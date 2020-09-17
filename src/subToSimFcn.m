function subToSimFcn(subsystem, simulinkFcnName, visibility)
% SUBTOSIMFUNC Convert a Subsystem into a Simulink Function.
%
%   Inputs:
%       subsystem         Path of a subsystem to be converted.
%       simulinkFcnName   Name of the Simulink Function to be created.
%       visibility        Set function visibility to 'scoped' or 'global'.
%
%   Outputs:
%       N/A
%
%   Example:
%       subToSimFunc('Demo_Example/f_Sensor_Trip_1', 'f_Sensor_Trip_i', 'scoped')

    %% Input Validation
    % Check that the subsystem model is loaded
    try
        assert(ischar(subsystem));
        assert(bdIsLoaded(bdroot(subsystem)));
    catch
        error('Invalid subsystem. Model may not be loaded or name is invalid.');
    end
    
    % Check that the function name is valid
    try
        assert(isvarname(simulinkFcnName));
    catch
        error('Invalid function name. Use a valid MATLAB variable name.');
    end
    
    % Check that the function visibility is valid
    try
        assert(strcmp(visibility, 'scoped') || strcmp(visibility, 'global'));
    catch
        error('Invalid function visibility. Use scoped/global visibility.');
    end
    
    %% Add Trigger to Subsystem  
    % Break library link
    set_param(subsystem, 'LinkStatus', 'none');

    % Adding the trigger block to the subsystem
    triggerPath = [subsystem, '/', simulinkFcnName];
    add_block('simulink/Ports & Subsystems/Trigger', triggerPath);
    
    % Set trigger block parameters
    set_param(triggerPath, 'TriggerType', 'function-call');
    try
        set_param(triggerPath, 'IsSimulinkFunction', 'on', 'FunctionName', simulinkFcnName);
    catch ME
        if strcmp(ME.identifier, 'Simulink:Commands:ParamUnknown')
            % Version of Simulink is pre-R2014b so doesn't support Simulink Functions
            v = ver('Simulink');
            warning(ME.identifier, ['Simulink ' v.Release ' does not support Simulink Functions.']);
        else
            rethrow(ME)
        end
    end
    try
        set_param(triggerPath, 'FunctionVisibility', visibility);   
    catch ME
        if strcmp(ME.identifier, 'Simulink:Commands:ParamUnknown')
            %  Version of Simulink is pre-R2017b so doesn't support scoping
            v = ver('Simulink');
            warning(ME.identifier, ['Simulink ' v.Release ' does not support Simulink Function scope.']);
        else
            rethrow(ME)
        end
    end
    
    %% Set subsystem parameters
    set_param(subsystem, 'TreatAsAtomicUnit', 'on');
    
    %% Convert Inports to ArgIns    
    % Create array of all the inports in the subsystem
    allInports = find_system(subsystem, 'SearchDepth', 1, 'BlockType', 'Inport');
    
    % Get the parameters for all inports in the subsystem
    inportParameters = getPortParameters(allInports);
    
    % Replace inports with argument inputs
    replace_block(subsystem, 'SearchDepth', 1, 'BlockType', 'Inport', 'ArgIn', 'noprompt');
    
    % Create array of all the argIns in the Simulink Function
    allArgIns = find_system(subsystem, 'SearchDepth', 1, 'BlockType', 'ArgIn');
    
    % Set the parameters for all the argument inputs
    setArgumentParameters(allArgIns, inportParameters);
    
    %% Convert Outports to ArgOuts    
    % Create array of all the outports in the subsystem
    allOutports = find_system(subsystem, 'SearchDepth', 1, 'BlockType', 'Outport');
    
    % Get the parameters for all outports in the subsystem
    outportParameters = getPortParameters(allOutports);
    
    % Replace outports with argument outputs
    replace_block(subsystem, 'SearchDepth', 1, 'BlockType', 'Outport', 'ArgOut', 'noprompt');
    
    % Create array of all the argOuts for the Simulink Function
    allArgOuts = find_system(subsystem, 'SearchDepth', 1, 'BlockType', 'ArgOut');
    
    % Set the parameters for all the argument outputs
    setArgumentParameters(allArgOuts, outportParameters);
end

function parameters = getPortParameters(ports)
% getPortParameters     Get the parameters for an inport or outport.
%
% Inputs:
%   ports               Cell array of inports or outports.
%
% Outputs:
%   parameters          Cell array of parameters including:
%                           1) Port
%                           2) OutMin
%                           3) OutMax
%                           4) OutDataTypeStr
%                           5) LockScale
%                           6) PortDimensions
%                           7) ArgumentName
%
% Example:
%   parameters = getPortParameters({'System/Subsystem/Inport1'})
%
%      ans = 
%          1x7 cell array
%            {'1'} {'[]'} {'[]'} {'boolean'} {'off'} {'on'} {'Inport1'}

    %% Get the port parameters
    % Init array of parameters for the ports
    parameters = cell(length(ports), 7);
    % Loop through each port
    for port = 1:length(ports)
        % Get the port name by splitting the pathname by the backslash
        splitPortPath = split(ports{port}, '/');
        % The port name is the last index of splitPortPath
        portName = splitPortPath{end};
        % Get the port number
        parameters{port, 1} = get_param(ports{port}, 'Port');
        % Get the port minimum output
        parameters{port, 2} = get_param(ports{port}, 'OutMin');
        % Get the port maximum output
        parameters{port, 3} = get_param(ports{port}, 'OutMax');
        % Get the port data type
        parameters{port, 4} = get_param(ports{port}, 'OutDataTypeStr');
        % If data type is set to inherit, set to double by default
        try
            assert(not(strcmp(parameters{port, 4}, 'Inherit: auto')));
        catch
            disp([portName, ...
                  ' data type was set to ''Inherit: auto''', ...
                  ' - setting to ''double''...']);
            parameters{port, 4} = 'double';
        end
        % Get the port lock scale
        parameters{port, 5} = get_param(ports{port}, 'LockScale');
        % Get the port dimension
        parameters{port, 6} = get_param(ports{port}, 'PortDimensions');
        % If port dimension is set to inherit, set to 1 by default
        try
            assert(not(strcmp(parameters{port, 6}, '-1')))
        catch
            disp([portName, ...
                  ' dimension was set to ''-1''', ...
                  ' - setting to ''1''...']);
            parameters{port, 6} = '1';
        end
        % Remove spaces from port name to create a valid variable name
        parameters{port, 7} = genvarname(portName);
    end
end

function setArgumentParameters(arguments, parameters)
% setArgumentParameters     Set argIn or ArgOut parameters.
%
% Inputs:
%   arguments               Cell array of argIns or argOuts.
%   parameters              Cell array of parameters for each argument.
%
% Outputs:
%   N/A
%
% Example:
%   setArgumentParameters({'System/Subsystem/argIn1'}, ...
%        {'1', '[]', '[]', 'boolean', 'off', 'on', 'Inport1'})

    %% Set the argument parameters
    % Loop through each argument
    for arg = 1:length(arguments)
        % Set the parameters for each argument
        set_param(arguments{arg}, 'Port', parameters{arg, 1}, ...
                  'OutMin', parameters{arg, 2}, ...
                  'OutMax', parameters{arg, 3}, ...
                  'OutDataTypeStr', parameters{arg, 4}, ...
                  'LockScale', parameters{arg, 5}, ...
                  'PortDimensions', parameters{arg, 6}, ...
                  'ArgumentName', parameters{arg, 7});
    end
end