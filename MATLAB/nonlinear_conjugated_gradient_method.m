function [x, f, i] = nonlinear_conjugated_gradient_method(obj, grad, hess, x, eps, str)

    normGrad = inf;
    i = 0;

    x_old = zeros(size(x,1),1);
    g = grad(x);
    d = -g;

    while (normGrad >= eps)

        Q = hess(x);

        alpha = -g'*d/(d'*Q*d);

        x = x + alpha*d;

        g = grad(x);
        g_old = grad(x_old);

        x_old = x;
        
        if (strcmp(str, "Fletcher-Reeves"))
            beta = norm(g, 2)/norm(g_old, 2);
        elseif (strcmp(str, "Polyak-Polak-Ribiére"))
            beta = g'*(g-g_old)/norm(g_old, 2);
        else
            beta = g'*Q*d/(d'*Q*d);
        end

        d = -g + beta*d;

        normGrad = norm(g, inf);
        i = i + 1;
    end
    f = obj(x);
end