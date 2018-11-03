function value = getInput(name, args)
 % GETINPUT Get a specific input from a list of arguments from varargin.
 %
 %	Inputs:
 %		name 	Character array of the input name.
 %		args 	Cell array of all arguments as passed in via varargin.
 %
 %	Outputs:
 %		value 	Vale of the input specific by the input name.
 %
 %	Example:
 %		>> getInput('BlockType', {'Name', 'Controller1', 'BlockType', 'SubSystem'})
 %			ans =
 %				SubSystem

    if iscellcell(args)
    	idx = find(strcmp(args, name));
    	exists = ~isempty(idx);
    else
    	[exists, idx] = ismember(name, args);
    end

    if exists && length(args) > idx
        value = args(idx + 1);
    else
        value = [];
    end
end