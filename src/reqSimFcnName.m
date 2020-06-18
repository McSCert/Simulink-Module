function simulinkFcnName = reqSimFcnName()
% getSimFcnName             Prompts the user for an input Simulink Function name
%                           until a name is entered which is not the same as
%                           another Simulink Function in scope
%                                                 
% Inputs:
%   N/A
%
% Outputs:
%   simulinkFcnName         Char array which represents a Simulink Function name
%
% Example:
%   simulinkFcnName = getSimFcnName()
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
        % Checks to see if the name shadows other names in scope
        if isGoodSimFcnName(gcs,inputName{1})
            break
        else
            waitfor(msgbox([inputName{1}, ...
                    ' is already used as a Simulink Function in scope.', ...
                     newline, newline, 'Please enter a new name.'], dlgtitle));
        end
    end
    simulinkFcnName = inputName{1};
end