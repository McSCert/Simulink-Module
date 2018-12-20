function dims = getDimensions(blocks)
% GETDIMENSIONS Return the block dimensions, for each Inport and Outport.
%
%   Inputs:
%       blocks  Array of block paths or handles.
%
%   Outputs:
%       dims    Cell array of structs.
%
%   Example:
%       >> getDimensions{'model/In1')
%           ans = 
%             struct with fields:
%               Inport: 1
%               Outport: []

    blocks = inputToNumeric(blocks);

    % Get block types
    blockTypes = get_param(blocks, 'BlockType');
    if ~iscell(blockTypes) || length(blockTypes) == 1
        blockTypes = {blockTypes};
    end

    % Create empty struct cell array
    dims = struct('Inport', [], 'Outport', []);
    dims = repmat({dims}, size(blocks));
    
    for i = 1:length(blocks)
        b = blocks(i);
        
        if strcmp(blockTypes{i}, 'Inport')
            dims{i}.Outport = get_param(b, 'PortDimensions');
            
        elseif strcmp(blockTypes{i}, 'Outport')
            dims{i}.Inport = get_param(b, 'PortDimensions');
            
        elseif isSimulinkFcn(b) && ~isLibraryLink(b)
            [indim, outdim] = getFcnArgsDim(b);            
            dims{i}.Inport = cell2mat(indim);
            dims{i}.Outport = cell2mat(outdim);
        
        elseif strcmp(blockTypes{i}, 'DataStoreRead')
            [isGlobal, obj, ~] = isGlobalDataStore(b);
            if isGlobal
                dims{i}.Outport = obj.Dimensions;
            else
                error(['Block ''' getfullname(b) ''' is not a global data store and should not be on the interface.']);
            end
            
        elseif strcmp(blockTypes{i}, 'DataStoreWrite')
            [isGlobal, obj, ~] = isGlobalDataStore(b);
            if isGlobal
                dims{i}.Inport = obj.Dimensions;
            else
                error(['Block ''' getfullname(b) ''' is not a global data store and should not be on the interface.']);
            end               

        elseif any(find(strcmp(blockTypes{i}, {'ToFile', 'FromFile'})))
            %
            
        elseif strcmp(blockTypes{i}, 'FromSpreadsheet')
            % Only one dimensional signals are supported
            dims{i}.Outport = ones(1, length(get_param(gcb, 'PortConnectivity')));
             
        elseif strcmp(blockTypes{i}, 'ToWorkspace')
            workspaceData = evalin('base', 'whos');
            idx = ismember({workspaceData.name}, get_param(b, 'VariableName'));
            if any(idx)
                match = workspaceData(idx);
                dims{i}.Inport = match.size;
            end
            
        elseif strcmp(blockTypes{i}, 'FromWorkspace')
            workspaceData = evalin('base', 'whos');
            idx = ismember({workspaceData.name}, get_param(b, 'VariableName'));
            if any(idx)
                match = workspaceData(idx);
                dims{i}.Outport = match.size;
            end
            
        elseif strcmp(blockTypes{i}, 'ModelReference')
             %
        end
        
        
        try 
            dims{i}.Inport = str2num(dims{i}.Inport);
        catch
        end
        try 
            dims{i}.Outport = str2num(dims{i}.Outport);
        catch
        end
    end
    
    % Just return the struct if it's for one element only
    if length(dims) == 1
        dims = dims{1};
    end
end