function value = getInput(name, args)
% GETINPUT Get a specific input from a list of arguments from varargin.
%
%   Inputs:
%       name    Char array of the input name.
%       args    Cell array of all arguments pass in via varargin.
%
%   Outputs:
%       value   Value of the input specified by the input name.
%
%   Example:
%       >> getInput('BlockType', {'Name', 'Example', 'BlockType', 'SubSystem'})
%           ans =
%               'SubSystem'
%
%       >> getInput('otherFiles', {'imageFile', 'test.png', 'otherFiles', {'file1', 'file2'}})
%           ans =
%               1�2 cell array
%                   {'file1'}    {'file2'}

    if iscellcell(args)
        paramNames = args(1:2:end);
        idx = find(strcmp(paramNames, name));
        exists = ~isempty(idx);
    else
        args2 = cellfun(@num2str, args, 'un', 0);
        paramNames = args2(1:2:end);
        [exists, idx] = ismember(name, paramNames);
    end

    idx = idx*2;

    if exists && length(args) >= idx
        value = args{idx+1};
    else
        value = [];
    end
end

function b = iscellcell(c)
% ISCELLCELL Whether the input is a cell array of cells.
%
%   Example:
%       iscellcell({'a'})
%           ans = 0
%
%       iscellcell({{'a'}, {'b'}})
%           ans = 1

    b = false;
    if iscell(c)
        for i = 1:length(c)
            if iscell(c{i})
                b = true;
            end
        end
    end
end