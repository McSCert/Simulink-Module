function [indim, outdim] = getFcnArgsDim(fcn)
% GETFCNARGSDIM Get the dimensions of Simulink Function input/output arguments, 
%   i.e., any ArgIn or ArgOut blocks.
%
%   Inputs:
%       fcn        Simulink function path name or handle.
%
%   Outputs:
%       intype     Data types of ArgIn blocks.
%       outtype    Data types of ArgOut blocks.

    fcn = inputToCell(fcn);
    
    argsIn = find_system(fcn, 'SearchDepth', 1, 'BlockType', 'ArgIn');
    argsOut = find_system(fcn, 'SearchDepth', 1, 'BlockType', 'ArgOut');

    indim = cell(size(argsIn));
    outdim = cell(size(argsOut));
    
    for i = 1:length(argsIn)
        indim{i} = get_param(argsIn(i), 'PortDimensions');
    end

    for j = 1:length(argsOut)
        outdim{j} = get_param(argsOut(j), 'PortDimensions');
    end 
end