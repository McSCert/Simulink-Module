function blocks = guideline0002(model)
% GUIDELINE0002 Check that a model complies to guideline MJ_0002. Return blocks  
%   that are not in compliance. Blocks are not in compliance if they have global
%   visibility, and are not used outside of the model. It is not possible to
%   check is all models (loaded and unloaded) use the function, which would
%   justify the global visibility. Therefore, we err on the side of caution, and
%   return all blocks with global visibility.
%
%   Inputs:
%       model   Simulink model name.
%
%   Outputs:
%       blocks  Simulink function block names.

    blocks = find_system(model, 'BlockType', 'SubSystem');
    blocks = blocks(isSimulinkFcn(blocks) == 1);
    
    visibility = cell(size(blocks));
    
    for i = 1:length(blocks)
        % 1) Get Function Visibility parameter
        triggerPort = find_system(blocks{i}, 'SearchDepth', 1, 'FollowLinks', 'on', ...
            'BlockType', 'TriggerPort', ...
            'TriggerType', 'function-call');
        try
            visibility{i} = get_param(triggerPort{1}, 'FunctionVisibility');
        catch
            % Either not a Simulink Function, or earlier versions of
            % Simulink Functions (e.g. 2014b) do not have this parameter
            visibility{i} = '';
            continue
        end
    end
    
    globalVisibility = strcmp(visibility, 'global') == 1;
    blocks = blocks(globalVisibility);
end