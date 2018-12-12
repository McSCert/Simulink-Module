function [isGlobal, obj] = isGlobalDataStore(block)
% Check if a Data Store Read or Data Store Write block is a global data store,
%   that is, has a corresponding Simulink.Signal that is refers to.
%
%   Inputs:
%       block       Block path or handle.
%
%   Outputs:
%       isGlobal    Whether the block is a global data store (1) or not (0).
%       obj         Simulink.Signal object corresponding to the block.

    isGlobal = false;
    obj = [];
    
    % Convert input to path
    block = inputToCell(block);
    
    blockType = get_param(block, 'BlockType');
    if any(find(strcmp(blockType, {'DataStoreRead', 'DataStoreWrite'})))
        name = get_param(block, 'DataStoreName');
        
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
        
        % Check the base workspace for a Simulink.Signal object 
        if isempty(memoryInScope)
            workspaceData = evalin('base', 'whos');
            idx = ismember({workspaceData.class}, 'Simulink.Signal');
            datastoreObjs = workspaceData(idx);
            match = strcmp({datastoreObjs.name}, get_param(block, 'DataStoreName'));
            datastoreObjMatch = datastoreObjs(match);
            
            if ~isempty(datastoreObjMatch)
                isGlobal = true;
                obj = evalin('base', datastoreObjMatch.name);
            end
        end
    end
end