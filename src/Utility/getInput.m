function value = getInput(name, args)
    
    [exists, idx] = ismember(name, args);
    if exists && length(args) > idx
        value = args(idx + 1);
    else
        value = [];
    end
end