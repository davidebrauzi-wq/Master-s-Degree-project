clc
clear
close all

% problem's data
n = 10;
c = 100;
x_0 = repmat([-1.2; 1],n/2,1);

[obj, grad, hess] = extended_rosenbrock_function(n,c);

eps = 1e-6;

%% gradient method
[x, f, i] = gradient_method(obj, grad, x_0, eps)

%% spectral gradient method
c_min = 1;
c_max = 10;
[x, f, i] = spectral_gradient_method(obj, grad, x_0, eps, c_min, c_max)

%% gradient method with momentum
beta = 0.01;
[x, f, i] = momentum_gradient_method(obj, grad, x_0, eps, beta)

%% conjugated gradient method
[x, f, i] = conjugated_gradient_method(obj, grad, hess, x_0, eps)

%% non-linear conjugated gradient method with Fletcher-Reeves method for beta
beta_method = "Fletcher-Reeves";
[x, f, i] = nonlinear_conjugated_gradient_method(obj, grad, hess, x_0, eps, beta_method)

%% non-linear conjugated gradient method with Polyak-Polak-Ribiére method for beta
beta_method = "Polyak-Polak-Ribiére";
[x, f, i] = nonlinear_conjugated_gradient_method(obj, grad, hess, x_0, eps, beta_method)

%% newton method
[x, f, i] = newton_method(obj, grad, hess, x_0, eps)

%% quasi-newton method with direct rank 1 formulas
method = "Direct Rank 1";
[x, f, i] = quasi_newton_method(obj, grad, x_0, eps, method)

%% quasi-newton method with inverse rank 1 formulas
method = "Inverse Rank 1";
[x, f, i] = quasi_newton_method(obj, grad, x_0, eps, method)

%% quasi-newton method with direct rank 2 formulas
method = "Direct Rank 2";
[x, f, i] = quasi_newton_method(obj, grad, x_0, eps, method)

%% quasi-newton method with inverse rank 2 formulas
method = "Inverse Rank 2";
[x, f, i] = quasi_newton_method(obj, grad, x_0, eps, method)

%% truncated newton method
epsilon = 0.01;
eta = 0.01;
[x, f, i] = truncated_newton_method(obj, grad, hess, x_0, eps, epsilon, eta)