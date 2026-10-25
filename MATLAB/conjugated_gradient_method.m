function [x, f, i] = conjugated_gradient_method(obj, grad, hess, x, eps)

    normGrad = inf;
    i = 0;

    g = grad(x);
    d = -g;

    while (normGrad >= eps)

        Q = hess(x);

        alpha = -g'*d/(d'*Q*d);

        x = x + alpha*d;

        g = grad(x);

        beta = g'*Q*d/(d'*Q*d);

        d = -g + beta*d;

        normGrad = norm(g, inf);
        i = i + 1;
    end
    f = obj(x);
end