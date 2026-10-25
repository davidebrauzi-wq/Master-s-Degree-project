function [Aa] = matrice(v,p,omega,ni)
    Aa = zeros(3,3);
    Aa = [1 - p*omega*v(2) -p*omega*v(1) 0;
          p*omega*v(2) (1-ni)+p*omega*v(1) 0;
          0 ni 1];
end

% genera correttamente la matrice Aa


