function [x, f, i] = gradient_method(obj, grad, x, eps)

    normGrad = inf;
    i = 0;

    g = grad(x);

    while (normGrad >= eps)
        d = -g;

        alpha = armijo_method(obj, g, x, d);

        x = x + alpha*d;

        g = grad(x);
        normGrad = norm(g, inf);
        i = i + 1;
    end
    f = obj(x);
end