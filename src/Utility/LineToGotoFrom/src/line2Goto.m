function line2Goto(address, line, tag)
% LINE2GOTO Convert a signal line into a goto/from connection.
%
%   Inputs:
%       address     Simulink system name or path.
%       line        Line handle.
%       tag         Valid variable name string.
%
%   Examples:
%       line2Goto(gcs, gcls, 'NewLine')
%           Converts the currently selected lines in the current Simulink
%           system to goto/from blocks with the tag 'NewLine'.

    % Check address argument
    % 1) Check that model at address is open
    try
        assert(ischar(address));
        assert(bdIsLoaded(bdroot(address)));
    catch
        error('Invalid address. Model may not be loaded or name is invalid.');
    end

    % 2) Check that library is unlocked
    try
        assert(strcmp(get_param(bdroot(address), 'Lock'), 'off'));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:assert:failed') || ...
                strcmp(ME.identifier, 'MATLAB:assertion:failed')
            error('Model is locked.')
        else
            error('Invalid address.');
        end
    end

    % 3) Check that blocks are not in a linked library
    try
        assert(strcmp(get_param(address, 'LinkStatus'), 'none') || ...
        strcmp(get_param(address, 'LinkStatus'), 'inactive'));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:assert:failed') || ...
                strcmp(ME.identifier, 'MATLAB:assertion:failed')
            error('Cannot modify blocks within a linked library.');
        end
    end

    % Check line argument
    % 1) Check that a value was provided
    % 2) Check that it is a valid handle to an object
    % 3) Check that it is the handle for a line
    try
        assert(~isempty(line));
        assert(ishandle(line));
        assert(strcmp(get_param(line, 'Type'), 'line'));
    catch
        error('Invalid line argument.');
    end

   % Check tag argument
   % 1) Check type
    try
        assert(ischar(tag));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:assert:failed') || ...
                strcmp(ME.identifier, 'MATLAB:assertion:failed')
            error('Invalid goto/from tag provided. Tag must be a char.')
        end
    end
   % 2) Check that it can be used as a variable name
   try
        assert(isvarname(tag));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:assert:failed') || ...
                strcmp(ME.identifier, 'MATLAB:assertion:failed')
            error(['The goto/from tag provided is not a valid identifier. ' ...
                'Identifiers start with a letter, contain no spaces or ' ...
                'special characters and are at most 63 characters long.'])
        end
   end

    % Check for conflicts with existing gotos with the same name
    conflictLocalGotos = find_system(address, 'SearchDepth', 1, 'BlockType', 'Goto', 'GotoTag', tag);

    conflictsGlobalGotos = find_system(bdroot(address), 'BlockType', 'Goto', 'TagVisibility', 'global', 'GotoTag', tag);

    allScopedGotos = find_system(bdroot(address), 'BlockType', 'Goto', 'TagVisibility', 'scoped', 'GotoTag', tag);
    belowScopedGotos = find_system(address, 'BlockType', 'Goto', 'TagVisibility', 'scoped', 'GotoTag', tag);
    conflictsScopedGotos = setdiff(allScopedGotos, belowScopedGotos);

    if ~isempty(conflictLocalGotos)
        msg = ['Goto block "' tag '" already exists locally:' newline];
        for i = 1:length(conflictLocalGotos)
            msg = [msg, char(conflictLocalGotos(i)), newline];
        end
        warning(msg)
    elseif ~isempty(conflictsGlobalGotos)
        msg = ['Goto block "' tag '" overlaps with existing global goto:' newline];
        for i = 1:length(conflictsGlobalGotos)
            msg = [msg, char(conflictsGlobalGotos(i)), newline];
        end
        warning(msg)
    elseif ~isempty(conflictsScopedGotos)
        msg = ['Goto block "' tag '" overlaps with existing scoped goto(s):' newline];
        for i = 1:length(conflictsScopedGotos)
            msg = [msg, char(conflictsScopedGotos(i)), newline];
        end
        warning(msg)
    end

    % Check for conflicts with existing froms with the same name
    conflictLocalFroms = find_system(address, 'SearchDepth', 1, 'BlockType', 'From', 'GotoTag', tag);
    if ~isempty(conflictLocalFroms) && isempty(conflictLocalGotos)
        msg = ['From block "', tag, '" already exists locally:' newline];
        for i = 1:length(conflictLocalFroms)
            msg = [msg, char(conflictLocalFroms(i)), newline];
        end
        warning(msg)
    end

    % Get the line's source and destination blocks' ports
    srcPort = get_param(line, 'SrcPortHandle');
    dstPort = get_param(line, 'DstPortHandle');

    % Get signal name before deleting
    signalName = get_param(line, 'Name');

    % Delete line (multiple line segments in the case of branching)
    for i = 1:length(dstPort)
      delete_line(address, srcPort, dstPort(i));
    end

    % -- Add new goto/from blocks without using existing names --
    % First, check that block library is loaded
    %%%%% FCA %%%%%
    %if ~bdIsLoaded('ChryslerLib')
    %    load_system('ChryslerLib');
    %end
    %%%%% GENERAL %%%%%
    if ~bdIsLoaded('simulink')
        load_system('simulink');
    end

    numOfFroms = length(dstPort);   % To avoid recomputing

    % Add goto block
    num = 0;
    err = true;
    while err
        err = false;
        try
            %%%%% GENERAL %%%%%
            newGoto = add_block('simulink/Signal Routing/Goto', [address '/Goto' num2str(num)]);
            %%%%% FCA %%%%%
            %newGoto = add_block('ChryslerLib/Signals/Goto', [address '/Goto' num2str(num)]);
        catch ME
            % If a block already exists with the same name
            if strcmp(ME.identifier, 'Simulink:Commands:AddBlockCantAdd')
                num = num + 1;  % Try next name
                err = true;
            end
        end
    end

    % Add from block(s)
    num = 0;
    for j = 1:numOfFroms
        err = true;
        while err
            err = false;
            try
                %%%%% GENERAL %%%%%
                newFrom(j) = add_block('simulink/Signal Routing/From', [address '/From' num2str(num+j-1)]);
                %%%%% FCA %%%%%
                %newFrom(j) = add_block('ChryslerLib/Signals/From', [address '/From' num2str(num+j-1)]);
            catch ME
                if strcmp(ME.identifier, 'Simulink:Commands:AddBlockCantAdd')
                    num = num + 1;  % Try next name
                    err = true;
                end
            end
        end
    end

    % Set block names
    set_param(newGoto, 'GotoTag', tag);
    for k = 1:numOfFroms
        set_param(newFrom(k), 'GotoTag', tag);
    end

    % Reposition blocks
    moveToPort(newGoto, srcPort, 0);
    for l = 1:numOfFroms
        moveToPort(newFrom(l), dstPort(l), 1);
    end

    % Resize blocks to accomodate tags
    RESIZE_BLOCK = getLine2GotoConfig('resize_block', 1);
    if RESIZE_BLOCK
        resizeGotoFrom(newGoto);
        for m = 1:numOfFroms
            resizeGotoFrom(newFrom(m));
        end
    end

    % Connect blocks with signal lines
    % Note: Should be done after block placement is done
    newGotoPort = get_param(newGoto, 'PortHandles');
    newLine = add_line(address, srcPort, newGotoPort.Inport, 'autorouting', 'on');

    FROM_SIGNAL_NAMING = getLine2GotoConfig('from_signal_naming', 0);
    FROM_SIGNAL_PROPAGATION = getLine2GotoConfig('from_signal_propagation', 0);

    for n = 1:numOfFroms
        newFromPort = get_param(newFrom(n), 'PortHandles');
        newLine = add_line(address, newFromPort.Outport, dstPort(n), 'autorouting', 'on');
        if FROM_SIGNAL_NAMING
            set_param(newLine, 'Name', signalName);
        end
        if FROM_SIGNAL_PROPAGATION
            set(newLine, 'SignalPropagation', 'on');
        end
    end
