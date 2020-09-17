function simulinkFcnName = reqSimFcnName()
% REQSIMFCNNAME Prompt the user to input a Simulink Function name until a
%   name is entered which is not the same as another Simulink Function in scope.
%                                                 
%   Inputs:
%       N/A
%
%   Outputs:
%       simulinkFcnName  Char array representing a Simulink Function name.
%
%	Example:
%       simulinkFcnName = getSimFcnName()
%
%           ans = 'Function_Name'

    %% Dialog Box Parameters
    prompt = 'Enter a name for the Simulink Function: ';
    dlgtitle = 'Convert Subsystem';
    dims = [1 50];
    definput = {'f'};
            
    %% Checking Input
    % Loop until the input name is acceptable
    while 1
        inputName = inputdlg(prompt, dlgtitle, dims, definput);
        % Check to see if the name shadows other names in scope
        if isGoodSimFcnName(gcs, inputName{1})
            break
        else
            waitfor(msgbox([inputName{1}, ...
                ' is already used as a Simulink Function in scope.', ...
                char(10), 'Please enter a new name.'], dlgtitle));
        end
    end
    simulinkFcnName = inputName{1};
end