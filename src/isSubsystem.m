function b = isSubsystem(block)
% ISSUBSYSTEM Determine if the block is a subsystem.
%
%   Inputs:
%       block   Pathname or handle of a block.
%
%   Outputs:
%       b       Whether the block is a subsystem(1) or not(0).
    
    % Strip block from cell array
    block = block{1};
    % Check if block is a subsystem
    b = strcmpi(get_param(block,'BlockType'),'SubSystem');
end