end

function moveToPort(block, port, onLeft)
%% MOVETOPORT Move a block to the right/left of a block port.
%
%   Inputs:
%       block       Handle of the block to be moved.
%       port        Handle of the port to align the block with.
%       onLeft      Boolean indicating if the block is to be on the right(0) or
%                   left(1) of the port.
%
%   Outputs:
%       N/A

    % Get parameters from configuration file
    BLOCK_OFFSET = getLine2GotoConfig('block_offset', 25);

    % Get block's current position
    blockPosition = get_param(block, 'Position');

    % Get port position
    portPosition = get_param(port, 'Position');

    % Compute block dimensions which need to be maintained during the move
    blockWidth = blockPosition(4) - blockPosition(2);
    blockLength = blockPosition(3) - blockPosition(1);

    % Compute x dimensions
    if ~onLeft
        newBlockPosition(1) = portPosition(1) + BLOCK_OFFSET;  % Left
        newBlockPosition(3) = portPosition(1) + blockLength + BLOCK_OFFSET;    % Right
    else
        newBlockPosition(1) = portPosition(1) - blockLength - BLOCK_OFFSET;    % Left
        newBlockPosition(3) = portPosition(1) - BLOCK_OFFSET;  % Right
    end

    % Compute y dimensions
    newBlockPosition(2) = portPosition(2) - (blockWidth/2);    % Top
    newBlockPosition(4) = portPosition(2) + blockWidth - (blockWidth/2);   % Bottom

    set_param(block, 'Position', newBlockPosition);
end

function resizeGotoFrom(block)
%% RESIZEGOTOFROM Resize a goto/from block to fit its tag.
%
%   Inputs:
%       block       Handle of the block to be resized.
%
%   Outputs:
%       N/A

    % Get parameters from configuration file
    STATIC_RESIZE = getLine2GotoConfig('static_resize', 1);
    STATIC_LENGTH = getLine2GotoConfig('static_length', 140);
    PX_PER_LETTER = getLine2GotoConfig('px_per_letter', 9);

    % Get the block information
    origBlockPosition = get_param(block, 'Position');
    origLength = origBlockPosition(3) - origBlockPosition(1);
    tag = get_param(block, 'GotoTag');

    newBlockPosition = origBlockPosition;
    newLength = origLength;

    if STATIC_RESIZE
        newLength = STATIC_LENGTH;
    else % DYNAMIC
        newLength = length(tag) * PX_PER_LETTER;
        if newLength < origLength % Don't make it smaller
            newLength = origLength;
        end
    end

    if strcmp(get_param(block, 'BlockType'), 'Goto')
        newBlockPosition(3) = (origBlockPosition(3) - origLength) + newLength;
    elseif strcmp(get_param(block, 'BlockType'), 'From')
        newBlockPosition(1) = (origBlockPosition(1) + origLength) - newLength;
    else
        warning('Attempted to resize an unsupported block.');
    end

    set_param(block, 'Position', newBlockPosition);
end