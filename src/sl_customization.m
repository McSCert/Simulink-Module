%% Register custom menu function to beginning of Simulink Editor's context menu
function sl_customization(cm)
	cm.addCustomMenuFcn('Simulink:PreContextMenu', @getSLModuleTool);
end

%% Define custom menu function: Changing Scope
function schemaFcns = getSLModuleTool(callbackInfo)
    schemaFcns = {};
    selection = find_system(gcs, 'Type', 'block', 'Selected', 'on');
    selectedFcns = isSimulinkFcn(selection);
    
    % Check if the Simulink version supports Simulink Functions
    v = ver('Simulink');
    if str2double(v.Version) > 8.3 % Greater than 2014a
        verOK = true;
    else
        verOK = false;
    end

    if isempty(gcbs)
        schemaFcns{end+1} = @FcnCreatorSchema;
        schemaFcns{end+1} = @GuidelineSchema;
        schemaFcns{end+1} = @InterfaceSchema;
    elseif verOK && isSubsystem(gcbs) && ~isSimulinkFcn(gcbs) && ~isempty(gcbs)
        schemaFcns{end+1} = @ConvToSimFcnSchema;
    elseif any(selectedFcns) && ~isempty(gcbs)
        schemaFcns{end+1} = @ChangeFcnScopeSchema;
        schemaFcns{end+1} = @FcnCreatorLocalSchema;
    end
end

%% Define action: Convert Subsystem to Simulink Function
function schema = ConvToSimFcnSchema(callbackInfo)
    schema = sl_container_schema;
    schema.label = 'Convert Subsystem';
    schema.ChildrenFcns = {@toScopedSimFcn, @toGlobalSimFcn};
end

