classdef InterfaceItem
    properties
        BlockType           % BlockType.
        InterfaceType       % Input or output.
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
    end
    methods (Access = private)
        function obj = autoGetData(obj)
            
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
            
            % INTERFACEBLOCK
            % Added when the interface is modeled only.
        end
    end
end
function [valid, type] = itemTypeCheck(handle)
% ITEMTYPECHECK Check if the item is one of the supported BlockTypes. Return the
%   InterfaceType.

    bt = get_param(handle, 'BlockType');
    in = {'Inport', 'FromFile', 'FromWorkspace', 'FromSpreadsheet', 'DataStoreRead'};
    out = {'Outport', 'ToFile', 'ToWorkspace', 'DataStoreWrite', 'SubSystem'};
    
    if isempty(bt)
        type = '';
        valid = false;
        return
    end
    
    if any2(find(strcmp(in, bt)))
        type = 'In';
        valid = true;
    elseif any2(find(strcmp(out, bt)))
        type = 'Out';
        valid = true;
    else
        type = '';
        valid = false;
    end    
end
function s = replaceNewline(string)
    s =  regexprep(string, '[\n\r]+', ' ');
end