function [isAtomic, sysAtomic] = inAtomicSubsystem(block)
% ISATOMICSUBSYSTEM Determine if the block is contained in an atomic subsystem.
%
%   Inputs:
%       block      Block name.
%
%   Outputs:
%       isAtomic   Whether the block resides in an atomic subsystem(1) or not(0).
%       sysAtomic  Atomic subsystem in which the block resides.

    isAtomic = false;
    sysAtomic = '';
    
    parent = get_param(block, 'Parent');
    while ~isempty(parent)
        disp(parent)
        try
            isAtomic = strcmpi(get_param(parent, 'TreatAsAtomicUnit'), 'on');
            if isAtomic
                sysAtomic = parent;
                return;
            end
            parent = get_param(parent, 'Parent');
        catch ME
            % reached root
            if strcmpi(ME.identifier, 'Simulink:Commands:ParamUnknown') 
                return;
            end
        end
    end
end