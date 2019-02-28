classdef InterfaceHeader
% INTERFACEHEADER The headers used in displaying an interface.
    properties
        Label   % Label text.
        Handle  % Handle of the annotation.
    end
    methods (Access = public)
        function obj = InterfaceHeader(label)
            obj.Label = label;
        end
        function obj = delete(obj)
            % DELETE Delete the header from the model.
            %
            % Inputs:
            try
                delete(obj.Handle);
            catch ME
                if ~strcmp(ME.identifier, 'MATLAB:hg:udd_interface:CannotDelete')
                    rethrow(ME)
                end
            end
            obj.Handle = [];
        end
    end
end