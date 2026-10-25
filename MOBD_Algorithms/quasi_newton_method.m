function [x, f, i] = quasi_newton_method(obj, grad, x, eps, str)

    normGrad = inf;
    i = 0;

    H = eye(size(x,1), size(x,1));
    x_old = zeros(size(x,1), 1);
    g_old = grad(x_old);
    g = grad(x);

    while (normGrad >= eps)
        s = x - x_old;
        y = g - g_old;

        d = -H*g;

        alpha = armijo_method(obj, g, x, d);

        x_old = x;
        g_old = g;
        
        x = x + alpha*d

        g = grad(x);

        delta_H = (s - H*y)*(s - H*y)'/((s - H*y)'*y);
        H = H + delta_H;

        normGrad = norm(g, inf);
        i = i + 1;
    end
    f = obj(x);
end