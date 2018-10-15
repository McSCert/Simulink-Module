classdef InterfaceIterator < Iterator

    properties(Access = private)
        loc;    % Current location of traversal.
    end
   
	methods   
        function newObj = InterfaceIterator(varargin)
            narginchk(0,1);

            if nargin == 0
                % Store reference to empty interface and position iterator at start.
                newObj.collection = Interface();
                newObj.loc        = 1;
            else
                % Store reference to interface and position iterator at start.
                newObj.collection = varargin{1};
                newObj.loc        = 1;
            end
        end
      
        % Concrete implementation. See Iterator superclass.
        function el = next(obj)
        % NEXT Advance to the next element in sequence in the collection and
        %   return it.
        %
        %   Inputs:
        %       obj     InterfaceIterator object.
        %
        %   Outputs:
        %       el      Next element in the interface.
        
            if obj.hasNext()
                el = obj.collection.get(obj.loc);
                obj.loc = obj.loc + 1;
            end
        end
      
        % Concrete implementation. See Iterator superclass.
        function next = hasNext(obj)
        % HASBEXT Check if the there is another element in the traversal of the
        %   collection.
        %
        %   Inputs:
        %       obj     InterfaceIterator object.
        %
        %   Outputs:
        %       next    Whether the is another interface element next (1), or 
        %               not (0);
        
            next = obj.loc <= obj.collection.length();
        end

        % Concrete implementation. See Iterator superclass.
        function reset(obj)
        % RESET Position iterator at the start.
        %
        %   Inputs:
        %       obj     InterfaceIterator object.
        %
        %   Outputs:
        %      N/A
        
            obj.loc = 1;
        end
   end
end
