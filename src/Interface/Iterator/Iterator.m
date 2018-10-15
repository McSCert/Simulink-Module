classdef Iterator < handle
   %ITERATOR Abstract Class for Iterator OOP Design Pattern
   %  Intent:  Provide a way to access the elements of an aggregate object
   %  sequentially without exposing its underlying representation [1].
   %  This design pattern is also known as Cursor.
   %
   %  Motivation:  An example of an aggregate object is an instance of the
   %  List ADT.  Consequently, an iterator can be used to traverse the
   %  elements of a list with a set of high-level abstract operations.
   %  These operations may be implemented within the List ADT but as
   %  Gamma et al.[1] wonderfully puts it, the key idea in this pattern
   %  is to take the responsibility for access and traversal out of the
   %  list object and put it into an iterator object - given the iterator
   %  describes behaviour whilst the list describes a collection.
   %
   %  Implementation:  The Iterator abstract class is used purely to
   %  specify the requirements of its concrete implementation.  Since
   %  MATLAB® and MATLAB OOP is loosely typed, the appealing software
   %  engineering approach of polymorphic iteration is not supported should
   %  the user want to easily implement different realisations of the
   %  Iterator.  Further, this abstraction could be implemented as an
   %  external/active or internal/passive iterator -
   %  External := the onus is on the client to advance the traversal and
   %  request next elements.
   %  Internal := the client can supply an operation to the iterator to
   %  perform over every element of a collection
   % 
   %  Refer to pp.257-271 Gamma et al.[1] for more information on the
   %  Iterator (Behavioural) Design Pattern.
   % 
   %  Written by Bobby Nedelkovski
   %  MathWorks Australia
   %  Copyright 2009-2010, The MathWorks, Inc.
   %
   %  Reference:
   %  [1] Gamma, E., Helm, R., Johnson, R. and Vlissides, J.
   %      Design Patterns : Elements of Reusable Object-Oriented Software.
   %      Boston: Addison-Wesley, 1995.

   % 2009-Oct-06: Change abstract class property from abstract to
   % concrete protected.
   % Common properties of all Iterator implementations.
   properties(Access=protected)
      collection;  % A collection of elements to traverse
   end
   
   % 2010-Jul-27: Included comments to work with arrays of Iterator.
   methods(Abstract) % Public Access
      % Advance to the next element in sequence in the collection and
      % return it.
      % Input:
      %    obj  = array of instances of concrete implementation of this
      %           abstraction
      % Output:
      %    elts = cell array of next elements in each sequence for each
      %           corresponding collection - an empty array is returned for
      %           traversals that have been exceeded - a single element is
      %           returned if only a single list is traversed
      % Preconditions:
      %    check that each Iterator has a next element using 'hasNext()'
      % Postconditions:
      %    a reference to the location of the next element in sequence for
      %    each corresponding collection is stored
      elts = next(obj);
      
      % Check if the there is another element in the traversal of the
      % collection.
      % Input:
      %    obj  = array of instances of concrete implementation of this
      %           abstraction
      % Output:
      %    next = array of boolean values 'true' if elements remaining in
      %           each corresponding traversal
      % Preconditions:
      %    <none>
      % Postconditions:
      %    <none>
      next = hasNext(obj);
      
      % Overloaded.  Reset the Iterator to the first element in the
      % collection.
      % Input:
      %    obj = array of instances of concrete implementation of this
      %          abstraction
      % Output:
      %    <none>
      % Preconditions:
      %    <none>
      % Postconditions:
      %    a reference to the beginning of each collection is stored
      reset(obj);
   end % methods
end % classdef
