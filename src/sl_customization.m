%% Register custom menu function to beginning of Simulink Editor's context menu
function sl_customization(cm)
	cm.addCustomMenuFcn('Simulink:PreContextMenu', @getSLModuleTool);
end

%% Define custom menu function: Changing Scope
function schemaFcns = getSLModuleTool(callbackInfo)
    schemaFcns = {};
    selection = find_system(gcs, 'Type', 'block', 'Selected', 'on');
    selectedFcns = isSimulinkFcn(selection);

    if isempty(gcbs)
        schemaFcns{end+1} = @FcnCreatorSchema;
        schemaFcns{end+1} = @GuidelineSchema;
        schemaFcns{end+1} = @InterfaceSchema;
    elseif any(selectedFcns) && ~isempty(gcbs)
        schemaFcns{end+1} = @ChangeFcnScopeSchema;
        schemaFcns{end+1} = @FcnCreatorLocalSchema;
    end
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
    sys = gcs; % save in case it changes
    
    [fcns, proto] = getCallableFunctions(sys);
    idx = functionGUI(fcns, proto); % let user make selection
    f = char(fcns(idx));
    p = char(proto(idx));
    
    if ~isempty(f)
        % load model is necessary
        i = regexp(f, '/', 'once');
        mdl = f(1:i-1);
        loaded = bdIsLoaded(mdl);
        if ~loaded
            load_system(mdl);
        end
        
        createFcnCaller(sys, f, p);
        
        % close model is necessary
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
    anyGlobal = any(contains(scopes, char(Scope.Global)));
    anyScoped = any(contains(scopes, char(Scope.Scoped)));
    anyLocal = any(contains(scopes, char(Scope.Local)));
    if anyScoped || anyLocal
        schema.childrenFcns{end+1} = @GlobalFcnSchema;
    end
    if anyGlobal || anyLocal
        schema.childrenFcns{end+1} = @ScopedFcnSchema;
    end
    if  anyGlobal || anyScoped || anyLocal
        schema.childrenFcns{end+1} = @LocalFcnSchema;
    end
    
    % If there ae functions selected, but the functions don't have a scope
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
    setFcnScope(gcbs, 0, '');
end

%% Define action: Convert to Scoped
function schema = ScopedFcnSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'To Scoped Exported Function';
    schema.userdata = 'convertToScopedFcn';
    schema.callback = @convertToScopedFcnCallback;
end

function convertToScopedFcnCallback(callbackInfo)
    setFcnScope(gcbs, 1, '');
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
    setFcnScope(gcbs, 2, '');
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
        setFcnScope(gcbs, 2, subsystem);
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
        fprintf('Guideline MJ_00001 ''Simulink Function Placement'' violations: ');
        if isempty(blocks)
            fprintf('None\n');
        else
            fprintf('\n');
            for i = 1:length(blocks)
                fprintf('\t%s can be moved to %s\n', replaceNewline(blocks{i}), replaceNewline(locations{i}));
            end
        end
    end
    if guidelines(2)
        blocks = guideline0002(sys);
        fprintf('Guideline MJ_00002 ''Simulink Function Scope'' violations: ');
        if isempty(blocks)
            fprintf('None\n');
        else
            fprintf('\n');
            for i = 1:length(blocks)
                fprintf('\t%s\n', replaceNewline(blocks{i}));
            end
        end
    end
    if guidelines(3)
        [blocks, shadows] = guideline0003(sys);
        fprintf('Guideline MJ_00003 ''Simulink Function Shadowing'' violations: ');
        if isempty(blocks)
            fprintf('None\n');
        else
            fprintf('\n');
            for i = 1:length(blocks)
               if ~isempty(shadows{i})
                    fprintf('\t%s is shadowed by:\n\t\t%s\n', replaceNewline(blocks{i}), strjoin(replaceNewline(shadows{i}), '\n\t\t'));
               end         
            end
        end        
    end
    if guidelines(4)
        blocks = guideline0004(sys);
        fprintf('Guideline MJ_00004 ''Use of Base Workspace'' violations: ');
        if isempty(blocks)
            fprintf('None\n');
        else
            fprintf('\n');
            for i = 1:length(blocks)
                fprintf('\t%s\n', replaceNewline(blocks{i}));       
            end
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
        answer = questdlg('An interface already exists. Do you wish to replace it?', 'Interface Exists');
        if strcmp(answer, 'Yes')
            % Delete old representation
            eval([objName '.delete;'])

            % Create new interface
            eval([objName ' = Interface(sys);']);
            eval([objName ' = ' objName '.model();']);
        end
    else
        eval([objName ' = Interface(sys);']);
        eval([objName ' = ' objName '.model();']);        
    end
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
    eval([objName ' = Interface(sys);']);
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
    if interface_exists(bdroot(gcs))
        schema.state = 'Enabled';
    else
        schema.state = 'Disabled';
    end
end

function deleteInterfaceCallback(callbackInfo)
    sys = bdroot(gcs);
    objName = [sys '_InterfaceObject'];
    eval(['global ' objName ';']);
    
    if interface_exists(sys)
        eval([objName ' = delete(' objName ');']);
        eval(['clear global ' objName ';']);
    else
        warning('No interface representation is present in the moodel.');
    end
    
    garbageCollection();
end

function e = interface_exists(sys)
    % INTERFACE_EXISTS Determine if there exists an interface object for a model.
    objName = [sys '_InterfaceObject'];
    eval(['global ' objName ';']);
    eval(['objEmpty = isempty(' objName ');']);
    
    if ~objEmpty
        % Check that the object refers to the same model instance
        eval(['objHdl = ' objName '.getHandle;']);
        sysHdl = get_param(sys, 'Handle');
        sameHdl = (objHdl == sysHdl);
        if sameHdl
            e = true;
        else
            e = false;
        end
    else
        e = false;
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