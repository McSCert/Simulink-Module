%% Register custom menu function to beginning of Simulink Editor's context menu
function sl_customization(cm)
    cm.addCustomMenuFcn('Simulink:PreContextMenu', @getSLFcnTool);
end

%% Define custom menu function: Changing Scope
function schemaFcns = getSLFcnTool(callbackInfo)
    schemaFcns = {};
    selection = find_system(gcs, 'Type', 'block', 'Selected', 'on');
    selectedFcns = isSimulinkFcn(selection);

    if isempty(gcbs)
        schemaFcns{end+1} = @FcnCreatorSchema;
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

    % If there ae functions selected, but the functions don't have a scope
    if isempty(schema.childrenFcns)
        schema.state = 'Disabled';
    end
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