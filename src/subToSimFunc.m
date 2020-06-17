function subToSimFunc(subsystem,simulinkFunctionName,visibility)
% subToSimFunc converts a subsystem to a Simulink-function
%
% Inputs:
%   subsystem           Path of a subsystem to be converted
%   simulinkFunctionName     Name of the Simulink-function to be created
%   visibility          Set function Visibility parameter to'scoped' or 'global'
%
% Outputs:
%   N/A
%
% Example:
%   subToSimFunc('Demo_Example/f_Sensor_Trip_1','f_Sensor_Trip_i', 'scoped')
%
%           Converts 'f_Sensor_Trip_1' subsystem to a
%           scoped Simulink-function 'f_SensorTrip_i'
%
% Author: Stephen Scott

    %% Input Validation
    
    % Check that the subsystem is loaded
    try
        assert(ischar(subsystem));
        assert(bdIsLoaded(bdroot(subsystem)));
    catch
        error('Invalid subsystem. Model may not be loaded or name is invalid.');
    end
    
    % Check that the function name is valid
    try
        assert(isvarname(simulinkFunctionName));
    catch
        error('Invalid function name. Use a valid MATLAB variable name.');
    end
    
    % Check that the function visibility is valid
    try
        assert(strcmp(visibility,'scoped')||strcmp(visibility,'global'));
    catch
        error('Invalid function visibility. Use scoped/global visibility.');
    end
    
    %% Convert Subsystem to Simulink-function
    
    % Disable subsystem link
    set_param(subsystem,'LinkStatus','inactive');

    % Adding the trigger block to the subsystem and calibrating its parameters
    TriggerPath=append(subsystem,'/',simulinkFunctionName);
    add_block('simulink/Ports & Subsystems/Trigger',TriggerPath);
    set_param(TriggerPath,'TriggerType','function-call','IsSimulinkFunction',...
              'on','FunctionName',simulinkFunctionName,...
              'FunctionVisibility',visibility);
    
    % Set subsystem to atomic execution
    set_param(subsystem,'TreatAsAtomicUnit','on');
    
    %% Convert Inports to ArgIns
    
    % Create array of all the inports in the subsystem
    allInports=find_system(subsystem,'SearchDepth',1,'BlockType','Inport');
    
    % Getting the parameters for all inports in the subsystem
    inportParameters=getPortParameters(allInports);
    
    % Replace inports with argument inputs
    replace_block(subsystem,'SearchDepth',1,'BlockType',...
                  'Inport','ArgIn','noprompt');
    
    % Create array of all the argIns in the Simulink-function
    allArgIns=find_system(subsystem,'SearchDepth',1,'BlockType','ArgIn');
    
    % Setting the parameters for all the argument inputs
    for argIn=1:length(allArgIns)
        set_param(allArgIns{argIn},'Port',inportParameters{argIn,1},...
                  'OutMin',inportParameters{argIn,2},...
                  'OutMax',inportParameters{argIn,3},...
                  'OutDataTypeStr',inportParameters{argIn,4},...
                  'LockScale',inportParameters{argIn,5},....
                  'PortDimensions',inportParameters{argIn,6},...
                  'ArgumentName',inportParameters{argIn,7});
    end
    
    %% Convert Outports to ArgOuts
    
    % Create array of all the outports in the subsystem
    allOutports=find_system(subsystem,'SearchDepth',1,'BlockType','Outport');
    
    % Getting the parameters for all outports in the subsystem
    outportParameters=getPortParameters(allOutports);
    
    % Replace outports with argument outputs
    replace_block(subsystem,'SearchDepth',1,'BlockType',...
                  'Outport','ArgOut','noprompt');
    
    % Create array of all the argOuts for the Simulink-function
    allArgOuts=find_system(subsystem,'SearchDepth',1,'BlockType','ArgOut');
    
    % Setting the parameters for all the argument outputs
    for argOut=1:length(allArgOuts)
        set_param(allArgOuts{argOut},'Port',outportParameters{argOut,1},...
                  'OutMin',outportParameters{argOut,2},...
                  'OutMax',outportParameters{argOut,3},...
                  'OutDataTypeStr',outportParameters{argOut,4},...
                  'LockScale',outportParameters{argOut,5},...
                  'PortDimensions',outportParameters{argOut,6},...
                  'ArgumentName',outportParameters{argOut,7});
    end
end

function parameters=getPortParameters(ports)
% getPortParameters returns the parameters for an inport or outport
%
% Inputs:
%   ports           Cell array of inports or outports
%
% Outputs:
%   parameters      Cell array of parameters including:
%                       1) Port
%                       2) OutMin
%                       3) OutMax
%                       4) OutDataTypeStr
%                       5) LockScale
%                       6) PortDimensions
%                       7) ArgumentName
%
% Example:
%   parameters=getPortParameters({'System/Subsystem/Inport1'})
%
%           ans = 
%                1x7 cell array
%                    {'1'} {'[]'} {'[]'} {'boolean'} {'off'} {'on'} {'Inport1'}

    %% Get the port parameters
    % Init counter to counter invalid port names
    invalidNameCounter=0;
    % Init array of parameters for the ports
    parameters=cell(length(ports),7);
    % Loop through each port
    for port=1:length(ports)
        % Get the port number
        parameters{port,1}=get_param(ports{port},'Port');
        % Get the port minimum output
        parameters{port,2}=get_param(ports{port},'OutMin');
        % Get the port maximum output
        parameters{port,3}=get_param(ports{port},'OutMax');
        % Get the port data type
        parameters{port,4}=get_param(ports{port},'OutDataTypeStr');
        % If data type is set to inherit, set to double by default
        try
            assert(not(strcmp(parameters{port,4},'Inherit: auto')));
        catch
            disp(['Invalid data type of port',newline,ports{port},newline,...
                  'was set to Inherit - setting to double...',newline]);
            parameters{port,4}='double';
        end
        % Get the port lock scale
        parameters{port,5}=get_param(ports{port},'LockScale');
        % Get the port dimension
        parameters{port,6}=get_param(ports{port},'PortDimensions');
        % If port dimension is set to inherit, set to 1 by default
        try
            assert(not(strcmp(parameters{port,6},'-1')))
        catch
            disp(['Invalid port dimensions of port:',newline,ports{port},...
                   newline,'was set to Inherit - setting to 1...',newline]);
            parameters{port,6}='1';
        end
        % Get the port name by splitting the pathname by the backslash
        splitPortPath=split(ports{port},'/');
        % Set port name equal to the last string in the split pathname
        parameters{port,7}=splitPortPath{end};
        % If port name is invalid variable name, set to invalid name counter
        try
            assert(isvarname(parameters{port,7}));
        catch
            invalidNameCounter = invalidNameCounter + 1;
            parameters{port,7}=strcat('arg',num2str(invalidNameCounter));
            disp(['Invalid port variable name:',newline,splitPortPath{end},...
                   newline,'setting to ',parameters{port,7},newline])
        end
    end
end