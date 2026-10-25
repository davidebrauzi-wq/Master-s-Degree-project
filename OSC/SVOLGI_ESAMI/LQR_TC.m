% Script per risoluzione DRE tramite sistema hamiltoniano
% Definizione matrici
close all
clear all
clc

global A B Q R p11 p12 p22 tP

n = 2;
A = [1 1; 0 1]; 
B = [0; 1];
Q = zeros(2,2);
R = 1;
M = [1 0;0 1];
T = 2; % istante di fine controllo ottimo

x0 = [1;0];

%% Soluzione all'indietro di DRE
PT = reshape(M,n^2,1); % metti M in colonna

[t,yP] = ode45(@DRE,[T 0], M); % P(T) = M
p11 = yP(:,1);
p12 = yP(:,2); % ovviamente non plotto la terza componente poichè ug alla prima
p22 = yP(:,4);

figure(1)
hold on
plot(t,p11,t,p12,t,p22)
grid on
box on
xlabel('t')
ylabel('P')
P0 = [p11(end),p12(end);p12(end),p22(end)];
disp(P0)

tP = t;

[t,yX] = ode45(@SistemaDinamico,[0,T],x0);
x1 = yX(:,1); x2 = yX(:,2);
figure(2)
plot(t,x1,t,x2)
hold on 
grid on
box on
xlabel('t')
ylabel('x')

fprintf("Il costo ottimo è \n")
1/2 * x0' * P0 * x0

function Ppunto = DRE(t,y)

global A B Q R

P = [y(1),y(2);y(3),y(4)]; % matrice di 4 componenti
PpuntoDRE = -(A'*P + P*A + Q - P*B*inv(R)*B'*P);
Ppunto = reshape(PpuntoDRE,4,1); % vettore colonna

end

function xpunto = SistemaDinamico(t,y)

global A B R p11 p12 p22 tP

x = [y(1);y(2)];

p11_t = interp1(tP,p11,t);
p12_t = interp1(tP,p12,t);
p22_t = interp1(tP,p22,t);

Pt = [p11_t,p12_t;p12_t,p22_t];
u = -inv(R)*B'*Pt*x;
xpunto = A*x+B*u;

end