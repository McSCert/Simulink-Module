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
        b = blocks(i);
        if any(find(strcmp(blockTypes{i}, {'Inport', 'Outport'})))
            dims{i} = get_param(b, 'PortDimensions');

        elseif isSimulinkFcn(b) && ~isLibraryLink(b)
            [indim, outdim] = getFcnArgsDim(b);
            dims{i} = ['In: ' strjoin(indim, ', '), '; Out: ' strjoin(outdim, ', ')];

        elseif any(find(strcmp(blockTypes{i}, {'DataStoreRead', 'DataStoreWrite'})))
            % Find Simulink.Signal object, then get its DataType
            dims{i} = 'Unknown';
            
        elseif any(find(strcmp(blockTypes{i}, {'ToFile', 'FromFile'})))
            dims{i} = 'N/A';
            
        elseif strcmp(blockTypes{i}, 'FromWorkspace')            
            dims{i} = 'N/A';

        elseif strcmp(blockTypes{i}, 'FromSpreadsheet')
            % Only one dimensional signals are supported
            oneDims = num2str(ones(1, length(get_param(b, 'PortConnectivity'))));
            oneDims = regexprep(oneDims, ' +', ', ');
            dims{i} = oneDims;
            
        elseif strcmp(blockTypes{i}, 'ToWorkspace')
            dims{i} = get_param(b, 'SaveFormat'); % VariableName? SaveFormat?
            
        elseif strcmp(blockTypes{i}, 'ModelReference')
             dims{i} = 'N/A';

        else
            try
                dims{i} = get_param(b, 'PortDimensions');
            catch
               % warning(['No dimension was identified for block ' get_param(b, 'Name') '.']);
                dims{i} = 'N/A';
            end
        end
    end
end