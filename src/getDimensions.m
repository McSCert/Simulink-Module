function dims = getDimensions(blocks)
% GETDATATYPE Return the block's dimensions.
%
%   Inputs:
%       blocks  Array of block names of handles.
%
%   Outputs:
%       types   Cell array of dimensions.
%
%   Example:
%       >> getDataType({'model/In1', 'model/Out1'})
%           ans =
%               {'auto:inherit'}    
%               {'double'}

    blocks = inputToNumeric(blocks);

    dims = cell(size(blocks));
    blockTypes = get_param(blocks, 'BlockType');
    if ~iscell(blockTypes) || length(blockTypes) == 1
        blockTypes = {blockTypes};
    end

    for i = 1:length(blocks)
        if strcmp(blockTypes{i},  'Outport') || strcmp(blockTypes{i},  'Inport')
            dims{i} = get_param(blocks(i), 'PortDimensions');

        elseif isSimulinkFcn(blocks(i))
            [indim, outdim] = getFcnArgsDim(blocks(i));
            dims{i} = ['In: ' strjoin(indim, ', '), '; Out: ' strjoin(outdim, ', ')];

        elseif strcmp(blockTypes{i},  'DataStoreRead') || strcmp(blockTypes{i},  'DataStoreWrite')
            % Find Simulink.Signal object, then get its DataType
            dims{i} = 'Unknown';
        elseif strcmp(blockTypes{i},  'ToFile') || strcmp(blockTypes{i},  'FromFile')
            dims{i} = 'N/A';
        elseif strcmp(blockTypes{i},  'FromWorkspace')            
            dims{i} = 'N/A';

        elseif strcmp(blockTypes{i},  'FromSpreadsheet')
            % Only one dimensional signals are supported
            oneDims = num2str(ones(1, length(get_param(blocks(i), 'PortConnectivity'))));
            oneDims = regexprep(oneDims, ' +', ', ');
            dims{i} = oneDims;
        elseif strcmp(blockTypes{i},  'ToWorkspace')
            dims{i} = get_param(blocks(i), 'SaveFormat'); % VariableName? SaveFormat?
        else
            try
                dims{i} = get_param(blocks(i), 'PortDimensions');
            catch
               % warning(['No dimension was identified for block ' get_param(blocks(i), 'Name') '.']);
                dims{i} = 'N/A';
            end
        end
    end
end