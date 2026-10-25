function [x, f, i] = spectral_gradient_method(obj, grad, x, eps, c_min, c_max)
    
    normGrad = inf;
    i = 0;

    x_old = 0;
    g_old = 0;
    g = grad(x);

    while (normGrad >= eps)

        s = x - x_old;
        y = g - g_old;
        c = norm(s, 2)/(s'*y);

        if (c < c_min)
            c = c_min;
        end

        if (c > c_max)
            c = c_max;
        end

        d = -c*g;

        alpha = armijo_method(obj, g, x, d);

        x_old = x;
        g_old = g;
        
        x = x + alpha*d;
        
        g = grad(x);
        normGrad = norm(g, inf);

        i = i + 1;
    end
    f = obj(x);
end