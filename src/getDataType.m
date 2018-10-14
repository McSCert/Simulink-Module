function types = getDataType(blocks)
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
        if strcmp(blockTypes{i}, 'Outport') ...
            || strcmp(blockTypes{i}, 'Inport') ...
            || strcmp(blockTypes{i}, 'FromFile') ...
            || strcmp(blockTypes{i}, 'FromSpreadsheet') ...
            || strcmp(blockTypes{i}, 'FromWorkspace')
            types{i} = get_param(blocks(i), 'OutDataTypeStr');
        elseif strcmp(blockTypes{i}, 'ToFile')
            types{i} = get_param(blocks(i), 'SaveFormat');
        elseif strcmp(blockTypes{i}, 'ToWorkspace')
            types{i} = get_param(blocks(i), 'SaveFormat');
        elseif strcmp(blockTypes{i}, 'DataStoreRead') || strcmp(blockTypes{i},  'DataStoreWrite')
            % Find Simulink.Signal object, then get its DataType
    
            % Assume Data Stores are in the base workspace/data dictionary
            %1) Workspace
%             workspaceData = evalin('base', 'whos');
%             idx = ismember({workspaceData.class}, 'Simulink.Signal');
%             datastores = workspaceData(idx);
%             match = strcmp({datastores.name}, get_param(blocks(i), 'DataStoreName'));
            types{i} = 'Unknown';
        elseif isSimulinkFcn(blocks(i))
            [intype, outtype] = getFcnArgsType(blocks(i));
            types{i} = ['In: ' strjoin(intype, ', '), '; Out: ' strjoin(outtype, ', ')];
        else
            try
                types{i} = get_param(blocks(i), 'OutDataTypeStr');
            catch
               % warning(['No data type was identified for block ' get_param(blocks(i), 'Name') '.']);
                types{i} = 'N/A';
            end
        end
    end
end