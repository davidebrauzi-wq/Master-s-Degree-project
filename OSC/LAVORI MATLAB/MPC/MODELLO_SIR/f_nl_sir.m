function x_incr = f_nl_sir(v,p,omega,ni)
    x_incr = zeros(3,1);
    x_incr(1) = v(1) - p*omega*v(1)*v(2);
    x_incr(2) = (1 - ni) * v(2) + p*omega*v(1)*v(2);
    x_incr(3) = v(3) + ni*v(2);
end