function schema = toScopedSimFcn(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'To Scoped Simulink Function';
    schema.userdata = 'toScopedSimFcn';
    schema.callback = @toScopedSimFcnCallback;
end

function toScopedSimFcnCallback(callbackInfo)
    simulinkFcnName = reqSimFcnName();
    subsystem = gcbs;
    subToSimFcn(subsystem{1}, simulinkFcnName, 'scoped');
end

function schema = toGlobalSimFcn(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'To Global Simulink Function';
    schema.userdata = 'toGlobalSimFcn';
    schema.callback = @toGlobalSimFcnCallback;
end

function toGlobalSimFcnCallback(callbackInfo)
    simulinkFcnName = reqSimFcnName();
    subsystem = gcbs;
    subToSimFcn(subsystem{1}, simulinkFcnName, 'global');
end

%% Define action: Create Function Caller for Local Function
function schema = FcnCreatorLocalSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Create Function Caller';
    schema.userdata = 'createFcnCallerLocal';
    schema.callback = @createFcnCallerLocalCallback;
end

function createFcnCallerLocalCallback(callbackInfo)
    createFcnCallerLocal(gcbs);
end

%% Define action: Create Function Caller for Any Function
function schema = FcnCreatorSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Call Function...';
    schema.userdata = 'createFcnCaller';
    schema.callback = @FcnCreatorCallback;
end

function FcnCreatorCallback(callbackInfo)
    sys = gcs; % Save in case it changes
    
    % Position the caller in the center of the model
    bounds = bounds_of_sim_objects(find_system(sys, 'SearchDepth', 1));
    x = ((bounds(3)-bounds(1))/2) + bounds(1);
    y = ((bounds(4)-bounds(2))/2) + bounds(2);
    
    [fcns, proto] = getCallableFunctions(sys);
    idx = functionGUI(fcns, proto); % let user make selection
    f = char(fcns(idx));
    p = char(proto(idx));
    
    if ~isempty(f)
        % Load model is necessary
        i = regexp(f, '/', 'once');
        mdl = f(1:i-1);
        loaded = bdIsLoaded(mdl);
        if ~loaded
            load_system(mdl);
        end
        
        createFcnCaller(sys, f, 'prototype', p, 'position', [x, y]);
        
        % Close model if necessary
        if ~loaded
            close_system(mdl, 0);
        end
    end
end

%% Define action: Change Scope
function schema = ChangeFcnScopeSchema(callbackInfo)
    schema = sl_container_schema;
    schema.label = 'Change Function Scope';
    schema.userdata = 'changeFcnScope';
    
    % Get the functions that are selected and determine their scope
    selection = find_system(gcs, 'Type', 'block', 'Selected', 'on');
    selectedFcns = isSimulinkFcn(selection);
    fcns = {};
    for i = 1:length(selectedFcns)
        if selectedFcns(i)
            fcns{end+1,1} = selection{i};
        end
    end
    scopes = getFcnScope(fcns);

    % Show conversion operations depending on scope
    anyGlobal = any(contains2(scopes, char(Scope.Global)));
    anyScoped = any(contains2(scopes, char(Scope.Scoped)));
    anyLocal = any(contains2(scopes, char(Scope.Local)));
    if anyScoped || anyLocal
        schema.childrenFcns{end+1} = @GlobalFcnSchema;
    end
    if anyGlobal || anyLocal
        schema.childrenFcns{end+1} = @ScopedFcnSchema;
    end
    if  anyGlobal || anyScoped || anyLocal
        schema.childrenFcns{end+1} = @LocalFcnSchema;
    end
    
    % If there are functions selected, but the functions don't have a scope
    if isempty(schema.childrenFcns)
        schema.state = 'Disabled'; 
    end
    
    garbageCollection();
end

%% Define action: Convert to Global
function schema = GlobalFcnSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'To Global Function';
    schema.userdata = 'convertToGlobalFcn';
    schema.callback = @convertToGlobalFcnCallback;
end

function convertToGlobalFcnCallback(callbackInfo)
    setFcnScope(gcbs, Scope.Global, '');
end

%% Define action: Convert to Scoped
function schema = ScopedFcnSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'To Scoped Exported Function';
    schema.userdata = 'convertToScopedFcn';
    schema.callback = @convertToScopedFcnCallback;
end

function convertToScopedFcnCallback(callbackInfo)
    setFcnScope(gcbs, Scope.Scoped, '');
end

%% Define action: Convert to Local
function schema = LocalFcnSchema(callbackInfo)
    schema = sl_container_schema;
    schema.label = 'To Scoped Local Function';
    schema.userdata = 'convertToLocalFcn';
    schema.childrenFcns = {@LocalFcnNewSchema, @LocalFcnExistSchema};
end

function schema = LocalFcnNewSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'In New Subsystem';
    schema.userdata = 'convertToLocalFcnNew';
    schema.callback = @convertToLocalFcnNewCallback;
end

function convertToLocalFcnNewCallback(callbackInfo)
    setFcnScope(gcbs, Scope.Local, '');
end

function schema = LocalFcnExistSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'In Existing Subsystem';
    schema.userdata = 'convertToLocalFcnExist';
    schema.callback = @convertToLocalFcnExistCallback;
end

function convertToLocalFcnExistCallback(callbackInfo)
    subsystem = subsystemGUI(bdroot);
    if ~isempty(subsystem)
        setFcnScope(gcbs, Scope.Local, subsystem);
    end
end

%% Define action: Check Guidelines
function schema = GuidelineSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Check Guidelines...';
    schema.userdata = 'checkGuidelines';
    schema.callback = @CheckGuidelines;
end

function CheckGuidelines(callbackInfo)
    sys = gcs;
    guidelines = guidelineSelector;
    if guidelines(1)
        [blocks, locations] = guideline0001(sys);
        fprintf('Guideline 1 ''Simulink Function Placement'' violations: ');
        if isempty(blocks)
            fprintf('None\n');
        else
            fprintf('\n');
            for i = 1:length(blocks)
                fprintf('\t%s can be moved to %s\n', replaceNewline(blocks{i}), replaceNewline(locations{i}));
            end
            fprintf('\n');
        end
    end
    if guidelines(2)
        blocks = guideline0002(sys);
        fprintf('Guideline 2 ''Simulink Function Visibility'' violations: ');
        if isempty(blocks)
            fprintf('None\n');
        else
            fprintf('\n');
            for i = 1:length(blocks)
                fprintf('\t%s\n', replaceNewline(blocks{i}));
            end
            fprintf('\n');
        end
    end
    if guidelines(3)
        [blocks, shadows] = guideline0003(sys);
        fprintf('Guideline 3 ''Simulink Function Shadowing'' violations: ');
        if isempty(blocks)
            fprintf('None\n');
        else
            fprintf('\n');
            for i = 1:length(blocks)
               if ~isempty(shadows{i})
                    fprintf('\t%s is shadowed by:\n\t\t%s\n', replaceNewline(blocks{i}), strjoin(replaceNewline(shadows{i}), '\n\t\t'));
               end     
               fprintf('\n');
            end
        end        
    end
    if guidelines(4)
        blocks = guideline0004(sys);
        fprintf('Guideline 4 ''Use of Base Workspace'' violations: ');
        if isempty(blocks)
            fprintf('None\n');
        else
            fprintf('\n');
            for i = 1:length(blocks)
                fprintf('\t%s\n', replaceNewline(blocks{i}));       
            end
            fprintf('\n');
        end
    end
    
    garbageCollection();
end

%% Define menu: Model Interface
function schema = InterfaceSchema(callbackInfo)
    schema = sl_container_schema;
    schema.label = 'Interface';
    schema.ChildrenFcns = {@ModelInterfaceSchema, @PrintInterfaceSchema, @DeleteInterface, @PrintDependencies};
end

function schema = ModelInterfaceSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Show Interface';
    schema.callback = @showInterfaceCallback;
end

function showInterfaceCallback(callbackInfo)

    garbageCollection();
       
    sys = bdroot(gcs);
    objName = [sys '_InterfaceObject'];
    eval(['global ' objName ';']);
    
    if interface_exists(sys) 
        eval([objName ' = load_interface(sys);']);
        answer = questdlg('An interface already exists. Do you wish to replace it?', 'Interface Exists');
        if strcmp(answer, 'Yes')
            % Delete old representation
            eval([objName '.delete();'])

            % Create new interface
            eval([objName ' = Interface(sys);']);
            eval([objName ' = ' objName '.model();']);
        end
    else
        eval([objName ' = Interface(sys);']);
        eval([objName ' = ' objName '.model;']);
    end
    eval([objName '.saveInterfaceMat;']);
end

%% Define menu: Print Interface
function schema = PrintInterfaceSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Print Interface';
    schema.callback = @printInterfaceCallback;
end

function printInterfaceCallback(callbackInfo)
    sys = bdroot(gcs);
    objName = [sys '_InterfaceObject'];
    if interface_exists(sys)
        eval([objName ' = load_interface(sys);']);
    else
        eval([objName ' = Interface(sys);']);
    end
    eval([objName '.print();']);
    
    garbageCollection();
end

%% Delete Interface
function schema = DeleteInterface(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Delete Interface';
    schema.userdata = 'DeleteInterface';
    schema.callback = @deleteInterfaceCallback;
    
    % Hide the delete option when there is nothing to delete
    sys = bdroot(gcs);
    if interface_exists(sys)
        schema.state = 'Enabled';
    else
        schema.state = 'Disabled';
    end
end

function deleteInterfaceCallback(callbackInfo)
    sys = bdroot(gcs);
    objName = [sys '_InterfaceObject'];
    eval(['global ' objName ';']);
    
    eval([objName ' = load_interface(sys);']);
    
    eval([objName ' = delete(' objName ');']);
    eval(['clear global ' objName ';']);
    
    garbageCollection();
end

function filename = get_interface_filename(sys)
    syspath = get_param(sys, 'FileName');
    [path, name, ~] = fileparts(syspath);
    ext = '.mat';
    filename = fullfile(path, [name '_Interface' ext]);
end

function e = interface_exists(sys)
    % INTERFACE_EXISTS Determine if there exists an interface for a model.
    objName = [sys '_InterfaceObject'];
    eval(['global ' objName ';']);
    eval(['objEmpty = isempty(' objName ');']);
    
    filename = get_interface_filename(sys);
    
    if objEmpty
        if isfile(filename)
            e = true;
        else
            e = false;
        end
    else
        e = true;
    end
end

function obj = load_interface(sys)
    filename = get_interface_filename(sys);
    if interface_exists(sys)
       obj = load(filename);
       obj = obj.obj;
    end
end

%% Print dependencies
function schema = PrintDependencies(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Print Dependencies';
    schema.userdata = 'PrintDependencies';
    schema.callback = @printDependenciesCallback;
end

function printDependenciesCallback(callbackInfo)
    sys = bdroot(gcs);
    dependencies(sys);
    garbageCollection();
end

%% Garbage collection for objects
function garbageCollection()
    globals = who('global');
    
    suffix = 'InterfaceObject';
    suffixLen = length(suffix) + 1;
    
    sysAll = cellfun(@(x) x(1:end-suffixLen), globals, 'un', 0);
    allSysOpen = find_system('SearchDepth', 0);
    globalHasSysOpen = ismember(sysAll, allSysOpen);
    
    for i = 1:length(globals)
        isInterfaceName = ~isempty(strfind(globals{i}, suffix));
        if isInterfaceName
            eval(['global ' globals{i} ';']) % Get this object
            if ~globalHasSysOpen(i) % Has no associated model open          
                eval(['x =~ isempty(' globals{i} ');']);
                if x
                    eval(['clearvars -global ' globals{i} ';']);
                    %eval([globals{i} '.delete;']);
                end
            else % There is a system open that matches the object name
                % A different instance of the same model could be open, so we
                % check that the model handles match
                sameHdl = false;
                try
                    eval(['objHdl = ' globals{i} '.getHandle;']);
                    sysHdl = get_param(sysAll{i}, 'Handle');
                    sameHdl = (objHdl == sysHdl);
                catch
                    continue
                end
                
                if ~sameHdl %|| ~ishandle(objHdl
                    eval(['clearvars -global ' globals{i} ';']);
                %else
                    %eval([globals{i} '.delete;']);
                end
            end
        end
    end
end
