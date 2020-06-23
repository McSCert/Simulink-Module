function goodName = isGoodSimFcnName(subsystem, simulinkFcnName)
% isGoodSimFcnName          Checks to see if a Simulink Function name is the
%                           same as any other Simulink Functions in scope at
%                           the current subsystem level
% Inputs:
%   subsystem               Path of a subsystem where a Simulink Function
%                           will be added
%   simulinkFcnName         Name of the Simulink Function to be added
%
% Outputs:
%   goodName                Name can be used(1) or not(0)
%
% Example:
%   isGoodSimFcnName('SubSystem_Name', 'SimFcnName')
%
%           ans = 1

    % Get callable Simulink Functions at the current scope
    [~, prototype] = getCallableFunctions(subsystem);
    
    % Get the prototype names
    prototypeNames = getPrototypeName(prototype);
    
    % Make sure the prototype name is a cell
    if ~iscell(prototypeNames)
        prototypeNames = {prototypeNames};
    end
    
    result = zeros(1, length(prototypeNames));
    
    % Loop through each prototype name
    for name = 1:length(prototypeNames)
        % Compare to the input name
        result(name) = ~strcmp(simulinkFcnName, prototypeNames{name});
    end
    % Return true if none of the prototype names are the same as the input name
    goodName = all(result);
end