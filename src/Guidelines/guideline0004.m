function blocks = guideline0004(model)
% GUIDELINE0004 Check that a model complies to guideline MJ_0004. Return blocks 
%   that are not in compliance. Blocks are not in compliance if they interact
%   with the base workspace (e.g., To Workspace, From File, etc.)
%
%   Inputs:
%       model   Simulink model name.
%
%   Outputs:
%       blocks  Block fullnames.

    % Get the model
    try
        model = bdroot(model);
    catch % not loaded
        error(['Model ''' model ''' is not loaded.']);
    end
    
    ff = find_system(model, 'BlockType', 'FromFile', 'Commented', 'off');
    fs = find_system(model, 'BlockType', 'FromSpreadsheet', 'Commented', 'off');
    fw = find_system(model, 'BlockType', 'FromWorkspace', 'Commented', 'off');
    tf = find_system(model, 'BlockType', 'ToFile', 'Commented', 'off');
    tw = find_system(model, 'BlockType', 'ToWorkspace', 'Commented', 'off');
    
    % Global data stores in the base workspace are not be allowed. 
    % Data Dictionary and model workspace are OK.
    dswr = [find_system(model, 'BlockType', 'DataStoreWrite', 'Commented', 'off'); ...
                find_system(model, 'BlockType', 'DataStoreRead', 'Commented', 'off');];
    ds = {};
    for i = 1:length(dswr)
        [isGlobal, ~, location] = isGlobalDataStore(dswr{i});
        if isGlobal && strcmp(location, 'base')
            ds{end+1,1} = dswr{i};
        end
    end
    
    blocks = vertcat(ff, fs, fw, tf, tw, ds);
end