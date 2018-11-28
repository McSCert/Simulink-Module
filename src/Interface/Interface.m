classdef Interface
    properties
        ModelName
        
        % INPUTS
        Inport          InterfaceItem
        FromFile        InterfaceItem
        FromWorkspace   InterfaceItem
        FromSpreadsheet InterfaceItem
        DataStoreRead   InterfaceItem
        
        % IMPORTS
        ModelReference  InterfaceItem
        LibraryLink     InterfaceItem   
        
        % OUTPUTS
        Outport         InterfaceItem
        ToFile          InterfaceItem
        ToWorkspace     InterfaceItem
        DataStoreWrite  InterfaceItem
        
        % EXPORTS
        Function        InterfaceItem
    end
    properties (Access = private)
        % INPUTS
        InputHeader           = InterfaceHeader('Inputs');
        InportHeader          = InterfaceHeader('Inports');
        FromFileHeader        = InterfaceHeader('From Files');
        FromWorkspaceHeader   = InterfaceHeader('From Workspaces');
        FromSpreadsheetHeader = InterfaceHeader('From Spreadsheets');
        DataStoreReadHeader   = InterfaceHeader('Data Store Reads');

        % IMPORTS
        ImportHeader          = InterfaceHeader('Imports');
        ModelReferenceHeader  = InterfaceHeader('Model References');
        LibraryLinkHeader     = InterfaceHeader('Library Links');
                
        % OUTPUTS
        OutputHeader          = InterfaceHeader('Outputs');
        OutportHeader         = InterfaceHeader('Outports');
        ToFileHeader          = InterfaceHeader('To Files');
        ToWorkspaceHeader     = InterfaceHeader('To Workspaces');
        DataStoreWriteHeader  = InterfaceHeader('Data Store Writes');
        
        % EXPORTS
        ExportHeader          = InterfaceHeader('Exports');
        FunctionHeader        = InterfaceHeader('Simulink Functions');
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
        function n = numel(obj)
            % NUMEL Number of elements in the interface.
            %
            %   Inputs:
            %       obj     Interface object.
            %
            %   Outputs:
            %       n       Number of elements.
            
            n = numel(obj.Inport) + ...
                numel(obj.FromFile) + ...
                numel(obj.FromWorkspace) + ...
                numel(obj.FromSpreadsheet) + ...
                numel(obj.DataStoreRead) + ...
                numel(obj.ModelReference) + ...
                numel(obj.LibraryLink) + ...
                numel(obj.Outport) + ...
                numel(obj.ToFile) + ...
                numel(obj.ToWorkspace) + ...
                numel(obj.DataStoreWrite) + ...
                numel(obj.Function);
        end
        function l = length(obj)
            % LENGTH Length of the interface, i.e., the number of elements on the
            %   interface.
            %
            %   Inputs:
            %       obj     Interface object.
            %
            %   Outputs:
            %       l       Length.
            
            l = numel(obj);
        end
        function s = size(obj)
            % SIZE Size of the interface, where number of rows corresponds to number
            %   of properties, and number of columns to number of elements of that
            %   property.
            %
            %   Inputs:
            %       obj     Interface object.
            %
            %   Outputs:
            %       s       Size.
            
            n = max([numel(obj.Inport), ...
                numel(obj.FromFile), ...
                numel(obj.FromWorkspace), ...
                numel(obj.FromSpreadsheet), ...
                numel(obj.DataStoreRead), ...
                numel(obj.ModelReference), ...
                numel(obj.LibraryLink), ...
                numel(obj.Outport), ...
                numel(obj.ToFile), ...
                numel(obj.ToWorkspace), ...
                numel(obj.DataStoreWrite), ...
                numel(obj.Function)]);
            s = [12, n];
        end
        function b = isempty(obj, varargin)
            % ISEMPTY Return 1 if the interface is empty and 0 otherwise.
            %
            %   Inputs:
            %       obj      Interface object.
            %       varargin Part of the interface: 
            %                ['Input' | 'Import' | 'Output' | 'Export']
            %
            %   Outputs:
            %       b        Whether the interface is empty (1) or not (0).
            
            if nargin > 1
                group = varargin{1}; 
                switch group
                    case 'Input'
                        b = isempty(obj.Inport) ...
                            && isempty(obj.FromFile) ...
                            && isempty(obj.FromWorkspace) ...
                            && isempty(obj.FromSpreadsheet) ...
                            && isempty(obj.DataStoreRead);
                    case 'Import'
                        b = isempty(obj.ModelReference) ...
                            && isempty(obj.LibraryLink);
                    case 'Output'
                        b = isempty(obj.Outport) ...
                            && isempty(obj.ToFile) ...
                            && isempty(obj.ToWorkspace) ...
                            && isempty(obj.DataStoreWrite);
                    case 'Export'
                        b = isempty(obj.Function);
                    otherwise
                        error('Invalid input argument.');
                end
            else
                if numel(obj) == 0
                    b = true;
                else
                    b = false;
                end
            end
        end
        function print(obj, varargin)
            % PRINT Print the interface in the Command Window.
            %
            %   Inputs:
            %       obj         Interface object.
            %       verbose     Whether to show empty items (1, default) or not (0).
            %
            %   Outputs:
            %       N/A
            
            if nargin > 1
                verbose = varargin{1};
            else
                verbose = false;
            end
            fprintf('%s\n', obj.InputHeader.Label);
            fprintf('------\n');
            
            if isempty(obj, 'Input')
                fprintf('N/A\n');
            else
                if isempty(obj.Inport) && verbose
                    fprintf('%s:\n\tN/A\n', obj.InportHeader.Label);
                elseif ~isempty(obj.Inport)
                    fprintf('%s:\n', obj.InportHeader.Label);
                    for i = 1:length(obj.Inport)
                        fprintf('\t%s, %s\n', obj.Inport(i).Fullpath, obj.Inport(i).DataType);
                    end
                end

                if isempty(obj.FromFile) && verbose
                    fprintf('%s:\n\tN/A\n', obj.FromFileHeader.Label);
                elseif ~isempty(obj.FromFile)
                    fprintf('%s:\n', obj.FromFileHeader.Label);
                    for i = 1:length(obj.FromFile)
                        fprintf('\t%s, %s\n', obj.FromFile(i).Fullpath, obj.FromFile(i).DataType);
                    end
                end

                if isempty(obj.FromWorkspace) && verbose
                    fprintf('%s:\n\tN/A\n', obj.FromWorkspaceHeader.Label);
                elseif ~isempty(obj.FromWorkspace)
                    fprintf('%s:\n', obj.FromWorkspaceHeader.Label);
                    for i = 1:length(obj.FromWorkspace)
                        fprintf('\t%s, %s\n', obj.FromWorkspace(i).Fullpath, obj.FromWorkspace(i).DataType);
                    end
                end

                if isempty(obj.FromSpreadsheet) && verbose
                    fprintf('%s:\n\tN/A\n', obj.FromSpreadsheetHeader.Label);
                elseif ~isempty(obj.FromSpreadsheet)
                    fprintf('%s:\n', obj.FromSpreadsheetHeader.Label);
                    for i = 1:length(obj.FromSpreadsheet)
                        fprintf('\t%s, %s\n', obj.FromSpreadsheet(i).Fullpath, obj.FromSpreadsheet(i).DataType);
                    end
                end

                if isempty(obj.DataStoreRead) && verbose
                    fprintf('%s:\n\tN/A\n', obj.DataStoreReadHeader.Label);
                elseif ~isempty(obj.DataStoreRead)
                    fprintf('%s:\n', obj.DataStoreReadHeader.Label);
                    for i = 1:length(obj.DataStoreRead)
                        fprintf('\t%s, %s\n', obj.DataStoreRead(i).Fullpath, obj.DataStoreRead(i).DataType);
                    end
                end
            end

            fprintf('\n%s\n', obj.ImportHeader.Label);
            fprintf('------\n');
            if isempty(obj, 'Import')
                fprintf('N/A\n');
            else
                if isempty(obj.ModelReference) && verbose
                    fprintf('%s:\n\tN/A\n', obj.ModelReferenceHeader.Label);
                elseif ~isempty(obj.ModelReference)
                    fprintf('%s:\n', obj.ModelReferenceHeader.Label);
                    for i = 1:length(obj.ModelReference)
                        fprintf('\t%s, %s\n', obj.ModelReference(i).Fullpath, obj.ModelReference(i).DataType);
                    end
                end            

                if isempty(obj.LibraryLink) && verbose
                    fprintf('%s:\n\tN/A\n', obj.LibraryLinkHeader.Label);
                elseif ~isempty(obj.LibraryLink)
                    fprintf('%s:\n', obj.LibraryLinkHeader.Label);
                    for i = 1:length(obj.LibraryLink)
                        fprintf('\t%s, %s\n', obj.LibraryLink(i).Fullpath, obj.LibraryLink(i).DataType);
                    end
                end
            end
            
            fprintf('\n%s\n', obj.OutputHeader.Label);
            fprintf('-------\n');
            
            if isempty(obj, 'Output')
                fprintf('N/A\n');
            else
                if isempty(obj.Outport) && verbose
                    fprintf('%s:\n\tN/A\n', obj.OutportHeader.Label);
                elseif ~isempty(obj.Outport)
                    fprintf('%s:\n', obj.OutportHeader.Label);
                    for i = 1:length(obj.Outport)
                        fprintf('\t%s, %s\n', obj.Outport(i).Fullpath, obj.Outport(i).DataType);
                    end
                end

                if isempty(obj.ToFile) && verbose
                    fprintf('%s:\n\tN/A\n', obj.ToFileHeader.Label);
                elseif ~isempty(obj.ToFile)
                    fprintf('%s:\n', obj.ToFileHeader.Label);
                    for i = 1:length(obj.ToFile)
                        fprintf('\t%s, %s\n', obj.ToFile(i).Fullpath, obj.ToFile(i).DataType);
                    end
                end

                if isempty(obj.ToWorkspace) && verbose
                    fprintf('%s:\n\tN/A\n', obj.ToWorkspaceHeader.Label);
                elseif ~isempty(obj.ToWorkspace)
                    fprintf('%s:\n', obj.ToWorkspaceHeader.Label);
                    for i = 1:length(obj.ToWorkspace)
                        fprintf('\t%s, %s\n', obj.ToWorkspace(i).Fullpath, obj.ToWorkspace(i).DataType);
                    end
                end

                if isempty(obj.DataStoreWrite) && verbose
                    fprintf('%s:\n\tN/A\n', obj.DataStoreWriteHeader.Label);
                elseif ~isempty(obj.DataStoreWrite)
                    fprintf('%s:\n', obj.DataStoreWriteHeader.Label);
                    for i = 1:length(obj.DataStoreWrite)
                        fprintf('\t%s, %s\n', obj.DataStoreWrite(i).Fullpath, obj.DataStoreWrite(i).DataType);
                    end
                end
            end

            fprintf('\n%s\n', obj.ExportHeader.Label);
            fprintf('-------\n');
            
            if isempty(obj, 'Export')
                fprintf('N/A\n');
            else
                if isempty(obj.Function) && verbose
                    fprintf('%s:\n\tN/A\n', obj.FunctionHeader.Label);
                elseif ~isempty(obj.Function)
                    fprintf('%s:\n', obj.FunctionHeader.Label);
                    for i = 1:length(obj.Function)
                        fprintf('\t%s, %s\n', obj.Function(i).Fullpath, obj.Function(i).DataType);
                    end
                end
            end
        end
        function el = get(obj, loc)
            % GET Retrieve an element from the interface.
            %
            %   Inputs:
            %       obj     Interface object.
            %       locs    Location.
            %
            %   Outputs:
            %       el      Element.
            
            % Linearize and short-circuit the evaluation
            all = cell(numel(obj), 1);
            curr = 0;  % Index where element is placed in linearized cell array
            
            for i = 1:numel(obj.Inport)
                all{i} = obj.Inport(i);
            end
            if ~isempty(i)
                curr = i;
            end
            
            if curr < loc
                for j = 1:numel(obj.FromFile)
                    all{curr+j} = obj.FromFile(j);
                end
                if ~isempty(j)
                    curr = curr + j;
                end
            else
                el = all{loc};
                return
            end
            
            if curr < loc
                for k = 1:numel(obj.FromWorkspace)
                    all{curr+k} = obj.FromWorkspace(k);
                end
                if ~isempty(k)
                    curr = curr + k;
                end
            else
                el = all{loc};
                return
            end
            
            if curr < loc
                for l = 1:numel(obj.FromSpreadsheet)
                    all{curr+l} = obj.FromSpreadsheet(l);
                end
                if ~isempty(l)
                    curr = curr + l;
                end
            else
                el = all{loc};
                return
            end
            
            if curr < loc
                for m = 1:numel(obj.DataStoreRead)
                    all{curr+m} = obj.DataStoreRead(m);
                end
                if ~isempty(m)
                    curr = curr + m;
                end
            else
                el = all{loc};
                return
            end
            
            if curr < loc
                for m = 1:numel(obj.ModelReference)
                    all{curr+m} = obj.ModelReference(m);
                end
                if ~isempty(m)
                    curr = curr + m;
                end
            else
                el = all{loc};
                return
            end

            if curr < loc
                for m = 1:numel(obj.LibraryLink)
                    all{curr+m} = obj.LibraryLink(m);
                end
                if ~isempty(m)
                    curr = curr + m;
                end
            else
                el = all{loc};
                return
            end
            
            if curr < loc
                for n = 1:numel(obj.Outport)
                    all{curr+n} = obj.Outport(n);
                end
                if ~isempty(n)
                    curr = curr + n;
                end
            else
                el = all{loc};
                return
            end
            
            if curr < loc
                for o = 1:numel(obj.ToFile)
                    all{curr+o} = obj.ToFile(o);
                end
                if ~isempty(o)
                    curr = curr + o;
                end
            else
                el = all{loc};
                return
            end
            
            if curr < loc
                for p = 1:numel(obj.ToWorkspace)
                    all{curr+p} = obj.ToWorkspace(p);
                end
                if ~isempty(p)
                    curr = curr + p;
                end
            else
                el = all{loc};
                return
            end
            
            if curr < loc
                for q = 1:numel(obj.DataStoreWrite)
                    all{curr+q} = obj.DataStoreWrite(q);
                end
                if ~isempty(q)
                    curr = curr + q;
                end
            else
                el = all{loc};
                return
            end
            
            if curr < loc
                for r = 1:numel(obj.Function)
                    all{curr+r} = obj.Function(r);
                end
                %if ~isempty(r)
                %    curr = curr + r;
                %end
            else
                el = all{loc};
                return
            end
            
            el = all{loc};
        end
        function [main, grnd, term] = getInterfaceBlocks(obj)
            % GETINTERFACEBLOCKS Return the blocks associated with the interface
            %   after it has been modelled. They are returned in the order that
            %   they appear on the interface.
            iter = createIterator(obj);
            main = [];  % Inport, ToFile, Function Caller, etc.
            term = [];  % Terminators
            grnd = [];  % Grounds
            while iter.hasNext()
                el = iter.next();
                main = [main el.InterfaceHandle];
                grnd = [grnd el.GroundHandle];
                term = [term el.TerminatorHandle];
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
                t = blockTypes{i};
                switch t
                    case 'Inport'
                        j = length(obj.Inport)+1;
                        obj.Inport(j) = InterfaceItem(names(i));
                    case 'FromFile'
                        j = length(obj.FromFile)+1;
                        obj.FromFile(j) = InterfaceItem(names(i));
                    case 'FromWorkspace'
                        j = length(obj.FromWorkspace)+1;
                        obj.FromWorkspace(j) = InterfaceItem(names(i));
                    case 'FromSpreadsheet'
                        j = length(obj.FromSpreadsheet)+1;
                        obj.FromSpreadsheet(j) = InterfaceItem(names(i));
                    case 'DataStoreRead'
                        j = length(obj.DataStoreRead)+1;
                        obj.DataStoreRead(j) = InterfaceItem(names(i));
                    case 'ModelReference'
                         j = length(obj.ModelReference)+1;
                        obj.ModelReference(j) = InterfaceItem(names(i));
                    case 'Outport'
                        j = length(obj.Outport)+1;
                        obj.Outport(j) = InterfaceItem(names(i));
                    case 'ToFile'
                        j = length(obj.ToFile)+1;
                        obj.ToFile(j) = InterfaceItem(names(i));
                    case 'ToWorkspace'
                        j = length(obj.ToWorkspace)+1;
                        obj.ToWorkspace(j) = InterfaceItem(names(i));
                    case 'DataStoreWrite'
                        j = length(obj.DataStoreWrite)+1;
                        obj.DataStoreWrite(j) = InterfaceItem(names(i));
                    otherwise
                        if isSimulinkFcn(names(i)) && ~isLibraryLink(names(i))
                            j = length(obj.Function)+1;
                            obj.Function(j) = InterfaceItem(names(i));
                        elseif isLibraryLink(names(i))
                            j = length(obj.LibraryLink)+1;
                            obj.LibraryLink(j) = InterfaceItem(names(i));
                        end
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
        function obj = model(obj)
            % MODEL Create a representation of the interface in the model.
            %   Moves blocks, adds annotations, and adds the blocks representing the
            %   interface.
            %
            %   Inputs:
            %       obj      Interface object.
            %       varargin Any additional parameters that the use wants to
            %                include for the interface blocks created.
            %
            %   Outputs:
            %       obj      Interface object.
            
            if isempty(obj.ModelName)
                error('Interface has no model.');
            elseif isempty(obj)
                warning('No elements on the interface.');
                return
            end
            
            % Add default parameters for complying with MAAB
            options = {'ShowName' ,'on', 'HideAutomaticName', 'off', 'Commented', 'on'};
            
            % Get orignal model bounds before we start adding blocks
            modelBlocks = find_system(obj.ModelName, 'SearchDepth', '1', 'FindAll', 'on', 'IncludeCommented', 'on');
            modelBounds = bounds_of_sim_objects(modelBlocks);
            
            % Spacing constants
            SPACEBETWEEN_ModelAndInterface = 100;
            SPACEAFTER_Block = 30;
            SPACEAFTER_Header = 10;
            SPACEAFTER_MainHeader = 4;
            LARGEFONT = 18;
            SMALLFONT = 14;
            
            % ADD BLOCKS/ANNOTATIONS
            if ~isempty(obj, 'Input')
                obj.InputHeader.Handle = Simulink.Annotation([bdroot '/' obj.InputHeader.Label], 'FontSize', LARGEFONT).Handle;
            end
            if ~isempty(obj.Inport)
                obj.InportHeader.Handle = Simulink.Annotation([bdroot '/' obj.InportHeader.Label], 'FontSize', SMALLFONT).Handle;
                for a = 1:length(obj.Inport)
                    obj.Inport(a).InterfaceHandle = get_param(obj.Inport(a).Fullpath, 'Handle');
                    
                    % Convert line(s) to goto/from connection
                    lines = get_param(obj.Inport(a).Handle, 'LineHandles');
                    lines = lines.Outport;
                    tag = ['Goto' obj.Inport(a).Name];
                    tag = strrep(tag, ':', '');
                    
                    % Check for conflicts with existing gotos with the same name
                    conflictLocalGotos = 1;
                    conflictsGlobalGotos = 1;
                    n = 1;
                    while ~isempty(conflictLocalGotos) || ~isempty(conflictsGlobalGotos)
                        tag = [tag num2str(n)];
                        n = n + 1;
                        conflictLocalGotos = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Goto', 'GotoTag', tag);
                        conflictsGlobalGotos = find_system(obj.ModelName, 'BlockType', 'Goto', 'TagVisibility', 'global', 'GotoTag', tag);
                    end
                    line2Goto(obj.ModelName, lines, tag);
                    
                    fromName = char(getDsts(obj.Inport(a).Handle, 'IncludeImplicit', 'off'));
                    obj.Inport(a).TerminatorHandle = get_param(fromName, 'Handle');
                end
            end
            
            nblock = 1;
            if ~isempty(obj.FromFile)
                obj.FromFileHeader.Handle = Simulink.Annotation([bdroot '/' obj.FromFileHeader.Label], 'FontSize', SMALLFONT).Handle;
                for b = 1:length(obj.FromFile)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.FromFile(b).InterfaceHandle = add_block('simulink/Sources/From File', ...
                                [bdroot '/From File' num2str(nblock)], ...
                                options{:});
                            
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    % Set name
                    name = get_param(obj.FromFile(b).Handle, 'FileName');
                    set_param(obj.FromFile(b).InterfaceHandle, 'FileName', name);
                    
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.FromFile(b).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.FromFile(b).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.FromFile(b).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.FromSpreadsheet)
                obj.FromSpreadsheetHeader.Handle = Simulink.Annotation([bdroot '/' obj.FromSpreadsheetHeader.Label], 'FontSize', SMALLFONT).Handle;
                for c = 1:length(obj.FromSpreadsheet)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.FromSpreadsheet(c).InterfaceHandle = add_block('simulink/Sources/From Spreadsheet', ...
                                [bdroot '/From Spreadsheet' num2str(nblock)],...
                                options{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    % Set name
                    name = get_param(obj.FromSpreadsheet(c).Handle, 'FileName');
                    set_param(obj.FromSpreadsheet(c).InterfaceHandle, 'FileName', name);
                    
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.FromSpreadsheet(c).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.FromSpreadsheet(c).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.FromSpreadsheet(c).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.FromWorkspace)
                obj.FromWorkspaceHeader.Handle = Simulink.Annotation([bdroot '/' obj.FromWorkspaceHeader.Label], 'FontSize', SMALLFONT).Handle;
                for d = 1:length(obj.FromWorkspace)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.FromWorkspace(d).InterfaceHandle = add_block('simulink/Sources/From Workspace', ...
                                [bdroot '/From Workspace' num2str(nblock)], ...
                                options{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    % Set name
                    name = get_param(obj.FromWorkspace(d).Handle, 'VariableName');
                    set_param(obj.FromWorkspace(d).InterfaceHandle, 'VariableName', name);
                    
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.FromWorkspace(d).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.FromWorkspace(d).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.FromWorkspace(d).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.DataStoreRead)
                obj.DataStoreReadHeader.Handle = Simulink.Annotation([bdroot '/' obj.DataStoreReadHeader.Label], 'FontSize', SMALLFONT).Handle;
                for e = 1:length(obj.DataStoreRead)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.DataStoreRead(e).InterfaceHandle = add_block('simulink/Signal Routing/Data Store Read', ...
                                [bdroot '/Data Store Read' num2str(nblock)], ...
                                options{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    % Set name
                    name = get_param(obj.DataStoreRead(e).Handle, 'DataStoreName');
                    set_param(obj.DataStoreRead(e).InterfaceHandle, 'DataStoreName', name);
                    
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.DataStoreRead(e).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.DataStoreRead(e).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.DataStoreRead(e).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end
            end
            
            if ~isempty(obj, 'Import')
                obj.ImportHeader.Handle = Simulink.Annotation([bdroot '/' obj.ImportHeader.Label], 'FontSize', LARGEFONT).Handle; 
            end
            nblock = 1;
            if ~isempty(obj.ModelReference)
                obj.ModelReferenceHeader.Handle = Simulink.Annotation([bdroot '/' obj.ModelReferenceHeader.Label], 'FontSize', SMALLFONT).Handle;
                for f = 1:length(obj.ModelReference)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.ModelReference(f).InterfaceHandle = add_block('simulink/Ports & Subsystems/Model', ...
                                [bdroot '/Model' num2str(nblock)], ...
                                options{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    % Set name
                    name = get_param(obj.ModelReference(f).Handle, 'ModelName');
                    set_param(obj.ModelReference(f).InterfaceHandle, 'ModelName', name);
                    
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.ModelReference(f).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.ModelReference(f).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.ModelReference(f).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end
            end
            nblock = 1;
            if ~isempty(obj.LibraryLink)
                obj.LibraryLinkHeader.Handle = Simulink.Annotation([bdroot '/' obj.LibraryLinkHeader.Label], 'FontSize', SMALLFONT).Handle;
                for f = 1:length(obj.LibraryLink)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            blockPath = get_param(obj.LibraryLink(f).Handle, 'ReferenceBlock');
                            blockName = get_param(obj.LibraryLink(f).Handle, 'Name');
                            obj.LibraryLink(f).InterfaceHandle = add_block(blockPath, ...
                                [bdroot '/' blockName num2str(nblock)], ...
                                options{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.LibraryLink(f).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.LibraryLink(f).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.LibraryLink(f).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end                
            end
            
            if ~isempty(obj, 'Output')
                obj.OutputHeader.Handle = Simulink.Annotation([bdroot '/' obj.OutputHeader.Label], 'FontSize', LARGEFONT).Handle;
            end
            if ~isempty(obj.Outport)
                obj.OutportHeader.Handle = Simulink.Annotation([bdroot '/' obj.OutportHeader.Label], 'FontSize', SMALLFONT).Handle;
                for h = 1:length(obj.Outport)
                    obj.Outport(h).InterfaceHandle = get_param(obj.Outport(h).Fullpath, 'Handle');
                    
                    % Convert line(s) to goto/from connection
                    lines = get_param(obj.Outport(h).Handle, 'LineHandles');
                    lines = lines.Inport;      
                    tag = ['Goto' obj.Outport(h).Name];
                    tag = strrep(tag, ':', '');
                    
                    % Check for conflicts with existing gotos with the same name
                    conflictLocalGotos = 1;
                    conflictsGlobalGotos = 1;
                    n = 1;
                    while ~isempty(conflictLocalGotos) || ~isempty(conflictsGlobalGotos)
                        tag = [tag num2str(n)];
                        n = n + 1;
                        conflictLocalGotos = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Goto', 'GotoTag', tag);
                        conflictsGlobalGotos = find_system(obj.ModelName, 'BlockType', 'Goto', 'TagVisibility', 'global', 'GotoTag', tag);
                    end
                    line2Goto(obj.ModelName, lines, tag);
                    
                    fromName = char(getSrcs(obj.Outport(h).Handle, 'IncludeImplicit', 'off'));
                    obj.Outport(h).GroundHandle = get_param(fromName, 'Handle');
                end
            end
            
            nblock = 1;
            if ~isempty(obj.ToFile)
                obj.ToFileHeader.Handle = Simulink.Annotation([bdroot '/' obj.ToFileHeader.Label], 'FontSize', SMALLFONT).Handle;
                for i = 1:length(obj.ToFile)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.ToFile(i).InterfaceHandle = add_block('simulink/Sinks/To File', ...
                                [bdroot '/To File' num2str(nblock)], ...
                                options{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    % Set name
                    name = get_param(obj.ToFile(i).Handle, 'FileName');
                    set_param(obj.ToFile(i).InterfaceHandle, 'FileName', name);
                    
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.ToFile(i).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.ToFile(i).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.ToFile(i).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.ToWorkspace)
                obj.ToWorkspaceHeader.Handle = Simulink.Annotation([bdroot '/' obj.ToWorkspaceHeader.Label], 'FontSize', SMALLFONT).Handle;
                for j = 1:length(obj.ToWorkspace)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.ToWorkspace(j).InterfaceHandle = add_block('simulink/Sinks/To Workspace', ...
                                [bdroot '/To Workspace' num2str(nblock)], ...
                                options{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    % Set name
                    name = get_param(obj.ToWorkspace(j).Handle, 'VariableName');
                    set_param(obj.ToWorkspace(j).InterfaceHandle, 'VariableName', name);
                    
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.ToWorkspace(j).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.ToWorkspace(j).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.ToWorkspace(j).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.DataStoreWrite)
                obj.DataStoreWriteHeader.Handle = Simulink.Annotation([bdroot '/' obj.DataStoreWriteHeader.Label], 'FontSize', SMALLFONT).Handle;
                for k = 1:length(obj.DataStoreWrite)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            obj.DataStoreWrite(k).InterfaceHandle = add_block('simulink/Signal Routing/Data Store Write', ...
                                [bdroot '/Data Store Write' num2str(nblock)], ...
                                options{:});
                            blockCreated = true;
                        catch
                            nblock = nblock + 1;
                        end
                    end
                    % Set name
                    name = get_param(obj.DataStoreWrite(k).Handle, 'DataStoreName');
                    set_param(obj.DataStoreWrite(k).InterfaceHandle, 'DataStoreName', name);
                    
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.DataStoreWrite(k).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.DataStoreWrite(k).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.DataStoreWrite(k).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end
            end
            
            if ~isempty(obj, 'Export')
                obj.ExportHeader.Handle = Simulink.Annotation([bdroot '/' obj.ExportHeader.Label], 'FontSize', LARGEFONT).Handle; 
            end
            if ~isempty(obj.Function)
                obj.FunctionHeader.Handle = Simulink.Annotation([bdroot '/' obj.FunctionHeader.Label], 'FontSize', SMALLFONT).Handle;
                for l = 1:length(obj.Function)
                    obj.Function(l).InterfaceHandle = createFcnCaller(obj.ModelName, obj.Function(l).Fullpath);
                    set_param(obj.Function(l).InterfaceHandle, options{:})
                
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.Function(l).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.Function(l).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.Function(l).TerminatorHandle = fulfillPorts(allPorts.Outport);
                    end
                end
            end

            % Get all interface blocks
            hAll = getInterfaceSorted(obj);
            [~, hGrnd, hTerm] = getInterfaceBlocks(obj);
            interfaceBlocks = [hAll, hGrnd, hTerm];
            
            % Correct block orientation of inport and outports, because they are
            % created by the user and can be flipped
            if ~isempty(obj.Inport)
                for m = 1:length(obj.Inport)
                    set_param(obj.Inport(m).InterfaceHandle, 'Orientation', 'right');
                end
            end
            if ~isempty(obj.Outport)
                for n = 1:length(obj.Outport)
                    set_param(obj.Outport(n).InterfaceHandle, 'Orientation', 'right');
                end
            end
            
            % Resize main interface blocks
            resizeAll(obj);
            
            % Don't show terminator/ground names. Block symbols are
            % self-explanatory
            sinks = [hGrnd, hTerm];
            for o = 1:length(sinks)
                set_param(sinks(o), 'ShowName', 'off');
            end
 
            % Vertically distribute interface blocks/annotations
            topModelBound = modelBounds(2);
            pNext = topModelBound;
            for p = 1:length(hAll)
                pCurrent = get_param(hAll(p), 'Position');
                height = pCurrent(4) - pCurrent(2);
                set_param(hAll(p), 'Position', [pCurrent(1), pNext, pCurrent(3), pNext + height]);
                
                if strcmp(get_param(hAll(p), 'Type'), 'annotation')
                    % Next one is annotation too, use a smaller space
                    if (p+1 <= length(hAll)) && strcmp(get_param(hAll(p+1), 'Type'), 'annotation') 
                        pNext = pNext + height + SPACEAFTER_MainHeader;
                    else
                         pNext = pNext + height + SPACEAFTER_Header;
                    end
                else  
                    pNext = pNext + height + SPACEAFTER_Block;
                end
            end
            
            % Center main interface blocks and annotations
            alignBlocksInColumn(num2cell(hAll), 'center');

            % Move the terminators/grounds to their corresponding ports
            iter = createIterator(obj);
            while iter.hasNext()
                el = iter.next();
                % Ground
                if length(el.GroundHandle) > 1
                    for q = 1:length(el.GroundHandle)
                        moveToConnectedPort(el.GroundHandle(q), 30);
                    end
                else
                    moveToConnectedPort(el.GroundHandle, 30);
                end
                % Terminators
                if length(el.TerminatorHandle) > 1
                    for r = 1:length(el.TerminatorHandle)
                        moveToConnectedPort(el.TerminatorHandle(r), 30);
                    end
                else
                    moveToConnectedPort(el.TerminatorHandle, 30);
                end
            end
            
            % Left justify grounds
            alignBlocksInColumn(num2cell(hGrnd), 'left');
            
            % Right justify terminators
            alignBlocksInColumn(num2cell(hTerm), 'right');
            
            % Move the whole interface left/right
            leftModelBound = modelBounds(1);
            interfaceBounds = bounds_of_sim_objects(interfaceBlocks);
            rightInterfaceBound = interfaceBounds(3);
            if rightInterfaceBound < interfaceBounds
                shift = rightInterfaceBound - leftModelBound - SPACEBETWEEN_ModelAndInterface;
            else %rightInterfaceBound >= interfaceBounds
                shift = leftModelBound - rightInterfaceBound - SPACEBETWEEN_ModelAndInterface;
            end
            shiftBlocks(interfaceBlocks, [shift 0 shift 0]);

            % Re-adjust the zoom so we can see the whole interface
            set_param(bdroot, 'Zoomfactor', 'FitSystem');
        end
        function iter = createIterator(obj)
            % CREATEITERATOR Create the iterator object for iterating over an
            %   interface.
            %
            %   Inputs:
            %       obj     Interface object.
            %
            %   Outputs:
            %       iter    Iterator object.
            
            iter = InterfaceIterator(obj);
        end
    end
    methods (Access = private)
        function obj = autoAdd(obj, varargin)
            % AUTOADD Automatically search the model for inteface items and add them
            %   to the interface.
            
            if isempty(varargin)
                varargin = {...
                    'inport', 'fromfile', 'fromspreadsheet', 'fromworkspace', 'datastoreread', ...
                    'modelreference', 'librarylink', ...
                    'outport', 'tofile', 'toworkspace', 'datastorewrite', ...
                    'function'};
            end
            
            if contains2(varargin, 'inport')
                ports = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Inport', 'Commented', 'off');
                obj = add(obj, ports);
            end
            if contains2(varargin, 'fromfile')
                blocks = find_system(obj.ModelName, 'BlockType', 'FromFile', 'Commented', 'off');
                filename = get_param(blocks, 'FileName');
                
                % Remove non-unique
                [~, idx] = unique(filename);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'fromspreadsheet')
                blocks = find_system(obj.ModelName, 'BlockType', 'FromSpreadsheet', 'Commented', 'off');
                filename = get_param(blocks, 'FileName');
                
                % Remove non-unique
                [~, idx] = unique(filename);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'fromworkspace')
                blocks = find_system(obj.ModelName, 'BlockType', 'FromWorkspace', 'Commented', 'off');
                varname = get_param(blocks, 'VariableName');
                
                % Remove non-unique
                [~, idx] = unique(varname);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'datastoreread')
                % Only add data stores that are stored in the data dictionary or
                % base workspace because if they are in the model worskpace,
                % they are not shared outside the model
                blocks = find_system(obj.ModelName, 'BlockType', 'DataStoreRead', 'Commented', 'off');  
                
                % Remove non-unique based on DataStoreName
                dsname = get_param(blocks, 'DataStoreName');
                [dsname, idx] = unique(dsname);
                blocks = blocks(idx);
                
                for i = 1:length(blocks)
                    varInfo = Simulink.findVars(obj.ModelName, 'Name', dsname{i});
                    if strcmp(varInfo.SourceType, 'data dictionary') ...
                            || strcmp(varInfo.SourceType, 'base workspace')
                        obj = add(obj, blocks(i));
                    end
                end
            end
            
            if contains2(varargin, 'modelreference')
                blocks = find_system(obj.ModelName, 'BlockType', 'ModelReference', 'Commented', 'off');
                
                % Remove non-unique based on ModelFile
                modelname = get_param(blocks, 'ModelFile');
                [~, idx] = unique(modelname);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'librarylink')
                blocks = find_system(obj.ModelName, 'LinkStatus', 'resolved', 'Commented', 'off');
                
                % Remove non-unique based on ReferenceBlock
                libraryname = get_param(blocks, 'ReferenceBlock');
                [~, idx] = unique(libraryname);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end           
            
            if contains2(varargin, 'outport')
                ports = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Outport', 'Commented', 'off');
                obj = add(obj, ports);
            end
            if contains2(varargin, 'tofile')
                blocks = find_system(obj.ModelName, 'BlockType', 'ToFile', 'Commented', 'off');
                filename = get_param(blocks, 'FileName');
                
                % Remove non-unique
                [~, idx] = unique(filename);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'toworkspace')
                blocks = find_system(obj.ModelName, 'BlockType', 'ToWorkspace', 'Commented', 'off');                
                varname = get_param(blocks, 'VariableName');
                
                % Remove non-unique
                [~, idx] = unique(varname);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if contains2(varargin, 'datastorewrite')
                % Only add data stores that are stored in the data dictionary or
                % base workspace because if they are in the model worskpace,
                % they are not shared outside the model
                blocks = find_system(obj.ModelName, 'BlockType', 'DataStoreWrite', 'Commented', 'off');
                dsname = get_param(blocks, 'DataStoreName');
                
                % Remove non-unique
                [dsname, idx] = unique(dsname);
                blocks = blocks(idx);
                
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
                        fcns_global{end+1,1} = fcns_all{i};
                    end
                end
                obj = add(obj, unique(vertcat(fcns_scoped, fcns_global)));
            end
        end
        function resizeAll(obj)
            % RESIZEALL Resize all main blocks in the interface.
            %   (not terminators/grounds/gotos/froms)
            iter = createIterator(obj);
            while iter.hasNext()
                el = iter.next();
                if ~isempty(el.InterfaceHandle)
                    
                    block = [get_param(el.InterfaceHandle, 'Parent'), '/', get_param(el.InterfaceHandle, 'Name')];
                    
                    oldSize = get_param(block, 'Position');
                    [~, newSize] = adjustWidth(block, 'PerformOperation', 'off', 'Buffer', 12);
                    % Only resize if it's getting bigger
                    if (newSize(3) - newSize(1)) > (oldSize(3) - oldSize(1))
                        set_param(block, 'Position', newSize);
                    end
%                     try
%                         adjustHeight(get_param(el.InterfaceHandle, 'Path'));
%                     catch
%                         % FromFile blocks don't have a path parameter
%                         adjustHeight([get_param(el.InterfaceHandle, 'Parent'), '/', get_param(el.InterfaceHandle, 'Name')]);
%                     end
                end
            end
        end
        function handles = getInterfaceHeaders(obj)
            % GETINTERFACEHEADERS Return the annotations of the interface after
            %   it has been modelled. They are returned in the order that
            %   they appear on the interface.
            handles = [obj.InputHeader.Handle, ...
                obj.InportHeader.Handle, ...
                obj.FromFileHeader.Handle, ...
                obj.FromWorkspaceHeader.Handle, ...
                obj.FromSpreadsheetHeader.Handle, ...
                obj.DataStoreReadHeader.Handle, ...
                obj.ImportHeader.Handle, ...
                obj.ModelReferenceHeader.Handle, ... 
                obj.LibraryLinkHeader.Handle, ...
                obj.OutputHeader.Handle, ...
                obj.OutportHeader.Handle, ...
                obj.ToFileHeader.Handle, ...
                obj.ToWorkspaceHeader.Handle, ...
                obj.DataStoreWriteHeader.Handle, ...
                obj.ExportHeader.Handle, ...
                obj.FunctionHeader.Handle];
        end
        function handles = getInterfaceSorted(obj)
            handles = [obj.InputHeader.Handle, ...
                obj.InportHeader.Handle, ...
                obj.Inport.InterfaceHandle, ...
                obj.FromFileHeader.Handle, ...
                obj.FromFile.InterfaceHandle, ...
                obj.FromWorkspaceHeader.Handle, ...
                obj.FromWorkspace.InterfaceHandle, ...
                obj.FromSpreadsheetHeader.Handle, ...
                obj.FromSpreadsheet.InterfaceHandle, ...
                obj.DataStoreReadHeader.Handle, ...
                obj.DataStoreRead.InterfaceHandle, ...
                obj.ImportHeader.Handle, ...
                obj.ModelReferenceHeader.Handle, ... 
                obj.ModelReference.InterfaceHandle, ...
                obj.LibraryLinkHeader.Handle, ...
                obj.LibraryLink.InterfaceHandle, ...
                obj.OutputHeader.Handle, ...
                obj.OutportHeader.Handle, ...
                obj.Outport.InterfaceHandle, ...
                obj.ToFileHeader.Handle, ...
                obj.ToFile.InterfaceHandle, ...
                obj.ToWorkspaceHeader.Handle, ...
                obj.ToWorkspace.InterfaceHandle, ...
                obj.DataStoreWriteHeader.Handle, ...
                obj.DataStoreWrite.InterfaceHandle, ...
                obj.ExportHeader.Handle, ...
                obj.FunctionHeader.Handle, ...
                obj.Function.InterfaceHandle];          
        end
    end
end