clear all
close all
clc

global G W E xt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% MPC per ottimizzazione dinamica %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Esempio del doppio integratore

A = [1 1;0 1];
B = [0;1];
Q = [1 0;0 0];
S = [1 0;0 1];
R = 1/10;

n = 2;  % dimensione dello stato
m = 1;  % numero di controlli
Nu = 2; % orizzonte di previsione
x0 = [10;-0.2];

%%%% Calcolo delle matrici per MPC
Rbar = []; Qbar = []; 
for j = 1:Nu-1
   Rbar = blkdiag(Rbar,R);
   Qbar = blkdiag(Qbar,Q);
end
Rbar = blkdiag(Rbar,R); Qbar = blkdiag(Qbar,S);  % l'ultima componente della Qbar non è Q ma S...
Sbar = zeros(n*Nu,m*Nu); Tbar = zeros(n*Nu,n);
contR = 1; 
for ir = 1:n:n*Nu
    Tbar(ir:ir+n-1,:) = A^contR;
    contC = 1;
    for ic = 1:m:m*contR
        Sbar(ir:ir+n-1,ic:ic+m-1) = A^(contR-contC)*B; 
        contC = contC + 1;
    end
    contR = contR + 1;
end
% definizione delle matrici per il problema di minimizzazione statica non
% vincolato
H = 2*(Rbar + Sbar'*Qbar*Sbar);
F = 2*(Tbar'*Qbar*Sbar)';
Y = 2*(Q+Tbar'*Qbar*Tbar);
% matrici per vincoli
%  u_0 < 1
%  u_1 < 1
% -u_0 < -(-1)
% -u_1 < -(-1)
umax = 1;
W = umax*[1;1;1;1];
G = [1,0;0,1;-1,0;0,-1];
E = [0 0;0 0;0 0;0 0];
% vincolo GU < W, con U = [u_0,u_1]'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Model Predictive Control %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nmax = 20;
xmpc(:,1) = x0;
umpc = zeros(Nmax-1,1);
for t = 1:Nmax
   xt = xmpc(:,t);
    
   %%% soluzione ottima di QP con "fmincon"
   init = [0;0]; % candiato iniziale di soluzione ammissibile 
   Ustar = fmincon(@(z) 0.5*z'*H*z+xt'*F'*z,init,[],[],[],[],[],[],@mycon);
   options = optimoptions('fmincon','Algorithm','interior-point','MaxIterations',1e3);
   %Ustar2 = fmincon(@(z) 0.5*z'*H*z+xt'*F'*z,init,G,W+E*xt,[zeros(2,2*(Nu-1)),eye(2)]*Sbar,-[zeros(2,2*(Nu-1)),eye(2)]*Tbar*xt);
   %disp(Sbar*Ustar2+Tbar*xt);

   Vstar = 0.5*Ustar'*H*Ustar+xt'*F'*Ustar + 0.5*xt'*Y*xt;  % valore ottimo determinato
    
   umpc(t) = Ustar(1);                     % implementiamo solo il primo campione
   xmpc(:,t+1) = A*xmpc(:,t)+B*umpc(t); 
end
figure(2)
hold on
box on
grid on
set(gca,'FontSize',15);
ylabel('$x_2$','Interpreter','Latex','FontSize',23)
xlabel('$x_1$','Interpreter','Latex','FontSize',23)
plot(xmpc(1,:),xmpc(2,:),'g','LineWidth',1)
plot(xmpc(1,:),xmpc(2,:),'go','MarkerFaceColor','green')
figure(3)
hold on
box on
grid on
set(gca,'FontSize',15);
ylabel('$x_1,x_2$','Interpreter','Latex','FontSize',23)
xlabel('$t$','Interpreter','Latex','FontSize',23)
plot([0:Nmax],xmpc(1,:),'b','LineWidth',1.5)
plot([0:Nmax],xmpc(2,:),'r','LineWidth',1.5)
figure(4)
hold on
box on
grid on
set(gca,'FontSize',15);
ylabel('$u$','Interpreter','Latex','FontSize',23)
xlabel('$t$','Interpreter','Latex','FontSize',23)
plot([0:Nmax-1],umpc,'b','LineWidth',1.5)
pause

%close all
%%% AGGIUNGIAMO IL VINCOLO: x_{2,k} >= -1, per k = 1
% modifica delle matrici per il vincolo
% x_1 = Ax_0 + B u_0 -> -(x_{0,2} + u_0) <= 1
% G*U < W + E*xt
W = [W;1];
G = [G;-1 0];
E = [E;0 1];
xmpc(:,1) = x0;
umpc = zeros(Nmax-1,1);
for t = 1:Nmax
   xt = xmpc(:,t);
  
    
   %%% soluzione ottima di QP con "fmincon"
   init = [0;0]; % candiato iniziale di soluzione ammissibile 
   Ustar = fmincon(@(z) 0.5*z'*H*z+xt'*F'*z,init,[],[], [],[],[],[],@mycon);
   Vstar = 0.5*Ustar'*H*Ustar+xt'*F'*Ustar;  % valore ottimo determinato
    
   umpc(t) = Ustar(1);                     % implementiamo solo il primo campione
   xmpc(:,t+1) = A*xmpc(:,t)+B*umpc(t); 
end
figure(2)
hold on
box on
grid on
set(gca,'FontSize',15);
ylabel('$x_2$','Interpreter','Latex','FontSize',23)
xlabel('$x_1$','Interpreter','Latex','FontSize',23)
plot(xmpc(1,:),xmpc(2,:),'g--','LineWidth',1)
plot(xmpc(1,:),xmpc(2,:),'go','MarkerFaceColor','green')
figure(3)
hold on
box on
grid on
set(gca,'FontSize',15);
ylabel('$x_1,x_2$','Interpreter','Latex','FontSize',23)
xlabel('$t$','Interpreter','Latex','FontSize',23)
plot([0:Nmax],xmpc(1,:),'b--','LineWidth',1.5)
plot([0:Nmax],xmpc(2,:),'r--','LineWidth',1.5)
figure(4)
hold on
box on
grid on
set(gca,'FontSize',15);
ylabel('$u$','Interpreter','Latex','FontSize',23)
xlabel('$t$','Interpreter','Latex','FontSize',23)
plot([0:Nmax-1],umpc,'b--','LineWidth',1.5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FUNZIONI AUSILIARIE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c,ceq] = mycon(z)
    global G W E xt
    c =  G*z-W-E*xt;          % vincoli di disuguaglianza
    ceq = [];                 % vincoli di uguaglianza
end

