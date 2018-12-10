function time = getSampleTime(block)
% GETSAMPLETIME Determine the sample time of the block. Based on the 
%   SampleTime and CompiledSampleTime parameters. Note that some blocks may have
%   different sample rates for different ports (e.g. SubSystems containing blocks 
%   with different rates). Sample time may be more accurate after model
%   comilation.
%
%   Inputs:
%       block   Block name or handle.
%
%   Outputs:
%       time    Vector of times.
%
%   Example:
%       >> getSampleTime('ex_compiled_sample_new/Sine Wave3')
%           ans =
%               0.5000    
%               
%       >> getSampleTime('ex_compiled_sample_new/Atomic Subsystem')
%           ans =
%               3    
%               4
%
% See: www.mathworks.com/help/simulink/ug/determining-the-compiled-sample-time-of-a-block.html
    
    narginchk(1,1);
    
    explicitTime = [];
    try
        explicitTime = str2double(get_param(block, 'SampleTime'));
    catch ME
        if ~strcmpi(ME.identifier, 'Simulink:Commands:ParamUnknown')
            rethrow(ME)
        end
    end
    implicitTime = get_param(block, 'CompiledSampleTime');
    if iscell(implicitTime)
        implicitTime = cell2mat(implicitTime);
    end
    
    % Get the first row only. Documentation doesn't say what the second row is for, 
    % and it contains zeros
    implicitTime = implicitTime(:,1);  
    
    % Determine which to return. If the implicit time is available, always
    % return it because it could be different from the explicit time.
    if ~isInherited(implicitTime)
        time = implicitTime;
    elseif isempty(explicitTime)
        time = implicitTime;
    else
        time = explicitTime;
    end
end

function b = isInherited(time)
    if ~iscell(time)
        b = time == -1;
    else
        b = false;
    end
end