classdef Interface
	properties
        ModelName
        % INPUTS
        Inport          InterfaceItem
        FromFile        InterfaceItem 
        FromWorkspace   InterfaceItem 
        FromSpreadsheet InterfaceItem
        DataStoreRead   InterfaceItem
        
        % OUTPUTS
        Outport         InterfaceItem 
        ToFile          InterfaceItem 
        ToWorkspace     InterfaceItem
        DataStoreWrite  InterfaceItem
        Function        InterfaceItem
    end
    properties (Constant, Access = private)
        InputLabel          = 'Input';
        OutputLabel         = 'Output';
        
        InportLabel         = 'Inport';
        FromFileLabel       = 'From File';
        FromWorkspaceLabel  = 'From Workspace';
        FromSpreadsheetLabel = 'From Spreadsheet';
        DataStoreReadLabel  = 'Data Store Read';
        
        OutportLabel        = 'Outport';
        ToFileLabel         = 'To File';
        ToWorkspaceLabel    = 'To Workspace';
        DataStoreWriteLabel = 'Data Store Write';
        FunctionLabel       = 'Simulink Function';
    end
    properties (Access = private)
        ExportDataHeader
        FcnsHeader
    end
	methods (Access = public)
        function obj = Interface(m)
            if nargin == 0
                obj.ModelName = '';
            elseif nargin == 1
                obj.ModelName = bdroot(m); 
                obj = autoAdd(obj);
            end
        end
        function print(obj, varargin)
        % PRINT Print the interface in the Command Window.
        %
        %   Inputs:
        %       verbose     Whether to show empty items (1, default) or not (0).
        %
        %   Outputs:
        %       N/A
        
            if nargin > 1
                verbose = varargin{1};
            else
                verbose = false;
            end
            fprintf('INPUTS\n');
            fprintf('------\n');
            
            if isempty(obj.Inport) && verbose
                fprintf('%s:\n\tN/A\n', obj.InportLabel);  
            elseif ~isempty(obj.Inport) 
                fprintf('%s:\n', obj.InportLabel);
                for i = 1:length(obj.Inport)
                    fprintf('\t%s, %s\n', obj.Inport(i).Fullpath, obj.Inport(i).Type);
                end
            end
            
            if isempty(obj.FromFile) && verbose
                fprintf('%s:\n\tN/A\n', obj.FromFileLabel);  
            elseif ~isempty(obj.FromFile)
                fprintf('%s:\n', obj.FromFileLabel);
                for i = 1:length(obj.FromFile)
                    fprintf('\t%s, %s\n', obj.FromFile(i).Fullpath, obj.FromFile(i).Type);
                end
            end
            
            if isempty(obj.FromWorkspace) && verbose
                fprintf('%s:\n\tN/A\n', obj.FromWorkspaceLabel);    
            elseif ~isempty(obj.FromWorkspace)
                fprintf('%s:\n', obj.FromWorkspaceLabel);
                for i = 1:length(obj.FromWorkspace)
                    fprintf('\t%s, %s\n', obj.FromWorkspace(i).Fullpath, obj.FromWorkspace(i).Type);
                end
            end
            
            if isempty(obj.FromSpreadsheet) && verbose
                fprintf('%s:\n\tN/A\n', obj.FromSpreadsheetLabel);    
            elseif ~isempty(obj.FromSpreadsheet)
                fprintf('%s:\n', obj.FromSpreadsheetLabel);
                for i = 1:length(obj.FromSpreadsheet)
                    fprintf('\t%s, %s\n', obj.FromSpreadsheet(i).Fullpath, obj.FromSpreadsheet(i).Type);
                end
            end

            if isempty(obj.DataStoreRead) && verbose
                fprintf('%s:\n\tN/A\n', obj.DataStoreReadLabel);   
            elseif ~isempty(obj.DataStoreRead)
                fprintf('%s:\n', obj.DataStoreReadLabel);
                for i = 1:length(obj.DataStoreRead)
                    fprintf('\t%s, %s\n', obj.DataStoreRead(i).Fullpath, obj.DataStoreRead(i).Type);
                end
            end
            
            fprintf('\nOUTPUTS\n');
            fprintf('-------\n');
            
            if isempty(obj.Outport) && verbose
                fprintf('%s:\n\tN/A\n', obj.OutportLabel);   
            elseif ~isempty(obj.Outport)
                fprintf('%s:\n', obj.OutportLabel);
                for i = 1:length(obj.Outport)
                    fprintf('\t%s, %s\n', obj.Outport(i).Fullpath, obj.Outport(i).Type);
                end
            end
            
            if isempty(obj.ToFile) && verbose
                fprintf('%s:\n\tN/A\n', obj.ToFileLabel);  
            elseif ~isempty(obj.ToFile)
                fprintf('%s:\n', obj.ToFileLabel);
                for i = 1:length(obj.ToFile)
                    fprintf('\t%s, %s\n', obj.ToFile(i).Fullpath, obj.ToFile(i).Type);
                end
            end
            
            if isempty(obj.ToWorkspace) && verbose
                fprintf('%s:\n\tN/A\n', obj.ToWorkspaceLabel);   
            elseif ~isempty(obj.ToWorkspace)
                fprintf('%s:\n', obj.ToWorkspaceLabel);
                for i = 1:length(obj.ToWorkspace)
                    fprintf('\t%s, %s\n', obj.ToWorkspace(i).Fullpath, obj.ToWorkspace(i).Type);
                end
            end
                        
            if isempty(obj.DataStoreWrite) && verbose
                fprintf('%s:\n\tN/A\n', obj.DataStoreWriteLabel);   
            elseif ~isempty(obj.DataStoreWrite)
                fprintf('%s:\n', obj.DataStoreWriteLabel);
                for i = 1:length(obj.DataStoreWrite)
                    fprintf('\t%s, %s\n', obj.DataStoreWrite(i).Fullpath, obj.DataStoreWrite(i).Type);
                end
            end
            
            if isempty(obj.Function) && verbose
                fprintf('%s:\n\tN/A\n', obj.FunctionLabel);  
            elseif ~isempty(obj.Function)
                fprintf('%s:\n', obj.FunctionLabel);
                for i = 1:length(obj.Function)
                    fprintf('\t%s, %s\n', obj.Function(i).Fullpath, obj.Function(i).Type);
                end
            end
        end
        function obj = add(obj, names)
        % ADD Add item to interface.
        %
        %   Inputs:
        %       obj     Interface object.
        %       names   Cell array of names or vector of handles.
        %
        %   Outputs:
        %       obj     Interface object.
        
            names = inputToCell(names);
            blockTypes = get_param(names, 'BlockType');

            for i = 1:length(names)
                t = blockTypes(i);
                if strcmp(t, 'Inport')
                    j = length(obj.Inport)+1;
                    obj.Inport(j) = InterfaceItem(names(i));
                elseif strcmp(t, 'FromFile')
                    j = length(obj.FromFile)+1;
                    obj.FromFile(j) = InterfaceItem(names(i));
                elseif strcmp(t, 'FromWorkspace')
                    j = length(obj.FromWorkspace)+1;
                    obj.FromWorkspace(j) = InterfaceItem(names(i));     
                elseif strcmp(t, 'FromSpreadsheet')
                    j = length(obj.FromSpreadsheet)+1;
                    obj.FromSpreadsheet(j) = InterfaceItem(names(i));
                elseif strcmp(t, 'DataStoreRead')
                    j = length(obj.DataStoreRead)+1;
                    obj.DataStoreRead(j) = InterfaceItem(names(i));  
                elseif strcmp(t, 'Outport')
                    j = length(obj.Outport)+1;
                    obj.Outport(j) = InterfaceItem(names(i));
                elseif strcmp(t, 'ToFile')
                    j = length(obj.ToFile)+1;
                    obj.ToFile(j) = InterfaceItem(names(i));                    
                elseif strcmp(t, 'ToWorkspace')
                    j = length(obj.ToWorkspace)+1;
                    obj.ToWorkspace(j) = InterfaceItem(names(i));                      
                elseif strcmp(t, 'DataStoreWrite')
                    j = length(obj.DataStoreWrite)+1;
                    obj.DataStoreWrite(j) = InterfaceItem(names(i));                  
                elseif isSimulinkFcn(names(i))
                    j = length(obj.Function)+1;
                    obj.Function(j) = InterfaceItem(names(i));
                end
            end
        end
        function obj = setModelName(obj, name)
        % SETMODELNAME Set the model name.
        %   Inputs:
        %       obj     Interface object.
        %       name    System name.
        %   Outputs:
        %       obj     Interface object.
        
            obj.ModelName = bdroot(name);
        end 
        function obj = model(obj, varargin)
        % MODEL Create a representation of the interface in the model.
        %   Moves blocks, adds annotations, and adds the blocks representing the
        %   interface.
        %
        %   Inputs:
        %       obj     Interface object.
        %
        %   Outputs:
        %       obj     Interface object.
                    
           if isempty(obj.ModelName)
               error('Interface has no model.');
           end
            
           varargin = horzcat(varargin, 'ShowName' ,'on', 'HideAutomaticName', 'off');
           % TODO: use a for loop and space everything   
           interfaceWidth = 300; % Should be computed dynamically
           moveAll(obj.ModelName, interfaceWidth, 0);
           
           nblock = 1;
           if ~isempty(obj.FromFile)
                for j = 1:length(obj.FromFile)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.FromFile(j).InterfaceHandle = add_block('simulink/Sources/From File', [bdroot '/From File' num2str(nblock)], varargin{:});

                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end    
                    end
                    name = get_param(obj.FromFile(j).Handle, 'FileName');
                    set_param(obj.FromFile(j).InterfaceHandle, 'FileName', name); 
                end 
           end
           
            nblock = 1;
            if ~isempty(obj.FromSpreadsheet)
                for k = 1:length(obj.FromSpreadsheet)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.FromSpreadsheet(k).InterfaceHandle = add_block('simulink/Sources/From Spreadsheet', [bdroot '/From Spreadsheet' num2str(nblock)], varargin{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    name = get_param(obj.FromSpreadsheet(k).Handle, 'FileName');
                    set_param(obj.FromSpreadsheet(k).InterfaceHandle, 'FileName', name); 
                end 
            end
           
            nblock = 1;
            if ~isempty(obj.FromWorkspace)
                for l = 1:length(obj.FromWorkspace)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.FromWorkspace(l).InterfaceHandle = add_block('simulink/Sources/From Workspace', [bdroot '/From Workspace' num2str(nblock)], varargin{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    name = get_param(obj.FromWorkspace(l).Handle, 'VariableName');
                    set_param(obj.FromWorkspace(l).InterfaceHandle, 'VariableName', name);
                end 
            end
            
            nblock = 1;
            if ~isempty(obj.DataStoreRead)
                for m = 1:length(obj.DataStoreRead)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.DataStoreRead(m).InterfaceHandle = add_block('simulink/Signal Routing/Data Store Read', [bdroot '/Data Store Read' num2str(nblock)], varargin{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end    
                    name = get_param(obj.DataStoreRead(m).Handle, 'DataStoreName');
                    set_param(obj.DataStoreRead(m).InterfaceHandle, 'DataStoreName', name);
                end 
            end
            
            nblock = 1;
            if ~isempty(obj.ToFile)
                for n = 1:length(obj.ToFile)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.ToFile(n).InterfaceHandle = add_block('simulink/Sinks/To File', [bdroot '/To File' num2str(nblock)], varargin{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end   
                    name = get_param(obj.ToFile(n).Handle, 'FileName');
                    set_param(obj.ToFile(n).InterfaceHandle, 'FileName', name); 
                end 
            end
            
            nblock = 1;
            if ~isempty(obj.ToWorkspace)
                for o = 1:length(obj.ToWorkspace)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.ToWorkspace(o).InterfaceHandle = add_block('simulink/Sinks/To Workspace', [bdroot '/To Workspace' num2str(nblock)], varargin{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    name = get_param(obj.ToWorkspace(o).Handle, 'VariableName');
                    set_param(obj.ToWorkspace(o).InterfaceHandle, 'VariableName', name);
                end 
            end

            nblock = 1;
            if ~isempty(obj.DataStoreWrite)
                for p = 1:length(obj.DataStoreWrite)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.DataStoreWrite(p).InterfaceHandle = add_block('simulink/Signal Routing/Data Store Write', [bdroot '/Data Store Write' num2str(nblock)], varargin{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    name = get_param(obj.DataStoreWrite(p).Handle, 'DataStoreName');
                    set_param(obj.DataStoreWrite(p).InterfaceHandle, 'DataStoreName', name);
                end 
            end
            
            if ~isempty(obj.Function)
                for q = 1:length(obj.Function)
                    obj.Function(q).InterfaceHandle = createFcnCaller(obj.ModelName, obj.Function(q).Fullpath);    
                    set_param(obj.Function(q).InterfaceHandle, varargin{:})
                end 
            end
            
            % Resize blocks
            
            % Move blocks left and right
            
            % Connect to terminators/grounds

            % Add annotations
            %            obj.ExportDataHeader = Simulink.Annotation([bdroot '/' obj.ExportDataHeaderText], 'FontSize', 14, 'Position', [10,100]);
  
            
            set_param(bdroot, 'Zoomfactor', 'FitSystem');
        end      
    end
    methods (Access = private)
        function obj = autoAdd(obj, varargin)
        % AUTOADD Automatically search the model for inteface items and add them
        %   to the interface.
        
            if isempty(varargin)
                varargin = {'inport', 'fromfile', 'fromspreadsheet', 'fromworkspace', 'datastoreread', 'outport', 'tofile', 'toworkspace', 'datastorewrite', 'function'};
            end

            if contains2(varargin, 'inport')
                ports = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Inport', 'Commented', 'off');
                obj = add(obj, ports);
            end
            if contains2(varargin, 'fromfile')
                blocks = find_system(obj.ModelName, 'BlockType', 'FromFile', 'Commented', 'off');
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'fromspreadsheet')
                blocks = find_system(obj.ModelName, 'BlockType', 'FromSpreadsheet', 'Commented', 'off');
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'fromworkspace')
                blocks = find_system(obj.ModelName, 'BlockType', 'FromWorkspace', 'Commented', 'off');
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'datastoreread')
                % Only add data stores that are stored in the data dictionary or 
                % base workspace because if they are in the model worskpace, 
                % they are not shared outside the model
                blocks = find_system(obj.ModelName, 'BlockType', 'DataStoreRead', 'Commented', 'off');
                dsname = get_param(blocks, 'DataStoreName');
                for i = 1:length(blocks)
                    varInfo = Simulink.findVars(obj.ModelName, 'Name', dsname{i});
                    if strcmp(varInfo.SourceType, 'data dictionary') ...
                            || strcmp(varInfo.SourceType, 'base workspace')
                        obj = add(obj, blocks(i));
                    end   
                end
            end
            if contains2(varargin, 'outport')
                ports = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Outport', 'Commented', 'off');
                obj = add(obj, ports);
            end
            if contains2(varargin, 'tofile')
                blocks = find_system(obj.ModelName, 'BlockType', 'ToFile', 'Commented', 'off');
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'toworkspace')
                blocks = find_system(obj.ModelName, 'BlockType', 'ToWorkspace', 'Commented', 'off');
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'datastorewrite')
                % Only add data stores that are stored in the data dictionary or 
                % base workspace because if they are in the model worskpace, 
                % they are not shared outside the model
                blocks = find_system(obj.ModelName, 'BlockType', 'DataStoreWrite', 'Commented', 'off');
                dsname = get_param(blocks, 'DataStoreName');
                for i = 1:length(blocks)
                    varInfo = Simulink.findVars(obj.ModelName, 'Name', dsname{i});
                    if strcmp(varInfo.SourceType, 'data dictionary') ...
                            || strcmp(varInfo.SourceType, 'base workspace')
                        obj = add(obj, blocks(i));
                    end   
                end
            end
            if contains2(varargin, 'function')
                fcns_scoped = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'SubSystem', 'IsSimulinkFunction', 'on', 'Commented', 'off');
                fcns_all = find_system(obj.ModelName, 'BlockType', 'SubSystem', 'IsSimulinkFunction', 'on', 'Commented', 'off');
                scope = getFcnScope(fcns_all);
                
                fcns_global = {};
                for i = 1:length(fcns_all)
                    if scope{i} == Scope.Global
                        fcns_global{end+1} = fcns_all{i};
                    end
                end
                obj = add(obj, unique([fcns_scoped, fcns_global]));
            end
        end
    end
end