function [intype, outtype] = getFcnArgsType(fcn)
% GETFCNARGSTYPE Get the data types of Simulink Function input/output arguments, 
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

    intype = cell(size(argsIn));
    outtype = cell(size(argsOut));
    
    for i = 1:length(argsIn)
        intype{i} = get_param(argsIn{i}, 'OutDataTypeStr');
    end

    for j = 1:length(argsOut)
        outtype{j} = get_param(argsOut{j}, 'OutDataTypeStr');
    end 
end