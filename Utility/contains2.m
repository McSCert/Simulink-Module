function b = contains2(str, pattern)
% CONTAINS2 Returns true if pattern is found in text.
%   Required for backwards compatabililty as Matlab's built-in function was
%   not introduced until R2016b.

    try
        b = contains(str, pattern);
    catch
        b = cell2mat(strfind(str, pattern));
    end
end