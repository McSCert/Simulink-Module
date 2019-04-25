function caller = createFcnCaller(sys, blockPath, varargin)
% CREATEFCNCALLER Create a function caller block for a Simulink function, 
%   anywhere in the model or parent hierarchy, with the prototype and the input/output  
%   argument specifications populated.
%
%   Inputs:
%       sys         Subsystem in which to place the new caller.
%       blockPath   Simulink Function block path name.
%       varargin{1} Simulink Function prototype. [Optional]
%
%   Outputs:
%       caller      Handle of Function Caller block.
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
    if nargin < 3
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
                'FunctionPrototype', prototype);
            callerNum = callerNum + 1;
            blockCreated = true;
        catch ME
           if strcmp(ME.identifier, 'Simulink:Commands:AddBlockCantAdd')
                callerNum = callerNum + 1;
            else
                rethrow(ME)
            end
        end
    end
    % Try setting the input and output arguments
    triggerPort = find_system(blockPath, 'SearchDepth', 1,'FollowLinks', 'on', ...
        'BlockType', 'TriggerPort', ...
        'TriggerType', 'function-call');
    try
        set_param(caller, 'InputArgumentSpecifications', argsInSpec)
    catch
        [~, fcnname, ~] = fileparts(triggerPort{:});
        warndlg(['Error creating Function Caller for ''' fcnname ''' because an input argument is a user defined data type. ', ...
            'Argument data type must be built-in data types. ', ...
            'User-defined data types, including Bus, Fixed-point, Enumerations, and Alias types, may be provided with a Simulink.Parameter object.'], ...
            'Input Argument Error');
    end
    try
        set_param(caller, 'OutputArgumentSpecifications', argsOutSpec)
    catch
        [~, fcnname, ~] = fileparts(triggerPort{:});
        warndlg(['Error creating Function Caller for ''' fcnname ''' because an output argument is a user defined data type. ', ...
            'Argument data type must be built-in data types. ', ...
            'User-defined data types, including Bus, Fixed-point, Enumerations, and Alias types, may be provided with a Simulink.Parameter object.'], ...
            'Output Argument Error');
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