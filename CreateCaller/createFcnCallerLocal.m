function callers = createFcnCallerLocal(blocks)
% CREATECALLERLOCAL Create a function caller block for a Simulink function, in
%   the same subystem, with the prototype and the input/output argument specifications populated.
%
%   Inputs:
%       blocks      Simulink Function block path names or handles.
%
%   Outputs:
%       callers     Handles of Function Caller blocks.
%
%   Example:
%       createFcnCallerLocal(gcb)

    % Handle input
    blocks = inputToCell(blocks);

    % Allocate array for new block handles
    callers = zeros(1, length(blocks));

    callerNum = 1;
    for i = 1:length(blocks)
        if isSimulinkFcn(blocks{i})

            % Determine caller block parameters
            % 1) Prototype
            % Caller is in the same system, so don't worry about qualification
            triggerPort = find_system(blocks{i}, 'SearchDepth', 1,'FollowLinks', 'on', ...
                'BlockType', 'TriggerPort', ...
                'TriggerType', 'function-call');
            prototype = get_param(triggerPort, 'FunctionPrototype');

            % 2) InputArgumentSpecifications, OutputArgumentSpecifications
            argsIn = find_system(blocks{i}, 'SearchDepth', 1, 'BlockType', 'ArgIn');
            argsOut = find_system(blocks{i}, 'SearchDepth', 1, 'BlockType', 'ArgOut');
            argsInSpec = '';
            for a = 1:length(argsIn)
                type = get_param(argsIn{a}, 'OutDataTypeStr');
                dim = get_param(argsIn{a}, 'PortDimensions');
                if isempty(argsInSpec)
                    argsInSpec = [type '(' dim ')'];
                else
                    argsInSpec = [argsInSpec ', ' type '(' dim ')'];
                end
            end
            argsOutSpec = '';
            for b = 1:length(argsOut)
                type = get_param(argsOut{b}, 'OutDataTypeStr');
                dim = get_param(argsOut{b}, 'PortDimensions');
                if isempty(argsOutSpec)
                    argsOutSpec = [type '(' dim ')'];
                else
                    argsOutSpec = [argsOutSpec ', ' type '(' dim ')'];
                end
            end

            % 3) Position
            position = get_param(blocks{i}, 'Position');
            fcnBlockH = position(4) - position(2);
            bufferH = 10;
            if strcmpi(get_param(blocks{i}, 'ShowName'), 'on')
                [fcnNameH, ~] = blockStringDims(blocks{i}, get_param(blocks{i}, 'Name'));
                position(2) = position(4) + fcnNameH + bufferH;
                position(4) = position(4) + fcnBlockH + fcnNameH + bufferH;
            else
                position(2) = position(4) +  bufferH;
                position(4) = position(4) + fcnBlockH + bufferH;
            end

            % Create caller block (with a unique name)
            blockCreated = false;
            while ~blockCreated
                try
                    callers(i) = add_block('simulink/User-Defined Functions/Function Caller', ...
                        [get_param(blocks{i}, 'Parent') '/Function Caller' num2str(callerNum)], ...
                        'Position', position, ...
                        'FunctionPrototype', prototype{1}, ...
                        'InputArgumentSpecifications', argsInSpec, ...
                        'OutputArgumentSpecifications', argsOutSpec);
                    callerNum = callerNum + 1;
                    blockCreated = true;
                catch
                    callerNum = callerNum + 1;
                end
            end
        end
    end
end