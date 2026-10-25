% Vediamo i miglioramenti della mancata linearizzazione su finestre
% temporali maggiori di 2 (in SIR 2 avevamo notato come l'approssimazione
% del sistema non realizzasse variazioni nella funzione di costo).

clear all
close all
clc

xd = [0 0 60000]';
x0 = [45000 1 14999]';

exp_I = 2;
Q = [0 0 0;
     0 10^(-exp_I) 0;
     0 0 0];

R = 1;
S = blkdiag(10^-2,0,0);

Nu = 5; % numero passi MPC

tau = 2/10;
pop = 60000;
omega = tau/pop;

ni = 1/15;
%% Struttura problema MPC

u0 = 0;
T = 365; % orizzonte temporale simulazione
X = zeros(3,T + 1); % inizializzo gli stati del vettore SIR
u = zeros(1,T);
uc = u0;
X(:,1) = x0;

costo_MPC = zeros(1,T);

% L'MPC serve solo a ridurre la finestra temporale rendendo possibile
% l'implementazione di un modello non lineare (fmincon)

% Scrivo le matrici del sistema non lineare
% x(t+1) = A*x(t) + x(t)'*B_tilde*x(t)*u(t)
A = [1 0 0;
     0 1-ni 0;
     0 ni 1];
B = [0 -1 0;
     1 0 0;
     0 0 0];
B_tilde = omega * B;
L = blkdiag(Q,Q,Q,Q,S);
costo_MPC_non_lin = zeros(1,T);

X = zeros(3,T + 1); % inizializzo gli stati del vettore SIR
u = zeros(1,T);
X(:,1) = x0;

for t = 1:T  % ipotizzo T giorni per la simulazione
    xc = X(:,t);
    % Scriviamo la funzione obiettivo
    NL = optimproblem("ObjectiveSense","min");
    X_var = optimvar("X_var",3*(Nu),1); % variabile ausiliaria per lo stato del sistema
    U = optimvar("U",Nu,1);
    v = 8 * ones(Nu,1);
    NL.Objective = X_var' * L * X_var + xc'*Q*xc + (U-v)'*(U-v);
    NL.Constraints.a = eye(Nu)*U <= ones(Nu,1)*20;
    NL.Constraints.b = eye(Nu)*U >= zeros(Nu,1);
    NL.Constraints.c = X_var(1:3) == A*xc + xc'*B_tilde*xc*U(1);
    NL.Constraints.d = X_var(4:6) == A*X_var(1:3) + X_var(1:3)'*B_tilde*X_var(1:3)*U(2);
    NL.Constraints.e = X_var(7:9) == A*X_var(4:6) + X_var(4:6)'*B_tilde*X_var(4:6)*U(3);
    NL.Constraints.f = X_var(10:12) == A*X_var(7:9) + X_var(7:9)'*B_tilde*X_var(7:9)*U(4);
    NL.Constraints.g = X_var(13:15) == A*X_var(10:12) + X_var(10:12)'*B_tilde*X_var(10:12)*U(5);
        k0.U = zeros(Nu,1);
        k0.X_var = zeros(3*Nu,1);
    options = optimoptions('fmincon','MaxIterations',1e3);
    [sol,fval,exitflag] = solve(NL,k0,"Options",options);
    U_star = sol.U; % ho operato un cambio di variabile nella f.o.
    u(t) = U_star(1);
    X(1,t + 1) = X(1,t) - u(t) * omega * X(1,t) * X(2,t);
    X(2,t + 1) = X(2,t) + u(t) * omega * X(1,t) * X(2,t) - ni * X(2,t);
    X(3,t + 1) = X(3,t) + ni * X(2,t);
    if t >= 2
        costo_MPC_non_lin(t) = 10^(-2)*(X(2,t))^2 + (u(t) - 8)^2 + costo_MPC_non_lin(t-1);
    else 
        costo_MPC_non_lin(1) = 10^(-2)*(X(2,t))^2 + (u(t) - 8)^2;
    end
end

costo_MPC_non_lin(T);
%%
figure(2 + 20)
hold on
grid on
title("Andamenti nel tempo S I R, MPC non lin")
xlabel('k')
ylabel('Valori indici modello SIR')
plot(X(1,:),'-b','MarkerFaceColor','blue','DisplayName','S(k)')
plot(X(2,:),'-r','MarkerFaceColor','red','DisplayName','I(k)')
plot(X(3,:),'-g','MarkerFaceColor','green','DisplayName','R(k)')
set(figure(2 + 20), 'WindowStyle', 'Docked');
legend("Location","southeast")
hold off


figure(3 + 20)
hold on
grid on
title("Contatti nel tempo MPC non lin")
xlabel('k')
ylabel('u(k)')
plot(u,'-b','MarkerFaceColor','blue','DisplayName','u(k)')
set(figure(3 + 20), 'WindowStyle', 'Docked');
legend("Location","southeast")
hold off

figure(6 + 20)
hold on
grid on
title("costo controllo MPC non lin")
xlabel('k')
ylabel('C^{MPC}(k)')
plot(costo_MPC_non_lin,'-g','MarkerFaceColor','green','DisplayName','C^{MPC}(k)')
set(figure(6 + 20), 'WindowStyle', 'Docked');
hold off