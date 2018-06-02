function prototype = getPrototype(fcn)
% GETPROTOTYPE Find the prototype for a Simulink function.
%
%   Inputs:
%       fcn        Simulink function path names or handles.
%
%   Outputs:
%        prototype Simulink functions prototypes.

    triggerPort = find_system(fcn, 'SearchDepth', 1, 'FollowLinks', 'on', ...
        'BlockType', 'TriggerPort', ...
        'TriggerType', 'function-call');
    prototype = get_param(triggerPort, 'FunctionPrototype');
end