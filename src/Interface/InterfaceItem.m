classdef InterfaceItem
    properties
        BlockType           % BlockType.
        InterfaceType       % Input, Import, Output, or Export.
        Handle              % Handle of the item that is on the interface.
        Name                % Name.
        Fullpath            % Fullpath.
        DataType            % Output or input types.
        Dimensions          % Struct of Inport and Outport dimensions.
        SampleTime          % SameTime.
        
        % Visual Representation
        InterfaceHandle     % If the block is represented on the interface by another 
                            % block, this is the handle to that block (not
                            % applicable for Inports and Outports).
        GroundHandle        % Handle(s) of Ground blocks (or Goto for ports).
        TerminatorHandle    % Handle(s) of Terminators blocks (or From for ports).
    end
    methods (Access = public)
        function obj = InterfaceItem(handle)
            if nargin == 1
                % Perform checks before creating an InterfaceItem
                [valid, ~] = itemTypeCheck(handle);
                if ~valid
                    error(['Block ''' get_param(obj.Handle, 'Name') ''' is not a valid InterfaceItem.']);
                end

                obj.Handle = inputToNumeric(handle);
                obj = autoGetData(obj);    
            elseif nargin > 1
                error('Too many inputs provided.');
            else
                error('Not enough inputs provided.');
            end
        end
        function b = eq(obj1, obj2)
        % EQ Check if two InterfaceItems are equal.
        %
        %   Inputs:
        %       obj1    InterfaceItem.
        %       obj2    InterfaceItem.
        %
        %   Outputs:
        %       b       Whether or not inputs are equal (1), or not (0).
        
             if obj1.Handle == obj2.Handle
                 b = true;
             else
                 b = false;
             end
        end
        function print(obj)
        % PRINT Print the item to the Command Window.
        %
        %   Inputs:
        %       obj    InterfaceItem.
        %
        %   Outputs:
        %       N/A
         
             % TODO: Currently assumes one sample time. There can be
            % multiple times
         
            if isSimulinkFcn(obj.Handle)
                argsIn = find_system(obj.Handle, 'SearchDepth', 1, 'BlockType', 'ArgIn');
                argsOut = find_system(obj.Handle, 'SearchDepth', 1, 'BlockType', 'ArgOut');
                nIn = length(argsIn);
                nOut = length(argsOut);
            else
                handles = get_param(obj.Handle, 'PortHandles');
                nIn = length(handles.Inport);
                nOut = length(handles.Outport);
            end
            
            oneInport = (nIn == 1);
            oneOutport = (nOut == 1);

            dt   = obj.DataType;
            dim  = obj.Dimensions;
            time = obj.SampleTime;
            
            if strcmp(obj.BlockType, 'ModelReference') || isLibraryLink(obj.Handle)
                if isempty(time)
                    time_i = 'N/A';
                elseif size(time,1) > 1 || size(time,2) > 1 % Non-scalar
                    time_i = char(strjoin(string(time), ', ')); 
                    time_i = ['[' time_i ']'];
                else
                    time_i = time;
                end
                
                if isnumeric(time_i) && rem(abs(time_i), 1) == 0
                    time_format = '%i';
                elseif ischar(time_i)
                    time_format = '%s';
                else
                    time_format = '%.4f';
                end
                fprintf(['%s, N/A, N/A, ' time_format '\n'], obj.Fullpath, time_i);
                return
            end
                
            % Only 1 port
            if xor(oneInport, oneOutport) 
                
                if oneInport
                    dt = dt.Inport;
                    dim = dim.Inport;
                else
                    dt = dt.Outport;
                    dim = dim.Outport;
                end
               
                % Account for data that is empty or an array
                if isempty(dt)
                    dt = 'N/A';
                end
                
                if isempty(dim)
                    dim = 'N/A';
                elseif size(dim,1) > 1 || size(dim,2) > 1 % Non-scalar
                    dim = ['[' regexprep(num2str(dim), ' +', ', ') ']'];
                end

                if isempty(time)
                    time_i = 'N/A';
                elseif size(time,1) > 1 || size(time,2) > 1 % Non-scalar
                    time_i = char(strjoin(string(time), ', ')); 
                    time_i = ['[' time_i ']'];
                else
                    time_i = time;
                end
                
                % Account for different formatting                
                dim_format = '%i';
                if ischar(dim)
                    dim_format = '%s';
                end
                
                if isnumeric(time_i) && rem(abs(time_i), 1) == 0
                    time_format = '%i';
                elseif ischar(time_i)
                    time_format = '%s';
                else
                    time_format = '%.4f';
                end
                
                % Print
                fprintf(['%s, %s, ' dim_format ', ' time_format '\n'], obj.Fullpath, dt, dim, time_i);
                
            % Multiple ports
            else
                fprintf('%s \n', obj.Fullpath);
                
                if nIn > 0
                    fprintf('\t\tIn:  ');
                    for i = 1:nIn
                        % Account for data that is empty or in an array
                        if isempty(dt.Inport)
                            dt_i = 'N/A';
                        else
                            dt_i  = dt.Inport(i,:);
                        end

                        if isempty(dim.Inport)
                            dim_i = 'N/A';
                        else
                            dim_i = dim.Inport(i);
                        end

                        if isempty(time)
                            time_i = 'N/A';
                        elseif size(time,1) > 1 || size(time,2) > 1 % Non-scalar
                            time_i = char(strjoin(string(time), ', ')); 
                            time_i = ['[' time_i ']'];
                        else
                            time_i = time;
                        end   
                        
                        % Separate from previous port
                        if i ~= 1
                            fprintf('; ');
                        end
                        if nIn > 4 && i > 1
                            fprintf('\n\t\t    ');
                        end
                        
                        % Account for different formatting                
                        if ischar(dim_i)
                            dim_format = '%s';
                        else
                            dim_format = '%i';
                        end
                        
                        time_format = '%.4f';
                        if isnumeric(time_i) && rem(abs(time_i), 1) == 0
                            time_format = '%i';
                        elseif ischar(time_i)
                            time_format = '%s';
                        else
                            time_format = '%.4f';
                        end
                        
                        % Print
                        fprintf(['%s, ' dim_format ', ' time_format], dt_i, dim_i, time_i);
                    end
                end
                
                if nOut > 0
                    if nIn > 0
                        fprintf('\n');
                    end
                    fprintf('\t\tOut: ');
                    for i = 1:nOut
                        % Account for data that is empty or in an array
                        if isempty(dt.Outport)
                            dt_i = 'N/A';
                        else
                            dt_i  = dt.Outport(i,:);
                        end

                        if isempty(dim.Outport)
                            dim_i = 'N/A';
                        else
                            dim_i = dim.Outport(i);
                        end

                        if isempty(time)
                            time_i = 'N/A';
                        elseif size(time,1) > 1 || size(time,2) > 1 % Non-scalar
                            time_i = char(strjoin(string(time), ', ')); 
                            time_i = ['[' time_i ']'];
                        else
                            time_i = time;
                        end   

                        % Separate from previous port
                        if i ~= 1
                            fprintf('; ');
                        end
                        if nIn > 4 && i > 1
                            fprintf('\n\t\t     ');
                        end
                       
                        % Account for different formatting                
                        if ischar(dim_i)
                            dim_format = '%s';
                        else
                            dim_format = '%i';
                        end
                        
                        if isnumeric(time_i) && rem(abs(time_i), 1) == 0
                            time_format = '%i';
                        elseif ischar(time_i)
                            time_format = '%s';
                        else
                            time_format = '%.4f';
                        end
                        
                        % Print
                        fprintf(['%s, ' dim_format ', ' time_format], dt_i, dim_i, time_i);
                    end
                    fprintf('\n');                    
                end
            end
        end
        function obj = deleteFromModel(obj)
            % DELETEFROMMODEL Delete the representation of the item in the
            % model.
            if any2(strcmp(obj.BlockType, {'Inport', 'Outport'}))
                obj = deleteGrndTrm(obj);
                % Move inport/outport back
                try
                    moveToConnectedPort(obj.InterfaceHandle, 30);
                    redraw_block_lines(obj.InterfaceHandle, 'AutoRouting', 'smart');
                catch ME 
                    if ~strcmp(ME.identifier, 'Simulink:Commands:InvSimulinkObjHandle') % The model was closed
                        rethrow(ME)
                    end
                end
            else
                try
                    delete(obj.InterfaceHandle);
                    obj = deleteGrndTrm(obj);
                catch ME
                    if ~strcmp(ME.identifier, 'MATLAB:hg:udd_interface:CannotDelete')  % Already deleted
                        rethrow(ME)
                    end
                end
            end
            obj.InterfaceHandle = [];
        end
    end 
    methods (Access = private)
        function obj = autoGetData(obj)
        % AUTOGETDATA Automatically populate the item's fields based on the model.
        %
        %   Inputs:
        %       obj     InterfaceItem.
        %
        %   Outputs:
        %
        %       obj     InterfaceItem.
        
            % BLOCKTYPE
            obj.BlockType = get_param(obj.Handle, 'BlockType');
            
            % INTERFACETYPE
            [~, obj.InterfaceType] = itemTypeCheck(obj.Handle);
            
            % NAME
            obj.Name = replaceNewline(get_param(obj.Handle, 'Name'));
            
            % FULLPATH
            obj.Fullpath = replaceNewline(getfullname(obj.Handle));

            % DATATYPE
            obj.DataType = getDataType_MJ(obj.Handle);

            % DIMENSIONS
            obj.Dimensions = getDimensions(obj.Handle);
            
            % SAMPLE TIME
            obj.SampleTime = getSampleTime(obj.Handle);
            
            % INTERFACEHANDLE
            % Added when the interface is modelled only.
        end
        function obj = deleteGrndTrm(obj)
        % DELETEGRNDTRM Delete the ground and terminator elements with their
        %   lines.
            for i = 1:length(obj.GroundHandle)
                g = obj.GroundHandle(i);
                if ishandle(g)
                    if strcmp(obj.BlockType, 'Outport')
                        goto2Line(bdroot(obj.Fullpath), obj.GroundHandle);
                    else
                        lines = get_param(g, 'LineHandles');
                        delete(lines.Outport);
                        delete(g);
                    end                    
                end
            end
            obj.GroundHandle = [];
            
            for j = 1:length(obj.TerminatorHandle)
                t = obj.TerminatorHandle(j);
                if ishandle(t)
                                        
                    if strcmp(obj.BlockType, 'Inport')
                        goto2Line(bdroot(obj.Fullpath), obj.TerminatorHandle);
                    else
                        lines = get_param(t, 'LineHandles');
                        delete(lines.Inport);
                        delete(t);
                    end   
                end
            end
            obj.TerminatorHandle = [];
        end
    end
end
function [valid, type] = itemTypeCheck(handle)
% ITEMTYPECHECK Check if the item is one of the supported BlockTypes. Return the
%   InterfaceType.
%
%   Inputs:
%       handle  Handle to a block.
%
%   Outputs:
%       valid   Whether or not it is a supported InterfaceItem block.
%       type    'Input', 'Import', 'Output', 'Export'

    blocktype  = get_param(handle, 'BlockType');
    in  = {'Inport', 'FromFile', 'FromWorkspace', 'FromSpreadsheet', 'DataStoreRead'};
    out = {'Outport', 'ToFile', 'ToWorkspace', 'DataStoreWrite'};

    % Note: Both library links and Simulink functions are potentially of BlockType
    % SubSystem, so an extra check will need to be done
    
    if isempty(blocktype)
        type = '';
        valid = false;
        return
    end
    
    if any2(find(strcmp(in, blocktype)))
        type = 'Input';
        valid = true;
    elseif any2(find(strcmp(out, blocktype)))
        type = 'Output';
        valid = true;
    elseif isSimulinkFcn(handle)
        type = 'Export';
        valid = true;
    else
        type = '';
        valid = false;
    end   
end