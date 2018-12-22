function types = getDataType_MJ(blocks)
% GETDATATYPE_MJ Return the block data type, for each Inport and Outport.
%
%   Inputs:
%       blocks  Array of block paths or handles.
%
%   Outputs:
%       types   Cell array of structs.
%
%   Example:
%       >> getDataType_MJ('model/In1')
%           ans =
%           struct with fields:  
%               Inport: []    
%               Outport: 'Inherit: auto'

    blocks = inputToNumeric(blocks);
    
    % Get block types
    blockTypes = get_param(blocks, 'BlockType');
    if ~iscell(blockTypes) || length(blockTypes) == 1
        blockTypes = {blockTypes};
    end

    % Create empty struct cell array
    types = struct('Inport', [], 'Outport', []);
    types = repmat({types}, size(blocks));
    
    for i = 1:length(blocks)
        b = blocks(i);
 
        if any(find(strcmp(blockTypes{i}, {'Inport', 'FromFile'})))
            types{i}.Outport = get_param(b, 'OutDataTypeStr');
            
        elseif strcmp(blockTypes{i}, 'FromSpreadsheet')
            t = get_param(b, 'OutDataTypeStr');
            portHandles = get_param(b, 'PortHandles');
            nOut = length(portHandles.Outport);
            types{i}.Outport = repmat(t, nOut, 1);
            
        elseif strcmp(blockTypes{i}, 'Outport')
            types{i}.Inport = get_param(b, 'OutDataTypeStr');
            
        elseif strcmp(blockTypes{i}, 'ToFile')
            types{i}.Inport = get_param(b, 'SaveFormat');
            
        elseif strcmp(blockTypes{i}, 'ToWorkspace')
            workspaceData = evalin('base', 'whos');
            idx = ismember({workspaceData.name}, get_param(b, 'VariableName'));
            if any(idx)
                match = workspaceData(idx);
                types{i}.Inport = match.class;
            else
                types{i}.Inport = get_param(gcb, 'OutDataTypeStr');
            end
            
        elseif strcmp(blockTypes{i}, 'FromWorkspace')
            workspaceData = evalin('base', 'whos');
            idx = ismember({workspaceData.name}, get_param(b, 'VariableName'));
            if any(idx)
                match = workspaceData(idx);
                types{i}.Outport = match.class;
            else
                types{i}.Outport = get_param(gcb, 'OutDataTypeStr');
            end
            
        elseif strcmp(blockTypes{i}, {'DataStoreRead'})
            [isGlobal, obj, ~] = isGlobalDataStore(b);
            if isGlobal
                types{i}.Outport = obj.DataType;
            else
                error(['Block ''' getfullname(b) ''' is not a global data store and should not be on the interface.']);
            end       
            
        elseif strcmp(blockTypes{i}, {'DataStoreWrite'})
            [isGlobal, obj, ~] = isGlobalDataStore(b);
            if isGlobal
                types{i}.Inport = obj.DataType;
            else
                error(['Block ''' getfullname(b) ''' is not a global data store and should not be on the interface.']);
            end  
            
        elseif isSimulinkFcn(b)
            [intype, outtype] = getFcnArgsType(b);
            types{i}.Inport = char(intype);
            types{i}.Outport = char(outtype); 
            
        elseif isLibraryLink(b)
            %types{i} = 'N/A';
            
        elseif strcmp(blockTypes{i}, 'ModelReference')
            %types{i} = 'N/A';
        end
    end
    
    % Just return the struct if it's for one element only
    if length(types) == 1
        types = types{1};
    end
end