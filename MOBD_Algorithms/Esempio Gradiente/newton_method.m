% Newton method
%
% Metodi di Ottimizzazione per Big Data (Optimization Methods for Big Data)
% LM Ingegneria Informatica (Master's Degree in Computer Engineering)
% University of Rome "Tor Vergata"
%
% Author: Andrea Cristofari (e-mail: andrea.cristofari@uniroma2.it)
% Date: April 6th, 2023


function [x,f,alg_info] = newton_method(obj,grad,hess,x,opts)
    
    % Input arguments.
    %   obj: objective function
    %   grad: gradient of the objective function
    %   hess: Hessian of the objective function
    %   x: starting point
    %   opts: algorithm options (not mandatory input)
    %
    % Output arguments.
    %   x: solution found by the algorithm
    %   f: objective value at the solution found by the algorithm
    %   flag: integer describing the exit condition,
    %         0 if the stationarity condition is satisfied with the desired tolerance
    %         1 if the maximum number of function evalations is reached
    %         2 if the Newton system cannot be solved (Hessian matrix singular)
    
    
    % check input and output
    if (nargin < 4)
        error('Too few input arguments.');
    end
    if (nargout < 1)
        error('Too few output arguments.');
    end
    
    % set options
    eps_opt = 1e-5;
    max_it = 100000;
    verbosity = true;
    if (nargin == 5)
        if (~isscalar(opts) || ~isstruct(opts))
            error('The third input (which is optional) must be a structure.');
        end
        opts_field = fieldnames(opts);
        for i = 1:length(opts_field)
            switch char(opts_field(i))
                case 'eps_opt'
                    eps_opt = opts.eps_opt;
                    if (~isscalar(eps_opt) || ~isnumeric(eps_opt) || ~isreal(eps_opt) || eps_opt<0e0)
                       error('In the options, ''eps_opt'' must be a non-negative number.');
                    end
                case 'max_it'
                    max_it = opts.max_it;
                    if (~isscalar(max_it) || ~isnumeric(max_it) || ~isreal(max_it) || max_it<1e0)
                       error('In the options, ''max_it'' must be a number greater than or equal to 1.');
                    end
                    max_it = floor(max_it);
                case 'verbosity'
                    verbosity = opts.verbosity;
                    if (~isscalar(verbosity) || ~islogical(verbosity))
                       error('In the options, ''verbosity'' must be a logical.');
                    end
                otherwise
                    error('Not valid field name in the structure of options.');
            end
        end
    end
    
    % initialization
    it = 0;
    f = obj(x);
    g = grad(x);
    sup_norm_g = norm(g,Inf);
    flag = 0;
    
    % f_vec = zeros(max_it+1,1);
    % f_vec(1) = f;
    
    if (verbosity)
        fprintf('%s%i%s%.4e%s%.4e\n','it = ',it,', f = ',f,', sup-norm of g = ', sup_norm_g);
    end
    
    while (sup_norm_g > eps_opt)
        
        h = hess(x);
        
        % solve the Newton system
        s = -h\g;
        if (any(isinf(s) | isnan(s)))
            flag = 2;
            break;
        end
        
        % set the new point
        x = x + s;
        f = obj(x);
        g = grad(x);
        sup_norm_g = norm(g,Inf);
        
        it = it + 1;
        
        % f_vec(it+1) = f;
        
        if (verbosity)
            fprintf('%s%i%s%.4e%s%.4e\n','it = ',it,', f = ',f,', sup-norm of g = ', sup_norm_g);
        end
        
        if (it >= max_it)
            flag = 1;
            break;
        end
        
    end
    
    alg_info.it = it;
    alg_info.sup_norm_g = sup_norm_g;
    alg_info.flag = flag;
    % alg_info.f_vec = f_vec(1:it+1);
    
end