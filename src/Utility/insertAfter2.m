function s = insertAfter2(str, pos, text)
% INSERTAFTER2 Insert substring after specified position.
%   Required for backwards compatabililty as Matlab's built-in function was
%   not introduced until R2016b.
    try
        s = insertAfter(str, pos, text);
    catch
        p = strfind(str, pos);
        s = [str(1:p+1) text str(p+2:end)];
    end
end