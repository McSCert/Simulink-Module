function val = getLine2GotoConfig(parameter, default)
% GETLINE2GOTOCONFIG Get a parameter from the tool configuration file.
%
%   Inputs:
%       parameter   Get the value of this paramter.
%       default     Value if parameter is not found.
%
%   Outputs:
%       val         Value of the parameter.

    val = default;
    filePath = mfilename('fullpath');
    name = mfilename;
    filePath = filePath(1:end-length(name));
    fileName = [filePath 'config.txt'];
    file = fopen(fileName);
    line = fgetl(file);

    paramPattern = ['^' parameter  ':[ ]*[0-9]+'];

    while ischar(line)
        match = regexp(line, paramPattern, 'match');
        if ~isempty(match)
            val = match{1}; % Get first occurrance
            val = str2num(strrep(val, [parameter ':'], '')); % Strip parameter
            break
        end
        line = fgetl(file);
    end
    fclose(file);
end