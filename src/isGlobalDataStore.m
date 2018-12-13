function [isGlobal, obj, location] = isGlobalDataStore(block)
% ISGLOBALDATASTORE Determine if a Data Store Read/Write block is a global data
%   store, that is, it has a corresponding Simulink.Signal in the base workspace 
%   or linked data dictionary. 
%
%   Inputs:
%       block       Block path or handle.
%
%   Outputs:
%       isGlobal    Whether the block is a global data store (1) or not (0).
%       obj         Simulink.Signal object corresponding to the block.
%       location    Object where the Simulink.Signal definition resides.
%
%   Example:
%       >> [gbl, obj, loc] = isGlobalStateStore('Example/Data Store Write1')
%
%             glb =
%               logical
%                1
% 
%             obj = 
%               Signal with properties:
%                      CoderInfo: [1x1 Simulink.CoderInfo]
%                    Description: ''
%                       DataType: 'double'
%                            Min: []
%                            Max: []
%                           Unit: ''
%                     Dimensions: [1 3]
%                 DimensionsMode: 'Fixed'
%                     Complexity: 'real'
%                     SampleTime: -1
%                   InitialValue: ''
% 
%             loc = 
%               Dictionary with properties:
%                                 DataSources: {0x1 cell}
%                    HasAccessToBaseWorkspace: 0
%                 EnableAccessToBaseWorkspace: 0
%                           HasUnsavedChanges: 1
%                             NumberOfEntries: 3

    % TODO: Figure out if when the 'EnableAccessToBaseWorkspace' parameter is
    % true, this affects the results of this function. See:
    % https://www.mathworks.com/help/simulink/slref/simulink.data.dictionary-class.html#d120e428542
    
    % Convert input to path
    block = [get_param(block, 'Parent') '/' get_param(block, 'Name')];
    
    blockType = get_param(block, 'BlockType');
    if ~any(find(strcmp(blockType, {'DataStoreRead', 'DataStoreWrite'})))   
        isGlobal = false;
        obj = [];
        location = [];
    else
        name = get_param(block, 'DataStoreName');
        
        % 0) Model
        % Check if the model contains an associated Data Store Memory block. If
        % it does, it takes precedence over all other definitions. This is NOT a
        % global data store.
        
        % Search for any associated memory block at the same level or above
        % Even if there is a workspace Simulink.Signal with the same name, the
        % Data Store Read/Write block will use the Memory block in the model.
        parent = get_param(block, 'Parent');
        root = bdroot(block);
        memoryAll = find_system(root, 'BlockType', 'DataStoreMemory', 'DataStoreName', name);
        memoryHere = find_system(parent, 'SearchDepth', 1, 'BlockType', 'DataStoreMemory', 'DataStoreName', name);
        memoryHereAndBelow = find_system(parent, 'BlockType', 'DataStoreMemory', 'DataStoreName', name);       
        memoryBelow = setdiff(memoryHereAndBelow, memoryHere);
        memoryInScope = setdiff(memoryAll, memoryBelow);
        
        % Check for a Simulink.Signal object 
        if ~isempty(memoryInScope)
            isGlobal = false;
            obj = [];
            location = []; % TODO: Find lowest common ancestor (Get from Rescope Tool)
        else
            
            % 1) Model Workspace
            % Check model workspace next, because it takes precedence over 
            % data dictionary or base workspace definitions. This is NOT a
            % global data store.
            workspace = get_param(bdroot, 'modelworkspace');
            try
                ds = getVariable(workspace, name);
            catch ME
                if strcmp(ME.identifier, 'Simulink:Data:WksUndefinedVariable')
                    ds = [];
                else 
                    rethrow(ME)
                end
            end
            
            if ~isempty(ds)
                isGlobal = false;
                obj = ds;
                location = workspace;
                return
            end
            
            % 2) Data Dictionary
            % Check data dictionary next, because if a model is linked to a dictionary,
            % it no longer refers to the base workspace.
            dataDictName = get_param(root, 'DataDictionary');
            if ~isempty(dataDictName)
                dataDict = Simulink.data.dictionary.open(dataDictName);
                dataSection = getSection(dataDict, 'Design Data');
                try
                    dataEntry = getEntry(dataSection, name);
                catch ME
                    if strcmp(ME.identifier, 'SLDD:sldd:EntryNotFound')
                        dataEntry = [];
                    else
                        rethrow(ME)
                    end
                end
                if ~isempty(dataEntry)
                    isGlobal = true;
                    obj = getValue(dataEntry);
                    location = dataDict;
                    return
                else
                    isGlobal = false;
                    obj = [];
                    location = [];
                    return                    
                end
                
            % 3) Base Workspace
            else
                workspaceData = evalin('base', 'whos');
                idx = ismember({workspaceData.class}, 'Simulink.Signal');
                allDs = workspaceData(idx);
                match = strcmp({allDs.name}, name);
                if any(match)
                    ds = allDs(match);
                    isGlobal = true;
                    obj = evalin('base', ds.name);
                    location = 'base';
                end
            end
        end
    end
end