function moveAll(address, xshift, yshift)
% MOVEALL Move all blocks/lines/etc. in a system to a new position.
%
%   Inputs:
%       address Path of the system to be moved.
%       xshift  Number of pixels to move horizontally.
%       yshift  Number of pixels to move vertically.
%
%   Outputs:
%       N/A

    % Move line points (needed for lines with branches or bends)
    % Note: Must be done before the the blocks are moved. Sometimes the
    % points move when the blocks are moved. Sometimes they don't.
    allLines = find_system(address, 'Searchdepth', '1', 'FollowLinks', 'on',...
        'LookUnderMasks', 'All', 'FindAll', 'on', 'Type', 'line');
    for k = 1:length(allLines)
        pts = get_param(allLines(k), 'Points');
        pts(:,1) = pts(:,1) + xshift;
        pts(:,2) = pts(:,2) + yshift;
        set_param(allLines(k), 'Points', pts);
    end

    % Move blocks
    blocks = find_system(address, 'SearchDepth', '1', 'IncludeCommented', 'on');
    for i = 2:length(blocks) % Start at 2 because the root is entry 1
        bPos = get_param(blocks{i}, 'Position');
        bPos(1) = bPos(1) + xshift;
        bPos(2) = bPos(2) + yshift;
        bPos(3) = bPos(3) + xshift;
        bPos(4) = bPos(4) + yshift;
        set_param(blocks{i}, 'Position', bPos);
    end

    % Move annotations
    annotations = find_system(address, 'FindAll', 'on', 'SearchDepth', '1',...
        'type', 'annotation');
    for j = 1:length(annotations)
        aPos = get_param(annotations(j), 'Position');
        aPos(1) = aPos(1) + xshift;
        aPos(2) = aPos(2) + yshift;
        set_param(annotations(j), 'Position', aPos);
    end
end