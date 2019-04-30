function [blocks, shadows] = guideline0003(model)
% GUIDELINE003 Check that a model complies to Guideline 3. Return blocks 
%   that are not in compliance. Blocks are not in compliance if they are in the  
%   scope of one or more function blocks with the same name and parameters.
%
%   Inputs:
%       model   Simulink model name.
%
%   Outputs:
%       blocks  Simulink Function block fullnames.
%       shadows Simulink Function block fullnames.

    % Get the model
    try
        model = bdroot(model);
    catch % not loaded
        error(['Model ''' model ''' is not loaded.']);
    end
    
    fcns = find_system(model, 'BlockType', 'SubSystem');
    fcns = fcns(isSimulinkFcn(fcns) == 1);
    
    blocks = {};
    shadows = {};
    
    % Note: 
    % - Functions with the same name in same subsystem (Error)
    % - Two global functions with same name in different subsystems (Error)
        
    for i = 1:length(fcns)
        % Get all Simulink functions that are in scope
        [inscopeFcns, inscopePrototyes] = getCallableFunctions(get_param(fcns{i}, 'Parent'));
        
        % Remove itself
        i_idx = find(strcmp(inscopeFcns, fcns{i}));
        inscopeFcns(i_idx) = '';
        inscopePrototyes(i_idx) = '';
        
        % Get function names
        %inscopeNames = getPrototypeName(inscopePrototyes);
        %n = getPrototypeName(getPrototype(fcns{i}));
        
        % Check if there are any function prototype that are the same
        found = strfind(inscopePrototyes, getPrototype(fcns{i}));
        if ~iscell(found)
            found = {found};
        end
        idx = find(not(cellfun('isempty', found)));
        if ~isempty(idx) % If yes, add to list of shadowing functions
            blocks{end+1} = fcns{i};
            shadows{end+1} = inscopeFcns(idx);
        end
    end 
end
