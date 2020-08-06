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
            obj = obj.update;
            try
                delete(obj.Handle);
            catch ME
                if ~strcmp(ME.identifier, 'MATLAB:hg:udd_interface:CannotDelete')
                    rethrow(ME)
                end
            end
            obj.Handle = [];
        end
        function obj = update(obj)

            if isempty(obj.Handle)
                return
            end
            
            sys = bdroot(gcs);
            path = [sys '/' obj.Label];
            disp(['Before: ' obj.Handle]);
            obj.Handle = get_param(path, 'Handle');
            disp(['After: ' obj.Handle]);
        end
    end
end