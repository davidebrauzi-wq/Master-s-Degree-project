function [x, f, i] = newton_method(obj,grad,hess,x,eps)

    normGrad = inf;
    i = 0;

    while (normGrad >= eps)
        h = hess(x);
        g = grad(x);
        x = x - h\g;

        normGrad = norm(g, inf);
        
        i = i + 1;
    end
    f = obj(x);
end