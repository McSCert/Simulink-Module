classdef InterfaceHeader
    properties
        Label   % Label text.
        Handle  % Handle of the annotation.
    end
    methods (Access = public)
        function obj = InterfaceHeader(label)
            obj.Label = label;
        end
    end
end