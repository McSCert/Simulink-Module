function path1 = commonParent(sys1, sys2)
% COMMONPARENT Find the first (top-most) common parent between two subsystems or blocks.
%
%   Inputs:
%       sys1    Subsystem path name or handle.
%       sys2    Subsystem path name or handle.
%
%   Outputs:
%       path    Path to common parent.

    % If handles, change to paths for later string operations
    if isnumeric(sys1)
        sys1 = getfullname(sys1);
    end
    if isnumeric(sys2)
        sys2 = getfullname(sys2);
    end
    
    % Compare each element in the path, starting at the root
    path1 = strsplit(sys1, '/');
    path2 = strsplit(sys2, '/');
    commonPath = '';
    for i = 1:min(length(path1), length(path2))
        if isempty(commonPath)
            newCommonPath = path1{i};
        else
            newCommonPath = [commonPath '/' path1{i}];
        end
        
        if  strcmp(path1{i}, path2{i})
            commonPath =  newCommonPath;
        else
            break;
        end
    end
    path1 = commonPath;
end