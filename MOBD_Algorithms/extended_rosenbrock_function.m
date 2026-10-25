% Extended Rosenbrock Function

function [obj, grad, hess] = extended_rosenbrock_function(n,c)
    
    % check input and output
    if (nargin < 2)
        error('Too few input arguments.');
    end
    if (nargout < 1)
        error('Too few output arguments.');
    end
    if (n < 1 || mod(n,2) ~= 0)
        error('n must be even.')
    end
    
    function f = funct(x)
        if (size(x,1) ~= n || size(x,2) ~= 1)
            error('The input argument has wrong dimension.');
        end
        f = sum(c*(x(2:2:n)-x(1:2:n-1).^2).^2 + (1e0-x(1:2:n-1)).^2);
    end
    obj = @funct;
    
    function g = gradient(x)
        if (size(x,1) ~= n || size(x,2) ~= 1)
            error('The input argument has wrong dimension.');
        end
        
        g = zeros(n,1);
        g(1:2:n-1) = 4e0*c*x(1:2:n-1).*(x(1:2:n-1).*x(1:2:n-1)-x(2:2:n)) + 2e0*(x(1:2:n-1)-1e0);
        g(2:2:n) = 2e0*c*(x(2:2:n)-x(1:2:n-1).*x(1:2:n-1));
        
    end
    grad = @gradient;

    function h = hessian(x)
        if (size(x,1) ~= n || size(x,2) ~= 1)
            error('The input argument has wrong dimension.');
        end
        
        h = zeros(n,n);
        h(1:2*n+2:n*(n-1)-1) = 4e0*c*(3e0*x(1:2:n-1).*x(1:2:n-1) - x(2:2:n)) + 2e0;
        h(n+2:2*n+2:n*n) = 2e0*c;

        h1 = -4e0*c*x(1:2:n-1);

        h(2:2*n+2:n*(n-1)) = h1;
        h(n+1:2*n+2:n*n-1) = h1;
        
    end
    hess = @hessian;
    
end