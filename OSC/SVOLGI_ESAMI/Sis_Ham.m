% Codice testato che funziona bene
clear all
clc
A = [-1 0; 0 -2]; 
%B = [1 0; -1 1];
B = [0; 1];
Q = zeros(2,2);

M = [1 0; 0 0];
%R = eye(2);
 R = 1;
x0 = [1 1]';

% syms q real 
% assume(q >= 0)
% 
% A = 2;
% B = 1;
% R = 1;
% M = 0;
% Q = 5;
% x0 = 2;

T = 2;
H = [A -B*inv(R)*B'; -Q -A'];
disp(H)

%%
% Scrivo gli autovalori trovati
vs_1 = [1 0 0 0]';
vs_2 = [0 1 0 0]';
vu_1 = [0 0 1 0]';
vu_2 = [0 1 0 -4]';

U = [vs_1 vs_2 vu_1 vu_2];

% vs = [1 5]';
% vu = [1 -1]';
% 
% U = [vs vu];

LAMBDA = inv(U) * H * U
U


LAMBDA_s = LAMBDA(1:2, 1:2);
LAMBDA_u = LAMBDA(3:4,3:4);

% LAMBDA_s = LAMBDA(1,1);
% LAMBDA_u = LAMBDA(2,2);

fprintf("esponenziali matriciali \n")
fprintf("e^(Lambda_s(T)) \n")
expm(LAMBDA_s*T)
fprintf("e^(-Lambda_u(T)) \n")
expm(-LAMBDA_u*T)

% componenti matrice U
U11 = U(1:2,1:2);
U12 = U(1:2,3:4);
U21 = U(3:4,1:2);
U22 = U(3:4,3:4);

% U11 = U(1,1);
% U12 = U(1,2);
% U21 = U(2,1);
% U22 = U(2,2);

%%
fprintf("Matrice G \n")
G1 = U22 - M*U12;
G2 = U21 - M*U11;
G = -inv(U22 - M*U12)*(U21 - M*U11)

%%
% Calcolo la matrice P(0)
% P = P1 * inv(P2)
LAMBDA_bar = expm(-LAMBDA_u*T) * G * expm(LAMBDA_s*T);
P1 = U21 + U22 * LAMBDA_bar;
P2 = U11 + U12 * LAMBDA_bar;
P = P1 * inv(P2);

%%

%phi = 1 + 4 * exp(-4) - 5 * exp(-8); % determinante P2 a mano
% costo ottimo
fprintf("Il costo ottimo è \n")
c_star = 1/2*x0'*P*x0

%%
x0 = sqrt(2);
eq = 3 == 1/2*x0'*P*x0;
solve(eq,q)
