function dims = getDimensions(blocks)
% GETDATATYPE Return the block dimensions.
%
%   Inputs:
%       blocks  Array of block paths or handles.
%
%   Outputs:
%       types   Cell array of dimensions.
%
%   Example:
%       >> getDimensions{'model/In1', 'model/DataStore'})
%           ans =
%               {'-1'}    
%               {'[1 3]'}

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
            [isGlobal, obj, ~] = isGlobalDataStore(b);
            if isGlobal
                d = obj.Dimensions;
                if length(d) > 1
                    dims{i} = strrep(['[' sprintf('%d ', d) ']'], ' ]', ']');
                else 
                    dims{i} = num2str(d);
                end
            else
                dims{i} = 'Unknown';
            end               

        elseif any(find(strcmp(blockTypes{i}, {'ToFile', 'FromFile'})))
            dims{i} = 'N/A';

        elseif strcmp(blockTypes{i}, 'FromSpreadsheet')
            % Only one dimensional signals are supported
            oneDims = num2str(ones(1, length(get_param(b, 'PortConnectivity'))));
            oneDims = regexprep(oneDims, ' +', ', ');
            dims{i} = oneDims;
            
        elseif any(strcmp(blockTypes{i}, {'ToWorkspace', 'FromWorkspace'}))
            workspaceData = evalin('base', 'whos');
            idx = ismember({workspaceData.name}, get_param(b, 'VariableName'));
            
            if any(idx)
                match = workspaceData(idx);
                n = match.size;
                if length(n) > 1
                    dims{i} = ['[' num2str(n) ']'];
                    dims{i} = strrep(dims{i}, '  ', ' ');
                else
                    dims{i} = num2str(n);
                end
            else
                dims{i} = 'Unknown';
            end
            
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

function d = size2dim(s)
   if s(1) == 1 && s(2) == 1
       d = 1;
   else 
       d = 2;
   end
end