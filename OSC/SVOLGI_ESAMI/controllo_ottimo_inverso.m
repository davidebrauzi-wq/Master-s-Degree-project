% Script per problema di controllo ottimo inverso
close all 
clear all
clc
syms x1 x2
assume(x1,'real');
assume(x2,'real');

% syms a b c
% syms a
syms u

u = -x2;
f = [-x1+2*x1*x2;u-x1^2];
V = x2^2/2 + x1^2/4;
l = 1/2*x1^2+1/2*x2^2+1/2*u^2;
simplify(l + diff(V,x1)*f(1) + diff(V,x2)*f(2))
%sol = solve(l + diff(V,x1)*f(1) + diff(V,x2)*f(2),[a b c])

%%

close all 
clear all
clc
syms x1 x2 x3
assume(x1,'real');
assume(x2,'real');
assume(x3,'real');

% syms a b c

syms u1 u2
syms gamma(x2)
u1 = -x1;
u2 = -x1 - x3;

f = [u1+u2;x1;u2];
V = x1^2/2 + x3^2/2 + gamma(x2);
l = 1/2*[x1 x2 x3]*[x1;x2;x3] + 1/2*[u1 u2]*[u1;u2];

simplify(l + diff(V,x1)*f(1) + diff(V,x2)*f(2) + diff(V,x3)*f(3))
%sol = solve(l + diff(V,x1)*f(1) + diff(V,x2)*f(2),[a b c])