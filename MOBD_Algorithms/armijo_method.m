function [alpha] = armijo_method(obj, grad, x, d)

    delta1 = 1;
    delta2 = 0.5;
    gamma = 1e-2;
    
    alpha = delta1;

    x_trial = x + alpha*d;
    f_trial = obj(x_trial);
    f = obj(x);
    while (f_trial > f + alpha*gamma*grad'*d)
        alpha = alpha*delta2;
        x_trial = x + alpha*d;
        f_trial = obj(x_trial);
    end
end