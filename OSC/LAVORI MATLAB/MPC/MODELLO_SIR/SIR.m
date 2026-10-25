
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
S = blkdiag(10^(-1.5),zeros(2,2));

Nu = 2; % numero passi MPC

tau = 2/10;
pop = 60000;
omega = tau/pop;

ni = 1/15;

% Anzitutto proviamo il sistema dinamico;
x1(1) = x0(1);
x2(1) = x0(2);
x3(1) = x0(3);
costo_pol_nominale = zeros(1,100);
for k = 1:100
    u(k) = 8;
    x1(k + 1) = x1(k) - u(k) * omega * x1(k) * x2(k);
    x2(k + 1) = x2(k) + u(k) * omega * x1(k) * x2(k) - ni * x2(k);
    x3(k + 1) = x3(k) + ni * x2(k);
    if k >= 2
        costo_pol_nominale(k) = costo_pol_nominale(k-1) + 10^(-2)*(x2(k))^2 + (u(k) - 8)^2;
    else 
        costo_pol_nominale(1) = 10^(-2)*(x2(k))^2 + (u(k) - 8)^2;
    end
end

figure(1)
hold on
grid on
title("Andamenti nel tempo S I R")
xlabel('k')
ylabel('Valori indici modello SIR')
plot(x1,'bo','MarkerFaceColor','blue','DisplayName','S(k)')
plot(x2,'ro','MarkerFaceColor','red','DisplayName','I(k)')
plot(x3,'go','MarkerFaceColor','green','DisplayName','R(k)')
set(figure(1), 'WindowStyle', 'Docked');
legend("Location","southeast")
hold off

figure(5)
hold on
grid on
title("costo controllo nominale")
xlabel('k')
ylabel('C(k)')
plot(costo_pol_nominale,'go','MarkerFaceColor','green','DisplayName','C(k)')
set(figure(5), 'WindowStyle', 'Docked');
hold off


% Modello funzionante

%% Struttura problema MPC
R_bar = [];
Q_bar = [];
for j = 1 : Nu - 1
    R_bar = blkdiag(R_bar,1);
    Q_bar = blkdiag(Q_bar,Q);
end

Q_bar = blkdiag(Q_bar,S);
R_bar = blkdiag(R_bar,R);
S_bar = zeros(3*Nu,Nu);

Xc = zeros(3*Nu,1); % inizializzo il vettore dello stato corrente
Uc = zeros(Nu,1); % inizializzo il vettore del controllo corrente
T_bar = zeros(3*Nu,3); % inizializzo la matrice contenente il termine affine

% Matrici vincolo sulle U (G U <= W)

G1 = eye(Nu);
G2 = -eye(Nu);
G = [G1;G2];

W1 = ones(Nu,1);
W2 = ones(Nu,1);

u0 = 0;
T = 365; % orizzonte temporale simulazione
X = zeros(3,T + 1); % inizializzo gli stati del vettore SIR
u = zeros(1,T);
uc = u0;
X(:,1) = x0;
err = zeros(1,T);
costo_MPC = zeros(1,T);

for t = 1:T  % ipotizzo T giorni per la simulazione
    xc = X(:,t);
    Aa = matrice(xc,uc,omega,ni); % df/dx(xc,uc)
    Ba = cont(xc,omega); % df/du(xc,uc)
    Pa = f_nl_sir(xc,uc,omega,ni) - xc; % f(xc,uc)
    
    % scrivo le matrici del problema quadratico da risolvere
    cost = zeros(3,3);
    for i = 1:Nu
        Xc(i*3 - 2 : i*3 , 1) = xc;
        Uc(i) = uc;
        W1(i) = (20 - uc);
        W2(i) = uc;
        cost = cost + Aa^(i-1); % aggiorno il termine di T_bar in quanto ogni riga incrementa
        T_bar(i*3 - 2:i*3 , :) = cost;
        for j = 1:i
            S_bar(i*3 - 2:i * 3 , j) = Aa^(i - j) * Ba;
        end
    end
    W = [W1;W2];
    
    % Scriviamo la funzione obiettivo
    QP = optimproblem("ObjectiveSense","min");
    U = optimvar("U",Nu,1);
    v = 8 * ones(Nu,1);
    %QP.Objective = xc'*(Nu*Q + S)*xc + 2*((Xc' + Pa'*(T_bar)')*Q_bar*S_bar + Uc'*R_bar)*(U) + (U-v)'*(R_bar + S_bar'*Q_bar*S_bar)*(U-v) + ...
    %      (2 * Xc' + Pa'*T_bar')*Q_bar*T_bar*Pa + Uc'*R_bar*Uc + 2*Uc'*R_bar*(-v);
    QP.Objective = U'*(S_bar'*Q_bar*S_bar + R_bar)*U + 2*((Pa'*T_bar' + Xc')*Q_bar*S_bar + ((-v)' + Uc')*R_bar)*U;
    QP.Constraints.a = G * U <= W;
    k0.U = zeros(Nu,1);
    options = optimoptions('quadprog','Algorithm','interior-point-convex','MaxIterations',1e3);
    [sol,fval,exitflag] = solve(QP,k0,"Options",options);
    U_star = sol.U + uc; % ho operato un cambio di variabile nella f.o.
    u(t) = U_star(1);
    uc = U_star(1);
    X(1,t + 1) = X(1,t) - u(t) * omega * X(1,t) * X(2,t);
    X(2,t + 1) = X(2,t) + u(t) * omega * X(1,t) * X(2,t) - ni * X(2,t);
    X(3,t + 1) = X(3,t) + ni * X(2,t);
    err(t) = norm([X(1,t + 1) - xd(1); X(2,t + 1) - xd(2); X(3,t + 1) - xd(3)]);
    if t >= 2
        costo_MPC(t) = 10^(-2)*(X(2,t))^2 + (u(t) - 8)^2 + costo_MPC(t-1);
    else 
        costo_MPC(1) = 10^(-2)*(X(2,t))^2 + (u(t) - 8)^2;
    end
end
%% 
figure(2)
hold on
grid on
title("Andamenti nel tempo S I R, MPC")
xlabel('k')
ylabel('Valori indici modello SIR')
plot(X(1,:),'-b','MarkerFaceColor','blue','DisplayName','S(k)')
plot(X(2,:),'-r','MarkerFaceColor','red','DisplayName','I(k)')
plot(X(3,:),'-g','MarkerFaceColor','green','DisplayName','R(k)')
set(figure(2), 'WindowStyle', 'Docked');
legend("Location","southeast")
hold off


figure(3)
hold on
grid on
title("Contatti nel tempo")
xlabel('k')
ylabel('u(k)')
plot(u,'-b','MarkerFaceColor','blue','DisplayName','u(k)')
set(figure(3), 'WindowStyle', 'Docked');
legend("Location","southeast")
hold off

figure(6)
hold on
grid on
title("costo controllo MPC")
xlabel('k')
ylabel('C^{MPC}(k)')
plot(costo_MPC,'-g','MarkerFaceColor','green','DisplayName','C^{MPC}(k)')
set(figure(6), 'WindowStyle', 'Docked');
hold off

figure(7)
hold on
grid on
title("distanza da x_d")
xlabel('k')
ylabel('e(k)')
plot(err,'-r','MarkerFaceColor','green','DisplayName','C^{MPC}(k)')
set(figure(7), 'WindowStyle', 'Docked');
hold off