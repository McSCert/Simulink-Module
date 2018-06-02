function b = startsWith2(str, pattern)
% STARTSWITH2 Returns true if text starts with pattern.
%   Required for backwards compatabililty as Matlab's built-in function was
%   not introduced until R2016b.

    try
        b = startsWith(str, pattern);
    catch
        b = regexp(str, ['^' pattern '.*']);
    end
end
