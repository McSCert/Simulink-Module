classdef InterfaceItem
    properties
        Handle
        Name
        Fullpath
        Position
        Type
        Dimensions
        InterfaceHandle
    end
    properties (Access = private)
        
    end
    methods (Access = public)
         function obj = InterfaceItem(handle)
             if nargin == 1
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
            obj.Name = replaceNewline(get_param(obj.Handle, 'Name'));
            obj.Fullpath = replaceNewline(getfullname(obj.Handle));
            obj.Position = get_param(obj.Handle, 'Position');
            obj.Type = char(getDataType(obj.Handle));   
            obj.Dimensions = char(getDimensions(obj.Handle));
        end
    end
end
function s = replaceNewline(string)
    s =  regexprep(string, '[\n\r]+', ' ');
end