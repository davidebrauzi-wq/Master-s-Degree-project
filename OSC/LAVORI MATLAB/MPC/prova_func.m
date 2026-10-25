clear all
clc
close all

xc = [3 4 5];
uc = 100;
ni = 9;
omega = 80;

Aa = matrice(xc,uc,omega,ni);
Bb = cont(xc,omega);

x_evol = f_nl_sir(xc,uc,omega,ni);
