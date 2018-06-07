classdef Scope < uint32
    % Scope values, for readability
   enumeration
      Global (0)  % Simulink Function visibility parameter is 'global' (exported from model)
      Scoped (1)  % Simulink Function visibility parameter is 'scoped', and function is placed at top level (exported from model)
      Local  (2)  % Simulink Function visibility parameter is 'scoped', and function is placed in subsystem (local to model)
   end
end