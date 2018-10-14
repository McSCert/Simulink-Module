function s = replaceNewline(string)
    s =  regexprep(string, '[\n\r]+', ' ');
end