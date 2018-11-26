classdef InterfaceHeader
    properties
        Label
        Handle
    end
    methods (Access = public)
        function obj = InterfaceHeader(label)
            obj.Label = label;
        end
    end
end