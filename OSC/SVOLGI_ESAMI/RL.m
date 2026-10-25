% Calcolo funzione valore tramite PE stocastico
close all
clear all
clc

% T = [0 1 0 0;
%      0 0 1 0;
%      0 0 0 1;
%      0 1 0 0];
% 
% R = [-1 1 -1 -1]';

T = [0.5 0.3 0.2;
     0.7 0 0.3;
     0.3 0.6 0.1;];
R = [1;
     0;
     -1];

gamma = 1/2;

% v
syms x real
syms y real
syms z real
v = [x y z]';
R + gamma*T*v

solve(v == R + gamma*T*v, [x y z]')


