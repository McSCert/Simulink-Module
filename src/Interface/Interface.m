classdef Interface
% INTERFACE A representation of a Simulink model interface.
%
%   Note: This class will not work with versions earlier than R2016a, due to 
%   the use of "Property Restriction Syntax". See the Matlab Object-Oriented
%   Programming guide.

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
                
        % OUTPUTS
        OutputHeader          = InterfaceHeader('Outputs');
        OutportHeader         = InterfaceHeader('Outports');
        ToFileHeader          = InterfaceHeader('To Files');
        ToWorkspaceHeader     = InterfaceHeader('To Workspaces');
        DataStoreWriteHeader  = InterfaceHeader('Data Store Writes');
        
        % EXPORTS
        ExportHeader          = InterfaceHeader('Exports');
        FunctionHeader        = InterfaceHeader('Simulink Functions');
        
        % Other
        RootSystemHandle
        FilePath
    end
    methods (Access = public)
        function obj = Interface(m)
            if nargin == 0
                obj.ModelName = '';
            elseif nargin == 1
                obj.ModelName = bdroot(m);
                obj.RootSystemHandle = get_param(obj.ModelName, 'Handle');
                obj = autoAdd(obj);
            end
        end
        function path = getFilePath(obj)
            path = obj.FilePath; 
        end
        function hdl = getHandle(obj)
            hdl = obj.RootSystemHandle;
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
            %       varargin Part of the interface to check if empty: 
            %                ['Input' | 'Output' | 'Export']
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
            %       varargin    Parameter, Value pairs:   
            %       'Verbose'   Whether to show empty items (1, default) or not (0).
            %
            %   Outputs:
            %       N/A
            
            verbose = getInput('Verbose', varargin);           
            if isempty(verbose)
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
                    fprintf('%s: (%d)\n', obj.InportHeader.Label, length(obj.Inport));
                    for i = 1:length(obj.Inport)
                        fprintf('\t');
                        obj.Inport(i).print;
                    end
                end

                if isempty(obj.FromFile) && verbose
                    fprintf('%s:\n\tN/A\n', obj.FromFileHeader.Label);
                elseif ~isempty(obj.FromFile)
                    fprintf('%s: (%d)\n', obj.FromFileHeader.Label, length(obj.FromFile));
                    for i = 1:length(obj.FromFile)
                        fprintf('\t');
                        obj.FromFile(i).print;
                    end
                end

                if isempty(obj.FromWorkspace) && verbose
                    fprintf('%s:\n\tN/A\n', obj.FromWorkspaceHeader.Label);
                elseif ~isempty(obj.FromWorkspace)
                    fprintf('%s: (%d)\n', obj.FromWorkspaceHeader.Label, length(obj.FromWorkspace));
                    for i = 1:length(obj.FromWorkspace)
                        fprintf('\t');
                        obj.FromWorkspace(i).print;
                    end
                end

                if isempty(obj.FromSpreadsheet) && verbose
                    fprintf('%s:\n\tN/A\n', obj.FromSpreadsheetHeader.Label);
                elseif ~isempty(obj.FromSpreadsheet)
                    fprintf('%s: (%d)\n', obj.FromSpreadsheetHeader.Label, length(obj.FromSpreadsheet));
                    for i = 1:length(obj.FromSpreadsheet)
                        fprintf('\t');
                        obj.FromSpreadsheet(i).print;
                    end
                end

                if isempty(obj.DataStoreRead) && verbose
                    fprintf('%s:\n\tN/A\n', obj.DataStoreReadHeader.Label);
                elseif ~isempty(obj.DataStoreRead)
                    fprintf('%s: (%d)\n', obj.DataStoreReadHeader.Label, length(obj.DataStoreRead));
                    for i = 1:length(obj.DataStoreRead)
                        fprintf('\t');
                        obj.DataStoreRead(i).print;
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
                    fprintf('%s: (%d)\n', obj.OutportHeader.Label, length(obj.Outport));
                    for i = 1:length(obj.Outport)
                        fprintf('\t');
                        obj.Outport(i).print;
                    end
                end

                if isempty(obj.ToFile) && verbose
                    fprintf('%s:\n\tN/A\n', obj.ToFileHeader.Label);
                elseif ~isempty(obj.ToFile)
                    fprintf('%s: (%d)\n', obj.ToFileHeader.Label, length(obj.ToFile));
                    for i = 1:length(obj.ToFile)
                        fprintf('\t');
                        obj.ToFile(i).print;
                    end
                end

                if isempty(obj.ToWorkspace) && verbose
                    fprintf('%s:\n\tN/A\n', obj.ToWorkspaceHeader.Label);
                elseif ~isempty(obj.ToWorkspace)
                    fprintf('%s: (%d)\n', obj.ToWorkspaceHeader.Label, length(obj.ToWorkspace));
                    for i = 1:length(obj.ToWorkspace)
                        fprintf('\t');
                        obj.ToWorkspace(i).print;
                    end
                end

                if isempty(obj.DataStoreWrite) && verbose
                    fprintf('%s:\n\tN/A\n', obj.DataStoreWriteHeader.Label);
                elseif ~isempty(obj.DataStoreWrite)
                    fprintf('%s: (%d)\n', obj.DataStoreWriteHeader.Label, length(obj.DataStoreWrite));
                    for i = 1:length(obj.DataStoreWrite)
                        fprintf('\t');
                        obj.DataStoreWrite(i).print;
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
                    fprintf('%s: (%d)\n', obj.FunctionHeader.Label, length(obj.Function));
                    for i = 1:length(obj.Function)
                        fprintf('\t');
                        obj.Function(i).print;
                    end
                end
            end
        end
        function el = get(obj, loc)
            % GET Retrieve an element from the interface.
            %
            %   Inputs:
            %       obj     Interface object.
            %       loc    Location.
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
            % ADD Add item to the interface.
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
            %       obj         Interface object.
            %
            %   Outputs:
            %       obj         Interface object.
            
            if isempty(obj.ModelName)
                error('Interface has no model.');
            elseif isempty(obj)
                warning('No elements on the interface.');
                return
            end
            
            % Default parameters for complying with MAAB
            options = {'ShowName' ,'on', 'HideAutomaticName', 'off', 'Commented', 'on'};
            
            % Get orignal model bounds before we start adding blocks
            modelBlocks = find_system(obj.ModelName, 'SearchDepth', '1', 'FindAll', 'on', 'IncludeCommented', 'on');
            modelBounds = bounds_of_sim_objects(modelBlocks);
            
            % Spacing constants
            SPACEBETWEEN_ModelAndInterface = 150;
            SPACEAFTER_Block = 30;
            SPACEAFTER_Header = 10;
            SPACEAFTER_MainHeader = 4;
            LARGEFONT = 18;
            SMALLFONT = 14;
            
            % ADD BLOCKS/ANNOTATIONS
            if ~isempty(obj, 'Input')
                obj.InputHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.InputHeader.Label], 'FontSize', LARGEFONT).Handle;
            end
            if ~isempty(obj.Inport)
                obj.InportHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.InportHeader.Label], 'FontSize', SMALLFONT).Handle;
                for a = 1:length(obj.Inport)
                    obj.Inport(a).InterfaceHandle = get_param(obj.Inport(a).Fullpath, 'Handle');
                    obj.Inport(a).InterfacePath = getfullname(obj.Inport(a).InterfaceHandle);
                    
                    % Convert lines to goto/from connections
                    lines = get_param(obj.Inport(a).Handle, 'LineHandles');
                    lines = lines.Outport;
                    tag = ['Goto_' obj.Inport(a).Name];
                    tag = regexprep(tag, '[^\w]', '');
                    
                    % Check for conflicts with existing gotos with the same name
                    conflictLocalGotos = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Goto', 'GotoTag', tag);
                    conflictsGlobalGotos = find_system(obj.ModelName, 'BlockType', 'Goto', 'TagVisibility', 'global', 'GotoTag', tag);
                    num = 0;
                    newTag = tag;
                    while ~isempty(conflictLocalGotos) || ~isempty(conflictsGlobalGotos)
                        num = num + 1;
                        newTag = [tag '_' num2str(num)];
                        conflictLocalGotos = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Goto', 'GotoTag', newTag);
                        conflictsGlobalGotos = find_system(obj.ModelName, 'BlockType', 'Goto', 'TagVisibility', 'global', 'GotoTag', newTag);
                    end
                    line2Goto(obj.ModelName, lines, newTag);
                    
                    fromName = char(getDsts(obj.Inport(a).Handle, 'IncludeImplicit', 'off'));
                    obj.Inport(a).TerminatorHandle = get_param(fromName, 'Handle');
                    obj.Inport(a).TerminatorPath = getfullname(obj.Inport(a).TerminatorHandle);
                end
            end
            
            nblock = 1;
            if ~isempty(obj.FromFile)
                obj.FromFileHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.FromFileHeader.Label], 'FontSize', SMALLFONT).Handle;
                for b = 1:length(obj.FromFile)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            name = [obj.ModelName '/From File' num2str(nblock)];
                            obj.FromFile(b).InterfaceHandle = add_block('simulink/Sources/From File', ...
                                name, ...
                                options{:});
                            obj.FromFile(b).InterfacePath = name;
                            
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
                        obj.FromFile(b).GroundPath = getfullname(obj.FromFile(b).GroundHandle);
                        obj.FromFile(b).TerminatorPath = getfullname(obj.FromFile(b).TerminatorHandle);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.FromSpreadsheet)
                obj.FromSpreadsheetHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.FromSpreadsheetHeader.Label], 'FontSize', SMALLFONT).Handle;
                for c = 1:length(obj.FromSpreadsheet)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            name = [obj.ModelName '/From Spreadsheet' num2str(nblock)];
                            obj.FromSpreadsheet(c).InterfaceHandle = add_block('simulink/Sources/From Spreadsheet', ...
                                name,...
                                options{:});
                            obj.FromSpreadsheet(c).InterfacePath = name;
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
                        obj.FromSpreadsheet(c).GroundPath = getfullname(obj.FromSpreadsheet(c).GroundHandle);
                        obj.FromSpreadsheet(c).TerminatorPath = getfullname(obj.FromSpreadsheet(c).TerminatorHandle);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.FromWorkspace)
                obj.FromWorkspaceHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.FromWorkspaceHeader.Label], 'FontSize', SMALLFONT).Handle;
                for d = 1:length(obj.FromWorkspace)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            name = [obj.ModelName '/From Workspace' num2str(nblock)];
                            obj.FromWorkspace(d).InterfaceHandle = add_block('simulink/Sources/From Workspace', ...
                                name, ...
                                options{:});
                            obj.FromWorkspace(d).InterfacePath = name;
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
                        obj.FromWorkspace(d).GroundPath = getfullname(obj.FromWorkspace(d).GroundHandle);
                        obj.FromWorkspace(d).TerminatorPath = getfullname(obj.FromWorkspace(d).TerminatorHandle);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.DataStoreRead)
                obj.DataStoreReadHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.DataStoreReadHeader.Label], 'FontSize', SMALLFONT).Handle;
                for e = 1:length(obj.DataStoreRead)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            name = [obj.ModelName '/Data Store Read' num2str(nblock)];
                            obj.DataStoreRead(e).InterfaceHandle = add_block('simulink/Signal Routing/Data Store Read', ...
                                name, ...
                                options{:});
                            obj.DataStoreRead(e).InterfacePath = name;
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
                        obj.DataStoreRead(e).GroundPath = getfullname(obj.DataStoreRead(e).GroundHandle);
                        obj.DataStoreRead(e).TerminatorPath = getfullname(obj.DataStoreRead(e).TerminatorHandle);
                    end
                end
            end
           
            if ~isempty(obj, 'Output')
                obj.OutputHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.OutputHeader.Label], 'FontSize', LARGEFONT).Handle;
            end
            if ~isempty(obj.Outport)
                obj.OutportHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.OutportHeader.Label], 'FontSize', SMALLFONT).Handle;
                for h = 1:length(obj.Outport)
                    obj.Outport(h).InterfaceHandle = get_param(obj.Outport(h).Fullpath, 'Handle');
                    obj.Outport(h).InterfacePath = getfullname(obj.Outport(h).InterfaceHandle);
                    
                    % Convert line(s) to goto/from connection
                    lines = get_param(obj.Outport(h).Handle, 'LineHandles');
                    lines = lines.Inport;      
                    tag = ['Goto_' obj.Outport(h).Name];
                    tag = regexprep(tag, '[^\w]', '');
                    
                    % Check for conflicts with existing gotos with the same name
                    conflictLocalGotos = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Goto', 'GotoTag', tag);
                    conflictsGlobalGotos = find_system(obj.ModelName, 'BlockType', 'Goto', 'TagVisibility', 'global', 'GotoTag', tag);
                    num = 0;
                    newTag = tag;
                    while ~isempty(conflictLocalGotos) || ~isempty(conflictsGlobalGotos)
                        num = num + 1;
                        newTag = [tag '_' num2str(num)];
                        conflictLocalGotos = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Goto', 'GotoTag', newTag);
                        conflictsGlobalGotos = find_system(obj.ModelName, 'BlockType', 'Goto', 'TagVisibility', 'global', 'GotoTag', newTag);
                    end
                    line2Goto(obj.ModelName, lines, newTag);
                    
                    fromName = char(getSrcs(obj.Outport(h).Handle, 'IncludeImplicit', 'off'));
                    obj.Outport(h).GroundHandle = get_param(fromName, 'Handle');
                    obj.Outport(h).GroundPath = getfullname(obj.Outport(h).GroundHandle);
                end
            end
            
            nblock = 1;
            if ~isempty(obj.ToFile)
                obj.ToFileHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.ToFileHeader.Label], 'FontSize', SMALLFONT).Handle;
                for i = 1:length(obj.ToFile)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            name = [obj.ModelName '/To File' num2str(nblock)];
                            obj.ToFile(i).InterfaceHandle = add_block('simulink/Sinks/To File', ...
                                name, ...
                                options{:});
                            obj.ToFile(i).InterfacePath = name;
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
                        obj.ToFile(i).GroundPath = getfullname(obj.ToFile(i).GroundHandle);
                        obj.ToFile(i).TerminatorPath = getfullname(obj.ToFile(i).TerminatorHandle);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.ToWorkspace)
                obj.ToWorkspaceHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.ToWorkspaceHeader.Label], 'FontSize', SMALLFONT).Handle;
                for j = 1:length(obj.ToWorkspace)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            name = [obj.ModelName '/To Workspace' num2str(nblock)];
                            obj.ToWorkspace(j).InterfaceHandle = add_block('simulink/Sinks/To Workspace', ...
                                name, ...
                                options{:});
                            obj.ToWorkspace(j).InterfacePath = name;
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
                        obj.ToWorkspace(j).GroundPath = getfullname(obj.ToWorkspace(j).GroundHandle);
                        obj.ToWorkspace(j).TerminatorPath = getfullname(obj.ToWorkspace(j).TerminatorHandle);
                    end
                end
            end
            
            nblock = 1;
            if ~isempty(obj.DataStoreWrite)
                obj.DataStoreWriteHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.DataStoreWriteHeader.Label], 'FontSize', SMALLFONT).Handle;
                for k = 1:length(obj.DataStoreWrite)
                    blockCreated = false;
                    while ~blockCreated
                        try
                            name = [obj.ModelName '/Data Store Write' num2str(nblock)];
                            obj.DataStoreWrite(k).InterfaceHandle = add_block('simulink/Signal Routing/Data Store Write', ...
                                name, ...
                                options{:});
                             obj.DataStoreWrite(k).InterfacePath = name;
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
                        obj.DataStoreWrite(k).GroundPath = getfullname(obj.DataStoreWrite(k).GroundHandle);
                        obj.DataStoreWrite(k).TerminatorPath = getfullname(obj.DataStoreWrite(k).TerminatorHandle);
                    end
                end
            end
            
            if ~isempty(obj, 'Export')
                obj.ExportHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.ExportHeader.Label], 'FontSize', LARGEFONT).Handle; 
            end
            if ~isempty(obj.Function)
                obj.FunctionHeader.Handle = Simulink.Annotation([obj.ModelName '/' obj.FunctionHeader.Label], 'FontSize', SMALLFONT).Handle;
                for l = 1:length(obj.Function)
                    obj.Function(l).InterfaceHandle = createFcnCaller(obj.ModelName, obj.Function(l).Fullpath);
                    obj.Function(l).InterfacePath = getfullname(obj.Function(l).InterfaceHandle);
                    set_param(obj.Function(l).InterfaceHandle, options{:})
                
                    % Connect to terminators/grounds
                    allPorts = get_param(obj.Function(l).InterfaceHandle, 'PortHandles');
                    if ~isempty(allPorts)
                        obj.Function(l).GroundHandle = fulfillPorts(allPorts.Inport);
                        obj.Function(l).TerminatorHandle = fulfillPorts(allPorts.Outport);
                        obj.Function(l).GroundPath = getfullname(obj.Function(l).GroundHandle);
                        obj.Function(l).TerminatorPath = getfullname(obj.Function(l).TerminatorHandle);
                    end
                end
            end

            % Get all interface blocks
            hAll = getInterfaceSorted(obj);
            [hMain, hGrnd, hTerm] = getInterfaceBlocks(obj);
            interfaceBlocks = [hAll, hGrnd, hTerm];
            
            % Correct block orientation of inport and outports, because they are
            % created by the user and can be flipped
            if ~isempty(obj.Inport)
                for m = 1:length(obj.Inport)
                    set_param(obj.Inport(m).InterfaceHandle, 'Orientation', 'right');
                end
            end
            if ~isempty(obj.Outport)
                for o = 1:length(obj.Outport)
                    set_param(obj.Outport(o).InterfaceHandle, 'Orientation', 'right');
                end
            end
            
            % Resize main interface blocks
            resizeAll(obj);
            
            % Show names of main blocks
            for p = 1:length(hMain)
                set_param(hMain(p), 'ShowName', 'on');
                set_param(hMain(p), 'HideAutomaticName', 'off');
            end
            
            % Don't show terminator/ground names. Block symbols are
            % self-explanatory
            sinks = [hGrnd, hTerm];
            for p = 1:length(sinks)
                set_param(sinks(p), 'ShowName', 'off');
            end
 
            % Vertically distribute interface blocks/annotations
            topModelBound = modelBounds(2);
            pNext = topModelBound;
            for q = 1:length(hAll)
                pCurrent = get_param(hAll(q), 'Position');
                height = pCurrent(4) - pCurrent(2);
                set_param(hAll(q), 'Position', [pCurrent(1), pNext, pCurrent(3), pNext + height]);
                
                if strcmp(get_param(hAll(q), 'Type'), 'annotation')
                    % Next one is annotation too, use a smaller space
                    if (q+1 <= length(hAll)) && strcmp(get_param(hAll(q+1), 'Type'), 'annotation') 
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
                    for r = 1:length(el.GroundHandle)
                        moveToConnectedPort(el.GroundHandle(r), 30);
                    end
                else
                    moveToConnectedPort(el.GroundHandle, 30);
                end
                % Terminators
                if length(el.TerminatorHandle) > 1
                    for s = 1:length(el.TerminatorHandle)
                        moveToConnectedPort(el.TerminatorHandle(s), 30);
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
            set_param(obj.ModelName, 'Zoomfactor', 'FitSystem');
        end
        function obj = delete(obj)
            % DELETE Remove the interface model representation (blocks, headings).
            %
            %   Inputs:
            %       obj         Interface object.
            %
            %   Outputs:
            %       obj         Interface object.
            
            if isempty(obj.ModelName)
                error('Interface has no model.');
            elseif isempty(obj)
                warning('No elements on the interface.');
                return
            end
            
            % Remove headings
            obj.InputHeader = delete(obj.InputHeader);
            obj.InportHeader = delete(obj.InportHeader);
            obj.FromFileHeader = delete(obj.FromFileHeader);
            obj.FromWorkspaceHeader = delete(obj.FromWorkspaceHeader);
            obj.FromSpreadsheetHeader = delete(obj.FromSpreadsheetHeader);
            obj.DataStoreReadHeader = delete(obj.DataStoreReadHeader);
            obj.OutputHeader = delete(obj.OutputHeader);
            obj.OutportHeader = delete(obj.OutportHeader);
            obj.ToFileHeader = delete(obj.ToFileHeader);
            obj.ToWorkspaceHeader = delete(obj.ToWorkspaceHeader);
            obj.DataStoreWriteHeader = delete(obj.DataStoreWriteHeader);
            obj.ExportHeader = delete(obj.ExportHeader);
            obj.FunctionHeader = delete(obj.FunctionHeader);            
            
            % Remove blocks
            for a = 1:length(obj.Inport)    
                obj.Inport(a) = deleteFromModel(obj.Inport(a));
            end
            
            for b = 1:length(obj.FromFile)
                obj.FromFile(b) = deleteFromModel(obj.FromFile(b));
            end
            
            for c = 1:length(obj.FromSpreadsheet)
                obj.FromSpreadsheet(c) = deleteFromModel(obj.FromSpreadsheet(c));
            end

            for d = 1:length(obj.FromWorkspace)
                obj.FromWorkspace(d) = deleteFromModel(obj.FromWorkspace(d));
            end

            for e = 1:length(obj.DataStoreRead)
                obj.DataStoreRead(e) = deleteFromModel(obj.DataStoreRead(e));
            end 
            
            for h = 1:length(obj.Outport)
                obj.Outport(h) = deleteFromModel(obj.Outport(h));
            end
            
            for i = 1:length(obj.ToFile)
                obj.ToFile(i) = deleteFromModel(obj.ToFile(i));
            end
            
            for j = 1:length(obj.ToWorkspace)
                obj.ToWorkspace(j) = deleteFromModel(obj.ToWorkspace(j));
            end
            
            for k = 1:length(obj.DataStoreWrite)
                obj.DataStoreWrite(k) = deleteFromModel(obj.DataStoreWrite(k));
            end
            
            for l = 1:length(obj.Function)
                obj.Function(l) = deleteFromModel(obj.Function(l));
            end
            
            % Re-adjust the zoom
            try
                set_param(obj.ModelName, 'Zoomfactor', 'FitSystem');
            catch
            end
            % Delete the interface .mat
            obj = deleteInterfaceMat(obj);
        end
        function obj = updateHandles(obj)

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
        function saveInterfaceMat(obj)
        % SAVEINTERFACE Save the interface object to a mat file
        % in the same directory as the model
            sys = obj.ModelName;
            syspath = get_param(sys, 'FileName');
            [path, name, ~] = fileparts(syspath);
            ext = '.mat';
            filename = fullfile(path, [name '_Interface' ext]);
            obj.FilePath = filename;
            save(filename, 'obj')
        end
    end
    methods (Access = private)
        function obj = autoAdd(obj, varargin)
            % AUTOADD Automatically search the model for inteface items and add them
            %   to the interface.
            
            if isempty(varargin)
                varargin = {...
                    'inport', 'fromfile', 'fromspreadsheet', 'fromworkspace', 'datastoreread', ...
                    'outport', 'tofile', 'toworkspace', 'datastorewrite', ...
                    'function'};
            end
            
            if any(contains2(varargin, 'inport'))
                ports = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Inport', 'Commented', 'off');
                obj = add(obj, ports);
            end
            if any(contains2(varargin, 'fromfile'))
                blocks = find_system(obj.ModelName, 'BlockType', 'FromFile', 'Commented', 'off');
                filename = get_param(blocks, 'FileName');
                
                % Remove non-unique
                [~, idx] = unique(filename);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if any(contains2(varargin, 'fromspreadsheet'))
                blocks = find_system(obj.ModelName, 'BlockType', 'FromSpreadsheet', 'Commented', 'off');
                filename = get_param(blocks, 'FileName');
                
                % Remove non-unique
                [~, idx] = unique(filename);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if any(contains2(varargin, 'fromworkspace'))
                blocks = find_system(obj.ModelName, 'BlockType', 'FromWorkspace', 'Commented', 'off');
                varname = get_param(blocks, 'VariableName');
                
                % Remove non-unique
                [~, idx] = unique(varname);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if any(contains2(varargin, 'datastoreread'))
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
            
            if any(contains2(varargin, 'outport'))
                ports = find_system(obj.ModelName, 'SearchDepth', 1, 'BlockType', 'Outport', 'Commented', 'off');
                obj = add(obj, ports);
            end
            if any(contains2(varargin, 'tofile'))
                blocks = find_system(obj.ModelName, 'BlockType', 'ToFile', 'Commented', 'off');
                filename = get_param(blocks, 'FileName');
                
                % Remove non-unique
                [~, idx] = unique(filename);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if any(contains2(varargin, 'toworkspace'))
                blocks = find_system(obj.ModelName, 'BlockType', 'ToWorkspace', 'Commented', 'off');                
                varname = get_param(blocks, 'VariableName');
                
                % Remove non-unique
                [~, idx] = unique(varname);
                blocks = blocks(idx);
                
                obj = add(obj, blocks);
            end
            if any(contains2(varargin, 'datastorewrite'))
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
            if any(contains2(varargin, 'function'))
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
                    
                    ports = get_param(block, 'Ports');
                    if ports(1) > 1 || ports(2) > 1
                        adjustHeight(block, 'PortParams', {'ConnectionType', {'Inport','Outport'}, 'Method', 'Compact', 'HeightPerPort', 40});
                    end
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
        function obj = deleteInterfaceMat(obj)
        % DELETEINTERFACE Delete the interface mat
            filename = obj.FilePath;
            if isfile(filename)
                delete(filename);
            end
            obj.FilePath = '';
        end
    end
end