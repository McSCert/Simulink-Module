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
    
    % TO REVISIT: Global data stores in the base workspace should not be allowed. 
    % DD and model workspace are ok
    %dsw = find_system(model, 'BlockType', 'DataStoreWrite', 'Commented', 'off');
    %dsr = find_system(model, 'BlockType', 'DataStoreRead', 'Commented', 'off');
    
    blocks = vertcat(ff, fs, fw, tf, tw);
end