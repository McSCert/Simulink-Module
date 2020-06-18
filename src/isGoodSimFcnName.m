function goodName = isGoodSimFcnName(subsystem, simulinkFcnName)
% isGoodSimFcnName          Checks to see if a Simulink-fcn name clashes with
%                           any other Simulink-fcns in scope at the current
%                           subsystem level
% Inputs:
%   subsystem               Path of a subsystem where the fcn will be added
%   simulinkFcnName         Name of the Simulink-function to be created
%
% Outputs:
%   goodName                Name can be used(1) or not(0)
%
% Example:
%   isGoodSimFcnName('SubSystem_Name','SimFcnName')
%
%           ans = 1

    % Get callable Simulink-functions at the current scope
    [~, prototype] = getCallableFunctions(subsystem);
    
    result = zeros(1, length(prototype));
    
    splitEquals = split(prototype, '= ');
    % Loop through each fcn name and compare to the input name
    for fcn = 1:length(prototype)
        if length(prototype) == 1
            splitHierarchy = split(splitEquals{end}, '.');
        else
            splitHierarchy = split(splitEquals{fcn,end}, '.');
        end
        tmp = split(splitHierarchy{end}, '(');
        result(fcn) = ~strcmp(simulinkFcnName, tmp{1});
    end
    % Return true if none of the fcn names are the same as the input name
    goodName = all(result);
end