% Script per svolgere esercizi LQR tempo discreto
close all
clear all
clc
% scrivi in Input le matrici A, B, R, Q, S;
% A = [0 1;
%      0 0];
% B = [0;
%      1];
% Q = [1 0;
%      0 0];
% R = 1;
% S = [0 0;
%      0 1];

% Caso scalare
% syms a
A = 1;
B = 1;
R = 1;
Q = 1;
S = 0;
% scrivi in Input l'orizzonte di ottimizzazione (quello indicato + 1);
N = 5;
% Equazione di Riccati alle differenze
P{N} = S;
for k = N-1:-1:1
   P{k} = Q+A'*P{k+1}*A-A'*P{k+1}*B*inv(R+B'*P{k+1}*B)*B'*P{k+1}*A;
   eig(R+B'*P{k+1}*B);  % verificare che la matrice resti definita positiva, dato che Q non è semi-definita positiva
end

% scrivi in Input lo stato inziale
%x{1} = [1 1]';
x{1} = -1;
for k = 1:1:N-1
  u{k} = -inv(R+B'*P{k+1}*B)*B'*P{k+1}*A*x{k};  
  x{k+1} = A*x{k}+B*u{k};   
end

for i = 1:N
    fprintf("########################## \n")
    fprintf(strcat("istante ",string(i)))
    fprintf("\n")
    fprintf(strcat("P_",string(i)))
    P{i}
    fprintf(strcat("x_",string(i)))
    x{i}
    fprintf(strcat("V(x_",string(i),")"))
    x{i}'*P{i}*x{i}
    if i <= N - 1
        fprintf(strcat("u_",string(i)))
        u{i}
    end
    fprintf("########################## \n")
end

% sol = solve(x{1}'*P{1}*x{1} == 2, a);