function dependencies(sys)
% DEPENDENCIES List the model dependencies in the Command Window.
%
%   Inputs:
%       sys     Model model
%
%   Outputs:
%       N/A
%

    sys = bdroot(sys);

    %% 1) Model References
    mr = find_system(sys, 'BlockType', 'ModelReference', 'Commented', 'off');
    % Remove non-unique based on ModelFile
    modelname = get_param(mr, 'ModelFile');
    [~, idx] = unique(modelname);
    mr = mr(idx);
    if isempty(mr)
        mr = {'N/A'};
    end

    %% 2) Linked Library Blocks
    ll = find_system(sys, 'LinkStatus', 'resolved', 'Commented', 'off');
    % Remove non-unique based on ReferenceBlock
    libraryname = get_param(ll, 'ReferenceBlock');
    [~, idx] = unique(libraryname);
    ll = ll(idx);
    if isempty(ll)
        ll = {'N/A'};
    end

    %% 3) Data Dictionary
    try
        dd = get_param(sys, 'DataDictionary');
        if isempty(dd)
            dd = 'N/A';
        end
    catch % Parameter does not exist in earlier versions
        dd = 'N/A';
    end

    %% Print
    fprintf('Model References\n');
    fprintf('------\n');
    for i = 1:length(mr)
        fprintf('%s\n', mr{i});
    end

    fprintf('\nLibrary Links\n');
    fprintf('------\n');
    for i = 1:length(ll)
        fprintf('%s\n', ll{i});
    end

    fprintf('\nData Dictionaries\n');
    fprintf('------\n');
        fprintf('%s\n', dd);
end