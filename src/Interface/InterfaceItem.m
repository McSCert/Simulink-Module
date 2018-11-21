classdef InterfaceItem
    properties
        BlockType           % BlockType.
        InterfaceType       % Input, Import, Output, or Export.
        Handle              % Handle of the item that is on the interface.
        Name                % Name.
        Fullpath            % Fullpath.
        DataType            % Output or input types.
        Dimensions          % Dimensions, if applicable.
        
        % Visual Representation
        InterfaceHandle     % If the block is represented on the interface by another 
                            % block, this is the handle to that block (not
                            % applicable for Inports and Outports).
        TerminatorHandle    % Handle(s) of Terminators blocks.
        GroundHandle        % Handle(s) of Ground blocks.
    end
    properties (Access = private)
        
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
        %
        %       b       Whether or not inputs are equal (1), or not (0).
        
             if obj1.Handle == obj2.Handle
                 b = true;
             else
                 b = false;
             end
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
            obj.DataType = char(getDataType(obj.Handle));

            % DIMENSIONS
            obj.Dimensions = char(getDimensions(obj.Handle));
            
            % INTERFACEHANDLE
            % Added when the interface is modeled only.
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
    im  = {'ModelReference'};
    out = {'Outport', 'ToFile', 'ToWorkspace', 'DataStoreWrite'};

    % Note: Both library links and Simulink functions are of BlockType
    % SubSystem, so extra check will need to be done
    
    if isempty(blocktype)
        type = '';
        valid = false;
        return
    end
    
    if any2(find(strcmp(in, blocktype)))
        type = 'Input';
        valid = true;
    elseif any2(find(strcmp(out, blocktype)))
        type = 'Outout';
        valid = true;
    elseif any2(find(strcmp(im, blocktype))) || isLibraryLink(handle)
        type = 'Import';
        valid = true;
    elseif isSimulinkFcn(handle)
        type = 'Export';
        valid = true;
    else
        type = '';
        valid = false;
    end   
end