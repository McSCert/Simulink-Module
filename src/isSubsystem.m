function b = isSubsystem(blocks)
% ISSUBSYSTEM Determine if the block is a subsystem.
%
%   Inputs:
%       block   Pathname or handle of a block.
%
%   Outputs:
%       b       Whether the block is a subsystem(1) or not(0).
    
    % Convert the input to handles
    blocks = inputToNumeric(blocks);
    
    b = zeros(1, length(blocks));
    % Check each block to see if its a subsystem
    for block = 1:length(blocks)
        try
            b(block) = strcmpi(get_param(blocks(block),'BlockType'),'SubSystem');
        catch % Unexpected error
        end
    end
end