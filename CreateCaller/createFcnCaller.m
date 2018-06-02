function caller = createFcnCaller(sys, blockPath, varargin)
% CREATECALLER Create a function caller block for a Simulink function,
%   anywhere in the model or parent hierarchy, with the prototype and the input/output argument
%   specifications populated.
%
%   Inputs:
%       sys         Subsystem in which to place the new caller.
%       blockName   Simulink Function block path name.
%       varargin{1} Simulink Function prototype. [Optional]
%
%   Outputs:
%       caller     Handle of Function Caller block.
%
%   Example:
%       createFcnCaller(gcs, 'model1/Simulink Function')

    callerNum = 1;
    loadedSys = false;

    % Get the model
    try
        blockSys = bdroot(blockPath);
    catch % not loaded
            i = regexp(blockPath, '/', 'once');
            blockSys = blockPath(1:i-1);
            load_system(blockSys);
            loadedSys = true;
    end

    % Determine Simulink Function block parameters
    % 1) Prototype
    if nargin < 2
        prototype = createPrototype(sys, blockPath);
    else
        prototype = varargin{1};
    end

    % 2) InputArgumentSpecifications, OutputArgumentSpecifications
    argsIn = find_system(blockPath, 'SearchDepth', 1, 'BlockType', 'ArgIn');
    argsOut = find_system(blockPath, 'SearchDepth', 1, 'BlockType', 'ArgOut');

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

    % Create caller block (with a unique name)
    blockCreated = false;
    while ~blockCreated
        try
            caller = add_block('simulink/User-Defined Functions/Function Caller', ...
                [sys '/Function Caller' num2str(callerNum)], ...
                'FunctionPrototype', prototype, ...
                'InputArgumentSpecifications', argsInSpec, ...
                'OutputArgumentSpecifications', argsOutSpec);
            callerNum = callerNum + 1;
            blockCreated = true;
        catch ME
            if contains2(ME.message, 'identifier') % Identifier is not valid
                rethrow(ME);
            else % Block with that name exists already
                callerNum = callerNum + 1;
            end
        end
    end

    %  Resize block width
    pos = get_param(caller, 'Position');
    [~, newWidth] = blockStringDims(caller, prototype);
    origWidth = pos(3) - pos(1);
    newPos = pos(1) + newWidth;
    if newWidth > origWidth
        pos(3) = newPos;
    end
    set_param(caller, 'Position', pos);

    % Close system
    if loadedSys
        close_system(blockSys);
    end
end