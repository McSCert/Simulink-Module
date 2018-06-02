classdef Interface
% INTERFACE A Simulink model's interface.
% [][WORK IN PROGRESS]]
    properties
        MdlName     % Root system.
        MdlRefs     % Vector of Model References.
        DataStores	% Vector of Data Stores.
        Fcns        % Vector of Simulink Functions.
    end
    properties (Constant, Access = private)
        MdlRefsHeaderText = 'Model References';
        DataStoresHeaderText = 'Global Data Stores';
        FcnsHeaderText = 'Functions';
    end
    properties (Access = private)
        MdlRefsHeader
        DataStoresHeader
        FcnsHeader
        DataStoresBlks
    end
    methods (Access = public)
        function obj = Interface(m, mr, ds, fd)
            if nargin == 0
                obj.MdlName = '';
                obj.MdlRefs = struct('Handle',{},'Name',{},'Position',{});
                obj.DataStores = struct('Name',{});
                obj.Fcns = struct('Handle',{},'Name',{},'Position',{});

                obj.DataStoresBlks = struct('Read',{},'Write',{},'Source',{},'Sink',{});
            elseif nargin == 1
                obj.MdlName = bdroot(m);

                obj.MdlRefs = struct('Handle',{},'Name',{},'Position',{});
                obj = autoAddMdlRefs(obj);

                obj.DataStores = struct('Name',{});
                obj = autoAddDataStores(obj);

                obj.Fcns = struct('Handle',{},'Name',{},'Position',{});
                obj = autoAddFcns(obj);

                obj.DataStoresBlks = struct('Read',{},'Write',{},'Source',{},'Sink',{});
            else
                obj.MdlName = bdroot(m);
                obj.MdlRefs = mr;
                obj.DataStores = ds;
                obj.Fcns = fd;

                obj.DataStoresBlks = struct('Read',{},'Write',{},'Source',{},'Sink',{});
            end
        end
        function obj = addMdlRefs(obj, mr)
        % Add model references to interface.
        %   obj   Interface object.
        %   mr    Cell array of model reference path names or handles.
            mr = inputToCell(mr);
            for i = 1:length(mr)
                h = get_param(mr(i), 'Handle');
                n = get_param(mr(i), 'Name');
                p = get_param(mr(i), 'Position');

                j = length(obj.MdlRefs)+1;
                obj.MdlRefs(j).Handle = h{:};
                obj.MdlRefs(j).Name =  n{:};
                obj.MdlRefs(j).Position = p{:};
            end
        end

        function obj = addFcns(obj, fd)
        % Add functions to interface.
        %   obj   Interface object.
        %   fd    Cell array of Simulink function path names or handles.
            fd = inputToCell(fd);
            for i = 1:length(fd)
                h = get_param(fd(i), 'Handle');
                n = get_param(fd(i), 'Name');
                p = get_param(fd(i), 'Position');

                j = length(obj.Fcns)+1;
                obj.Fcns(j).Handle = h{:};
                obj.Fcns(j).Name =  n{:};
                obj.Fcns(j).Position = p{:};
            end
        end

        function obj = addDataStores(obj, ds)
        % Add data stores to interface.
        %   obj   Interface object.
        %   ds    Struct array of Simulink.Signal objects.
        % More info: https://www.mathworks.com/help/simulink/slref/signal.html

            for i = 1:length(ds)
                n = ds(i).name;

                j = length(obj.DataStores)+1;
                obj.DataStores(j).Name =  n;
            end
        end

        function obj = setModelName(obj, name)
        % Set the model name.
        %   obj   Interface object.
        %   name  System name.
            obj.MdlName = bdroot(name);
        end

        function modelInterface(obj)
        % Move blocks, add annotations

            % Eventually, use a for loop and space everything nicely

            interfaceWidth = 300; % Should be computed dynamically
            moveAll(obj.MdlName, interfaceWidth, 0);

            obj.MdlRefsHeader = Simulink.Annotation([bdroot '/' obj.MdlRefsHeaderText], 'FontSize', 14, 'Position', [10,50]);

            obj.DataStoresHeader = Simulink.Annotation([bdroot '/' obj.DataStoresHeaderText], 'FontSize', 14, 'Position', [10,100]);

            blkN = 1;
            for i = 1:length(obj.DataStores)
                blockCreated = false;
                while ~blockCreated
                    ds = obj.DataStores(i);
                    try
                        read = add_block('simulink/Signal Routing/Data Store Read', [bdroot '/Data Store Read' num2str(blkN)], ...
                            'DataStoreName', ds.Name);
                        write = add_block('simulink/Signal Routing/Data Store Write', [bdroot '/Data Store Write' num2str(blkN)], ...
                            'DataStoreName', ds.Name);

                        source = add_block('simulink/Sinks/Terminator', [bdroot '/Terminator' num2str(blkN)]);
                        sink = add_block('simulink/Sources/Ground', [bdroot '/Ground' num2str(blkN)]);
                        all_line(bdroot, source, read, 'autorouting', 'on');
                        all_line(bdroot, write, sink, 'autorouting', 'on');
                        obj.DataStoreBlks(i).Read = read;
                    catch
                        blkN = blkN + 1;
                    end
                end
            end

            obj.FcnsHeader = Simulink.Annotation([bdroot '/' obj.FcnsHeaderText], 'FontSize', 14, 'Position', [10,200]);

            %set_param(bdroot, 'Zoomfactor', 'FitSystem');
        end
    end
    methods (Access = private)
        %% FUNCTIONS
        function obj = autoAddMdlRefs(obj)
        % Find model references and add them to the interface.
            mr = find_system(obj.MdlName, 'BlockType', 'ModelReference');
            obj = addMdlRefs(obj, mr);
        end

        function obj = autoAddFcns(obj)
        % Find Simulink functions that are available externally and add them to
        % the interface.
            allFcns = find_system(obj.MdlName, 'BlockType', 'SubSystem', ...
                'IsSimulinkFunction', 'on', 'Commented', 'off');
            exposedFcns = {};
            for j = 1:length(allFcns)
                vis = getFcnScope(allFcns(j));
                if (vis{:} == Scope.Scoped || vis{:} == Scope.Global)
                    exposedFcns(end+1) = allFcns(j);
                end
            end
            obj = addFcns(obj, exposedFcns);
        end

        %% DATA STORES
        function obj = autoAddDataStores(obj)
        % Find global data stores in the workspace and add them to the interface.
            workspaceData = evalin('base', 'whos');
            idx = ismember({workspaceData.class}, 'Simulink.Signal');
            dataStores = workspaceData(idx);

            obj = addDataStores(obj, dataStores);
        end
    end
end