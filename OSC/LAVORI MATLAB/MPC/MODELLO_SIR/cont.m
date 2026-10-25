function [Bb] = cont(v,omega)
    Bb = zeros(3,1);
    Bb = [-omega*v(1)*v(2);
          omega*v(1)*v(2);
          0];
end

% genero correttamente il gradiente di f