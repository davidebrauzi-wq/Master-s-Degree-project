function [x, f, i] = truncated_newton_method(obj, grad, hess, x, eps, epsilon, eta)

    normGrad = inf;
    i = 0;

    Q = hess(x);
    g = grad(x);

    while (normGrad >= eps)
        d = -g;
        
        k = 0;
        while (d'*Q*d > epsilon*norm(d, 2))
            alpha = -g'*d/(d'*Q*d);
    
            beta = g'*Q*d/(d'*Q*d);
    
            d = -g + beta*d;

            if (norm(hess(d),2) <= eta*norm(g,2)*min(1/(k+1),norm(g,2)))
                break
            end

            k = k + 1;
        end

        x = x + alpha*d;

        Q = hess(x);
        g = grad(x);

        normGrad = norm(g, inf);
        i = i + 1;
    end
    f = obj(x);
end