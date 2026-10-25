% Algoritmo per risoluzioni esercizi con Kleinman
clear all 
close all
clc

% Verifica preliminare
K0 = [-2 -1];
A = [-1 1/2; 1 -2];
B = [0 1]';
R = 1;
S0 = A + B*K0;
fprintf("Autovalori S0 \n")
eig(S0)

P0 = [2 1; 1 1];
Q = [2 2; 2 4];
fprintf("minore principale dominante di ordine 2 \n")
det(P0)
fprintf("Residuo equazione lineare di Lyapunov \n")
S0' * P0 + P0 * S0 + Q + K0' * R * K0

%% Plot del sistema dinamico associato
% Funzione di controllo (può dipendere da t e x)
u = @(t, x) 0; % esempio con solo t

% Definizione del sistema dinamico
f = @(t, x) A*x + B*u(t, x);

% Intervallo temporale
tspan = [0 10];

% Condizione iniziale
x0 = [1; 0];

% Risoluzione numerica
[t, x] = ode45(f, tspan, x0);

% Grafico dei risultati
plot(t, x(:,1), 'b', t, x(:,2), 'r--')
xlabel('t')
ylabel('x(t)')
legend('x_1(t)', 'x_2(t)')
title('Evoluzione del sistema x^.(t) = Ax(t) + Bu(t)')
grid on

%%
fprintf("costo di u0 \n")
x0 = [1 0]';
V_u0 = 1/2 * x0'*P0*x0

K1 = -inv(R)*B'*P0;
S1 = A + B*K1;

syms x positive
syms y
syms z

P1 = [x y; y z];

sol = solve(S1'*P1 + P1*S1 + Q + K1'*R*K1 == zeros(2,2), [x y z]);

%%
P1 = [sol.x sol.y; sol.y sol.z];
det(P1);

fprintf("Costo ottimo di u1 \n")
V_u1 = 1/2 * x0' * P1 * x0

K2 = -inv(R)*B'*P1;
S2 = A + B*K2;

eig(S2)

%% Kleinman con n = 3

clear all 
close all
clc

% Verifica preliminare
K0 = [-1 -2 -1];
A = [0 1 0;
     0 0 1;
     0 0 0];
B = [0 0 1]';
R = 1;
S0 = A + B*K0;
fprintf("Autovalori S0 \n")
eig(S0)

syms a b c x y z
P0 = [x a b;
      a y c;
      b c z];
Q = [1 0 0;
     0 1 0;
     0 0 1];
fprintf("minore principale dominante di ordine 2 \n")
sol = solve(S0' * P0 + P0 * S0 + Q + K0' * R * K0, [a b c x y z]);
fprintf("Residuo equazione lineare di Lyapunov \n")
% S0' * P0 + P0 * S0 + Q + K0' * R * K0
x = sol.x;
y = sol.y;
a = sol.a;
P0 = [x a b;
      a y c;
      b c z];
x0 = [1 1 0]';
fprintf("Costo della politica associata a K \n")
J_u = 1/2*x0'*P0*x0

%% Kleinmann con n = 1

close all
clear all 
clc

A = 1;
B = 1;
R = 1;
Q = 8;

K0 = -2;
S0 = A + B * K0;
syms x positive
P0 = x;

sol = solve(S0' * P0 + P0 * S0 + Q + K0' * R * K0, x);
P0 = sol;

%% Kleinmann con due controlli ed n = 2

clear all 
close all
clc

% Verifica preliminare
K0 = [-2 1; 1 -2];
A = [0 1; -1 0];
B = [1 1; 0 1];
R = [1 1;1 2];
S0 = A + B*K0;
fprintf("Autovalori S0 \n")
eig(S0)

P0 = [3/2 -1/3; -1/3 3/2];
Q = [1 0; 0 1];
fprintf("minore principale dominante di ordine 2 \n")
det(P0)
fprintf("Residuo equazione lineare di Lyapunov \n")
S0' * P0 + P0 * S0 + Q + K0' * R * K0