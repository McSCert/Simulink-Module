function [isGlobal, obj, location] = isGlobalDataStore(block)
% ISGLOBALDATASTORE Determine if a Data Store Read/Write block is a global data
%   store, that is, it has a corresponding Simulink.Signal that it refers to. A
%   Simulink.Signal object can be found in the base workspace, model workspace,
%   or data dictionary.
%
%   Inputs:
%       block       Block path or handle.
%
%   Outputs:
%       isGlobal    Whether the block is a global data store (1) or not (0).
%       obj         Simulink.Signal object corresponding to the block.
%       location    Object where the Simulink.Signal definition resides.

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
        % it does, it takes precedence over all other definitions.
        
        % Search for any associated memory block at the same level or above
        % Even if there is a workspace Simulink.Signal with the same name, the
        % Data Store Read/Write block will use the Memory block in the model.
        parent = get_param(block, 'Parent');
        root = bdroot(block);
        memoryAll = find_system(root, 'BlockType', 'DataStoreMemory', 'DataStoreName', name);
        memoryHere = find_system(parent, 'SearchDepth', 1, 'BlockType', 'DataStoreMemory', 'DataStoreName', name);
        memoryHereAndBelow = find_system(parent, 'BlockType', 'DataStoreMemory', 'DataStoreName', name);       
        memoryBelow = setdiff(memoryHereAndBelow, memoryHere);
        
        % As long as there is a Memory block in scope, the Data Store will not
        % be global (We don't really care which one exactly is associated)
        memoryInScope = setdiff(memoryAll, memoryBelow);
        
        % Check for a Simulink.Signal object 
        if ~isempty(memoryInScope)
            isGlobal = false;
            obj = [];
            location = []; % TODO: Find lowest common ancestor
        else
            
            % 1) Model Workspace
            % Check model workspace next, because it takes precedence over 
            % data dictionary or base workspace definitions
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
            % it no longer refers to the base workspace
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