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
end

%% Define action: Get Interface
function schema = InterfaceSchema(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Show Interface';
    schema.userdata = 'interface';
    schema.callback = @interface;
end

function interface(callbackInfo)
    
    % Check if interface object already exists for this model
    sys = bdroot(gcs);
    objName = [sys '_InterfaceObject'];
%     eval(['global ' objName ';']);
%     eval(['notempty_obj = ~isempty(' objName ');']);
%     
%     if notempty_obj
%         eval(['this_sys = strcmp(get_param(sys, ''name''), ' objName '.ModelName);'])
%         if this_sys
%             % don't recreate it because it already exists
%         else
%             eval([objName ' = Interface(sys);']);
%         end
%     else
%         eval([objName ' = Interface(sys);']);
%     end
%     
    eval([objName ' = Interface(sys);']);
    eval([objName ' = ' objName '.model;']);   
    
end