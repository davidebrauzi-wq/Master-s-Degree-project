close all
clear all
clc

% Soluzione ottima LQR inf
A = 1;
B = 1;
R = 1;
Q = 8;

syms a positive
P = a;

% Risolvo equazione algebrica di Riccati
sol = solve(A'*P + P*A + Q - P*B*inv(R)*B'*P,a);

syms x(t)

P = sol;

u_star = - inv(R)*B'*P * x(t);

% Definisco l'equazione differenziale
ode = diff(x,t) ==  A*x(t) + B*u_star; % soluzione sistema dinamico
cond = x(0) == 1;

xSol(t) = dsolve(ode, cond);

% Visualizza la soluzione
disp(xSol)

% Aggiorno u_star
fprintf("La soluzione ottima è \n")
u_star = - inv(R)*B'*P * xSol(t)

fplot(u_star, [0, 10])          
xlabel('t')
ylabel('f(t)')
title('u*')
grid on

%% n = 2
close all 
clear all 
clc

A = [0 1;0 1];
B = [0 1]';
R = 1;
Q = [1 0; 0 0];

x0 = [0 1]';


syms a positive
syms b c

P = [a b; b c];
% Risolvo equazione algebrica di Riccati
sol = solve(A'*P + P*A + Q - P*B*inv(R)*B'*P,[a b c]);
%%
P = [sol.a sol.b; sol.b sol.c];
P

fprintf("Il costo ottimo è \n")
c_star = 1/2 * x0' * P * x0;