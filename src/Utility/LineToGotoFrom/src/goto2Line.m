function goto2Line(address, blocks)
% GOTO2LINE Convert selected local goto/from block connections into signal lines.
%
%   Inputs:
%       address     Simulink system name or path.
%       blocks      Cell array of goto/from block path names.
%
%   Outputs:
%       N/A
%
%   Examples:
%       goto2Line(gcs, gcbs)        
%           Converts the currently selected blocks in the current Simulink
%           system into line connections.
%
%       goto2Line(gcs, gcb)       
%           Converts the currently selected block in the current Simulink
%           system into a line connection.

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
            error('Model is locked.');
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

    % Check blocks argument
    % 1) Check that each block is a goto block
    % 2) Check that its visibility is local
    tagsToConnect = {};
    % For each selected block
    for x = 1:length(blocks)
        % Get its goto tag
        try
            tag = get_param(blocks{x}, 'GotoTag');
        catch ME
            if strcmp(ME.identifier, 'Simulink:Commands:ParamUnknown')
                warning('A selected block is not a goto/from.');
            else % Block is a char array (single block)
                error('Invalid block.');
            end
        end
        % Check that visibility of goto/from is local
        if strcmp(get_param(blocks{x}, 'TagVisibility'), 'local')
            tagsToConnect{end+1} = tag; % Append to list
        else
            warning(['Selected goto/from "' blocks{x} '" does not have a local scope.']);
        end
    end

    % Filter out multiples of tags
    % e.g. if multiple froms of the same tag were selected
    % e.g. if both goto/from blocks in pair are selected
    tagsToConnect = unique(tagsToConnect);  % Tags of blocks to connect

    % For each tag
    for y = 1:length(tagsToConnect)
        % Get the goto corresponding to the tag
        gotos = find_system(address, 'SearchDepth', 1, 'BlockType', 'Goto', 'GotoTag', tagsToConnect{y});
        if isempty(gotos)
            warning(['From block "', tagsToConnect{y} , ...
                '" has no local matching goto block.']);
            continue
        elseif length(gotos) > 1
            msg = ['Multiple goto blocks with tag "', tagsToConnect{y} , ...
                '" exist. Some blocks may be left unconnected.'];
            warning(msg);
        end

        % Get the from(s) corresponding to the tag
        froms = find_system(address, 'SearchDepth', 1, 'BlockType', 'From', 'GotoTag', tagsToConnect{y});
        if isempty(froms)
            warning(['From block "', tagsToConnect{y} , ...
                '" has no local matching goto block.']);
            continue
        end

        % Find what block the goto is connected to
        connections = get_param(gotos, 'PortConnectivity');
        gotoSrcBlock = connections{1}.SrcBlock;
        gotoSrcPort = connections{1}.SrcPort;

        % Find which port needs to be connected with a line
        lineStartPortHandle = get_param(gotoSrcBlock, 'PortHandles');
        lineStartPortHandle = lineStartPortHandle.Outport(gotoSrcPort + 1);

        % Find endpoint of the signal line which needs deleting
        gotoPortHandle = get_param(gotos, 'PortHandles');
        gotoPortHandle = gotoPortHandle{1}.Inport(1);

        % Delete signal line and goto
        deletedLineName = get_param(lineStartPortHandle, 'Name'); % Save for later
        delete_line(address, lineStartPortHandle, gotoPortHandle)
        delete_block(gotos);

        % For each from
        for z = 1:length(froms)

            % Get the from's port handle
            fromPortHandle = get_param(froms{z}, 'PortHandles');
            fromPortHandle = fromPortHandle.Outport;

            % Find what block ports the from is connected to
            fromLineHandle = get_param(fromPortHandle, 'Line');

            % If the from is not connected to anything, just delete it
            if ~ishandle(fromLineHandle)
                delete_block(froms{z})
                continue
            else
                % Otherwise, find what ports the line is connected to
                fromDstPortHandle = get_param(fromLineHandle, 'Dstporthandle');
            end

            % Delete signal lines and from
            for b = 1:length(fromDstPortHandle)
                delete_line(address, fromPortHandle, fromDstPortHandle(b));
            end
            delete_block(froms{z})

            % Connect block ports with line
            LINE_ROUTING = getLine2GotoConfig('line_routing', 1);
            if LINE_ROUTING
                for c = 1:length(fromDstPortHandle)
                    if ishandle(lineStartPortHandle) && ishandle(fromDstPortHandle(c))
                        a = add_line(address, lineStartPortHandle, fromDstPortHandle(c), 'autorouting', 'on');
                    end
                end
            else
                for d = 1:length(fromDstPortHandle)
                    a = add_line(address, lineStartPortHandle, fromDstPortHandle(d));
                end
            end
        end
    end
end