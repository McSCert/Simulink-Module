function time = getSampleTime(block)
% GETSAMPLETIME Determine the block sample time. Based on the 
%   SampleTime and CompiledSampleTime parameters. Note that some blocks may have
%   different sample rates for different ports (e.g. SubSystems containing blocks 
%   with different rates). Sample time may be more accurate after model
%   compilation.
%
%   Inputs:
%       block   Block path or handle.
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
    
    % 1) Get the SampleTime
    sampleTime = [];
    try
        sampleTime = str2double(get_param(block, 'SampleTime'));
    catch ME
        if ~strcmpi(ME.identifier, 'Simulink:Commands:ParamUnknown')
            rethrow(ME)
        end
    end
    
    % For Simulink.Signal objects
    [isGlobal, obj, ~] = isGlobalDataStore(block);
    if isGlobal
        sampleTimeDs = obj.SampleTime;
        if (isInherited(sampleTime) || isempty(sampleTime)) && ~isempty(sampleTimeDs)
            sampleTime = sampleTimeDs;
        end
    end    
    
    % 2) Get the CompiledSampleTime
    compiledSampleTime = get_param(block, 'CompiledSampleTime');
    if iscell(compiledSampleTime)
        compiledSampleTime = cell2mat(compiledSampleTime);
    end
    
    % Get the first row only. Documentation doesn't say what the second row is for, 
    % and it contains zeros
    compiledSampleTime = compiledSampleTime(:,1);  

    % Finally: Determine which to return. If the compiled time is available, always
    % return it because it could be different from the sample time.
    if ~isInherited(compiledSampleTime)
        time = compiledSampleTime;
    elseif isempty(sampleTime)
        time = compiledSampleTime;
    else
        time = sampleTime;
    end
end

function b = isInherited(time)
    if ~iscell(time)
        b = time == -1;
    else
        b = false;
    end
end