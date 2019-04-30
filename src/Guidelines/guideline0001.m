function [blocks, location] = guideline0001(model)
% GUIDELINE0001 Check that a model complies to Guideline 1. Return blocks 
%   that are not in compliance. Blocks are not in compliance if they are not
%   placed in the lowest possible hierarchical position that is a common parent
%   amoung its callers.
%
%   Inputs:
%       model    Simulink model name.
%
%   Outputs:
%       blocks   Simulink Function block fullnames.
%       location Proposed correct location.

    % Get the model
    try
        model = bdroot(model);
    catch % not loaded
        error(['Model ''' model ''' is not loaded.']);
    end

    fcns = find_system(model, 'BlockType', 'SubSystem');
    fcns = fcns(isSimulinkFcn(fcns) == 1);
    currentLocation = get_param(fcns, 'Parent');
    
    blocks = {};
    location = {};
    
    for i = 1:length(fcns)
        % Find corresponding Function callers
        callers = findCallers(fcns{i});
        % Find lowest common parent of callers
        idealLocation = commonParents(callers);
        
        % If subsystem is not placed in this spot, it can be placed lower or higher
        % than its current position 
        if ~strcmp(idealLocation, currentLocation)
            blocks{end+1} = fcns{i};
            location{end+1} = idealLocation;
        end
    end
end