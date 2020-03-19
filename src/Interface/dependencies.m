function dependencies(sys)
% DEPENDENCIES List the model dependencies in the Command Window.
%
%   Inputs:
%       sys     Model model
%
%   Outputs:
%       N/A

    sys = bdroot(sys);
    
    % Initialize counts
    mr_n = 0;
    ll_n = 0;
    dd_n = 0;

    %% 1) Model References
    mr = find_system(sys, 'BlockType', 'ModelReference', 'Commented', 'off');
    % Remove non-unique based on ModelFile
    modelname = get_param(mr, 'ModelFile');
    [~, idx] = unique(modelname);
    mr = mr(idx);
    if isempty(mr)
        mr = {'N/A'};
    else
        mr = replaceNewline(mr);
        mr_n = length(mr);
    end

    %% 2) Linked Library Blocks
    % Find all unique, linked blocks (but don't go into the linked block)
    ll = find_system(sys, 'LinkStatus', 'resolved', 'Commented', 'off');
    % Remove non-unique based on ReferenceBlock
    %libraryname = get_param(ll, 'ReferenceBlock');
    %[~, idx] = unique(libraryname);
    %ll = ll(idx);
    if isempty(ll)
        ll = {'N/A'};
    else
        ll = replaceNewline(ll);
        ll_n = length(ll);
    end

    %% 3) Data Dictionary
    try
        dd = get_param(sys, 'DataDictionary');
        if isempty(dd)
            dd = 'N/A';
        else
            dd = replaceNewline(dd);
            dd_n = length(dd);
        end
    catch % Parameter does not exist in earlier versions
        dd = 'N/A';
    end

    %% Print
    fprintf('Model References (%d)\n', mr_n);
    fprintf('------\n');
    for i = 1:length(mr)
        fprintf('%s\n', mr{i});
    end

    fprintf('\nLibrary Links (%d)\n', ll_n);
    fprintf('------\n');
    for i = 1:length(ll)
        fprintf('%s\n', ll{i});
    end

    fprintf('\nData Dictionaries (%d)\n', dd_n);
    fprintf('------\n');
        fprintf('%s\n', dd);
end