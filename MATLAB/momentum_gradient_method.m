function [x, f, i] = momentum_gradient_method(obj, grad, x, eps, beta)

    normGrad = inf;
    i = 0;

    x_old = 0;
    g = grad(x);

    while (normGrad >= eps)
        d = -g;

        alpha = armijo_method(obj, g, x, d);

        x = x + alpha*d + beta*(x-x_old);

        g = grad(x);
        x_old = x;

        normGrad = norm(g, inf);
        i = i + 1;
    end
    f = obj(x);
end