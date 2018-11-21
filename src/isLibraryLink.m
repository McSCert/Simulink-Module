function b = isLibraryLink(blocks)
% ISLIBRARYLINK Determines if the block is a link to a library.
%
%   Inputs:
%       block   Pathname or handle of a block.
%
%   Outputs:
%       b       Whether the block is a Library Link(1) or not(0).
    
    % Convert whatever input to handles
    blocks = inputToNumeric(blocks);
    
    b = zeros(1, length(blocks));
    
    % Check if block is a Library Link
    for i = 1:length(blocks)
        try
            b(i) = strcmpi(get_param(blocks(i), 'LinkStatus'), 'resolved') && ...
                ~isempty(get_param(blocks(i), 'ReferenceBlock'));
        catch % block does not have this parameter
        end
    end
end