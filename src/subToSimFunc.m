function subToSimFunc(Subsystem,SimFunctionName,Visibility)
% subToSimFunc converts a subsystem to a Simulink-function
%
% Inputs:
%   Subsystem           Path of a subsystem to be converted
%   SimFunctionName     Name of the Simulink-function to be created
%   Visibility          Set function Visibility parameter to'scoped' or 'global'
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
        assert(ischar(Subsystem));
        assert(bdIsLoaded(bdroot(Subsystem)));
    catch
        error('Invalid subsystem. Model may not be loaded or name is invalid.');
    end
    
    % Check that the function name is valid
    try
        assert(isvarname(SimFunctionName));
    catch
        error('Invalid function name. Use a valid MATLAB variable name.');
    end
    
    % Check that the function visibility is valid
    try
        assert(strcmp(Visibility,'scoped')||strcmp(Visibility,'global'));
    catch
        error('Invalid function visibility. Use scoped/global visibility.');
    end

    %% Init constants
    
    errorCounter = 0;
    invalidNameCounter = 0;
    
    %% Convert Subsystem to Simulink-function
    
    % Disable subsystem link
    set_param(Subsystem,'LinkStatus','inactive');

    % Adding the trigger block to the subsystem and calibrating its parameters
    TriggerPath=append(Subsystem,'/',SimFunctionName);
    add_block('simulink/Ports & Subsystems/Trigger',TriggerPath);
    set_param(TriggerPath,'TriggerType','function-call','IsSimulinkFunction' ...
    ,'on','FunctionName',SimFunctionName,'FunctionVisibility',Visibility);
    
    % Set subsystem to atomic execution
    set_param(Subsystem,'TreatAsAtomicUnit','on');
    
    %% Convert Inports to ArgIns
    
    % Getting the parameters for all inports in the subsystem
    allInports=find_system(Subsystem,'SearchDepth',1,'BlockType','Inport');
    inportParameters=cell(length(allInports),7);
    for inport=1:length(allInports)
        inportParameters{inport,1}=get_param(allInports{inport},'Port');
        inportParameters{inport,2}=get_param(allInports{inport},'OutMin');
        inportParameters{inport,3}=get_param(allInports{inport},'OutMax');
        inportParameters{inport,4}=get_param(allInports{inport},'OutDataTypeStr');
        if strcmp(inportParameters{inport,4},'Inherit: auto')
            errorCounter = errorCounter+1;
            inportParameters{inport,4}='double';
            disp([num2str(errorCounter),'.',newline,'Data type of inport',newline,allInports{inport},newline,'was set to Inherit - setting to double...',newline]);
        end
        inportParameters{inport,5}=get_param(allInports{inport},'LockScale');
        inportParameters{inport,6}=get_param(allInports{inport},'PortDimensions');
        if strcmp(inportParameters{inport,6},'-1')
            errorCounter = errorCounter+1;
            inportParameters{inport,6}='1';
            disp([num2str(errorCounter),'.',newline,'Port dimensions of inport',newline,allInports{inport},newline,'was set to Inherit - setting to 1...',newline]);
        end
        splitInportPath=split(allInports{inport},'/');
        if isvarname(splitInportPath{end})
            inportParameters{inport,7}=splitInportPath{end};
        else
            errorCounter = errorCounter+1;
            invalidNameCounter = invalidNameCounter + 1;
            inportParameters{inport,7}=strcat('arg',num2str(invalidNameCounter));
            disp([num2str(errorCounter),'.',newline,'Invalid inport variable name',newline,splitInportPath{end},newline,'setting to ',inportParameters{inport,7},newline])
        end
    end
    
    % Replace inports with argument inputs
    replace_block(Subsystem,'SearchDepth',1,'BlockType','Inport','ArgIn','noprompt');
    
    % Setting the parameters for all the argument inputs
    allArgIns=find_system(Subsystem,'SearchDepth',1,'BlockType','ArgIn');
    for argIn=1:length(allArgIns)
        set_param(allArgIns{argIn},'Port',inportParameters{argIn,1},'OutMin',inportParameters{argIn,2},'OutMax',inportParameters{argIn,3},'OutDataTypeStr',inportParameters{argIn,4},'LockScale',inportParameters{argIn,5},'PortDimensions',inportParameters{argIn,6},'ArgumentName',inportParameters{argIn,7});
    end
    
    %% Convert Outports to ArgOuts
    
    % Getting the parameters for all outports in the subsystem
    allOutports=find_system(Subsystem,'SearchDepth',1,'BlockType','Outport');
    outputParameters=cell(length(allInports),7);
    for outport=1:length(allOutports)
        outputParameters{outport,1}=get_param(allOutports{outport},'Port');
        outputParameters{outport,2}=get_param(allOutports{outport},'OutMin');
        outputParameters{outport,3}=get_param(allOutports{outport},'OutMax');
        outputParameters{outport,4}=get_param(allOutports{outport},'OutDataTypeStr');
        if strcmp(outputParameters{outport,4},'Inherit: auto')
            errorCounter = errorCounter + 1;
            outputParameters{outport,4}='double';
            disp([num2str(errorCounter),'.',newline,'Data type of outport',newline,allOutports{outport},newline,'was set to Inherit - setting to double...',newline]);
        end
        outputParameters{outport,5}=get_param(allOutports{outport},'LockScale');
        outputParameters{outport,6}=get_param(allOutports{outport},'PortDimensions');
        if strcmp(outputParameters{outport,6},'-1')
            errorCounter = errorCounter+1;
            outputParameters{outport,6}='1';
            disp([num2str(errorCounter),'.',newline,'Port dimensions of outport',newline,allOutports{outport},newline,'was set to Inherit - setting to 1...',newline]);
        end
        splitOutportPath=split(allOutports{outport},'/');
        if isvarname(splitOutportPath{end})
            outputParameters{outport,7}=splitOutportPath{end};
        else
            errorCounter = errorCounter + 1;
            invalidNameCounter = invalidNameCounter + 1;
            outputParameters{outport,7}=strcat('arg',num2str(invalidNameCounter));
            disp([num2str(errorCounter),'.',newline,'Invalid outport variable name',newline,splitOutportPath{end},newline,'setting to ',outputParameters{outport,7},newline])
        end
    end
    
    % Replace outports with argument outputs
    replace_block(Subsystem,'SearchDepth',1,'BlockType','Outport','ArgOut','noprompt');
    
    % Setting the parameters for all the argument outputs
    allArgOuts=find_system(Subsystem,'SearchDepth',1,'BlockType','ArgOut');
    for argOut=1:length(allArgOuts)
        set_param(allArgOuts{argOut},'Port',outputParameters{argOut,1},'OutMin',outputParameters{argOut,2},'OutMax',outputParameters{argOut,3},'OutDataTypeStr',outputParameters{argOut,4},'LockScale',outputParameters{argOut,5},'PortDimensions',outputParameters{argOut,6},'ArgumentName',outputParameters{argOut,7});
    end
end