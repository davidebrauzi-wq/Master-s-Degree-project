%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ESEMPIO CONTROLLO OTTIMO PER SUPPLY CHAIN %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

alfa1 = 0.4;
delta1 = 0.1;
alfa2 = 0.5; %0.5 vs 0.4 produttività
delta2 = 0.1;
gamma3 = 0.35; 
beta3 = 0.2;
c = 0;

A = [1-alfa1-delta1,0,0;alfa1,1-alfa2-delta2,beta3;0,alfa2,1-beta3-gamma3];
B = [1;0;0];
Q = [0,0,0;0,0,0;0,0,-gamma3];
R = 1;
S = [c,0,0;0,c,0;0,0,0];
% J = sum(x_k' Q x_k + u_k' R u_k), R = 1 -> u_k^2, y_k = gamma_3 * x_{3,k}
% ob: max sum(gamma_3 x_3^2) -> Q = -[0 0 0; 0 0 0; 0 0 gamma_3]
% n = 3

N = 48; % 4 anni

% Equazione di Riccati alle differenze
P{N} = S;
for k = N-1:-1:1
   P{k} = Q+A'*P{k+1}*A-A'*P{k+1}*B*inv(R+B'*P{k+1}*B)*B'*P{k+1}*A;
   eig(R+B'*P{k+1}*B);  % verificare che la matrice resti definita positiva, dato che Q non è semi-definita positiva
end

% evoluzione del sistema a ciclo-chiuso con controllo ottimo
x0 = [0;0;1]; % x1 = 0, x2 = 0, x3 = 1
x{1} = x0;
for k = 1:1:N-1
  u{k} = -inv(R+B'*P{k+1}*B)*B'*P{k+1}*A*x{k};  
  x{k+1} = A*x{k}+B*u{k};   
end

for i = 1:size(x,2)
    xtmp = x{i};
    x1(i) = xtmp(1);
    x2(i) = xtmp(2);
    x3(i) = xtmp(3);
end

K = 1:1:N;
figure(1)
hold on
box on
grid on
xlabel('k')
ylabel('x1 (blu), x2 (rosso), x3 (verde)')
plot(0,x0(1),'bo','MarkerFaceColor','blue')
plot(K,x1,'bo','MarkerFaceColor','blue')
plot(0,x0(2),'ro','MarkerFaceColor','red')
plot(K,x2,'ro','MarkerFaceColor','red')
plot(0,x0(3),'go','MarkerFaceColor','green')
plot(K,x3,'go','MarkerFaceColor','green')
set(figure(1), 'WindowStyle', 'Docked');


