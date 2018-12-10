function types = getDataType_MJ(blocks)
% GETDATATYPE Return the block's data type.
%
%   Inputs:
%       blocks  Array of block names of handles.
%
%   Outputs:
%       types   Cell array of data types.
%
%   Example:
%       >> getDataType({'model/In1', 'model/Out1'})
%           ans =
%               {'auto:inherit'}    
%               {'double'}

    blocks = inputToNumeric(blocks);

    types = cell(size(blocks));
    blockTypes = get_param(blocks, 'BlockType');
    if ~iscell(blockTypes) || length(blockTypes) == 1
        blockTypes = {blockTypes};
    end

    for i = 1:length(blocks)
        b = blocks(i);
        
        if any(find(strcmp(blockTypes{i}, {'Outport', 'Inport', 'FromFile', 'FromSpreadsheet', 'FromWorkspace'})))
            types{i} = get_param(b, 'OutDataTypeStr');
            
        elseif strcmp(blockTypes{i}, 'ToFile')
            types{i} = get_param(b, 'SaveFormat');
            
        elseif strcmp(blockTypes{i}, 'ToWorkspace')
            types{i} = get_param(b, 'SaveFormat');
            
        elseif any(find(strcmp(blockTypes{i}, {'DataStoreRead', 'DataStoreWrite'})))
            % Find Simulink.Signal object, then get its DataType
    
            % Assume Data Stores are in the base workspace/data dictionary
            %1) Workspace
%             workspaceData = evalin('base', 'whos');
%             idx = ismember({workspaceData.class}, 'Simulink.Signal');
%             datastores = workspaceData(idx);
%             match = strcmp({datastores.name}, get_param(blocks(i), 'DataStoreName'));
            types{i} = 'Unknown';
            
        elseif isSimulinkFcn(b)
            [intype, outtype] = getFcnArgsType(b);
            types{i} = ['In: ' strjoin(intype, ', '), '; Out: ' strjoin(outtype, ', ')];
            
        elseif isLibraryLink(b)
            types{i} = 'N/A';
            
        elseif strcmp(blockTypes{i}, 'ModelReference')
            types{i} = 'N/A';
            
        else
            try
                types{i} = get_param(b, 'OutDataTypeStr');
            catch
               % warning(['No data type was identified for block ' get_param(b, 'Name') '.']);
                types{i} = 'N/A';
            end
        end
    end
end