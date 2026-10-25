%PROGETTO MOVIMENTAZIONE OTTIMA SC CON LQ%
%%DAVIDE BRAUZI - A.A. 2024/2025%%
%SECONDO SCRIPT: RISOLUZIONE PROBLEMA CON EQUAZIONE RICORSIVA DI RICCATI

clear all
close all
clc

% Input matrici
A_t = readmatrix("Matrice_A_t.xlsx", 'Sheet', 'Sheet1', 'Range','B2:AM39');
B_t = readmatrix("Matrice_B_t.xlsx", 'Sheet', 'Sheet1', 'Range','B2:K39');

n_primo = height(A_t); % numero nodi stato esteso con buffer
l = size(B_t);
m = l(2); % numero controlli (direttrici di trasporto)
n = 7; % numero nodi SC in esame

% Scrittura matrici che definiscono l'indice di costo cumulativo
Q = eye(n_primo,n_primo) * 10^(-2);
S = eye(n_primo,n_primo) * 10^(3);
R = eye(m,m);

%%FASE OFFLINE: CALCOLO P_{k} MEDIANTE EQUAZIONE DI RICCATI%%
N = 50; % istanti di tempo della simulazione (arbitrariamente lungo per apprezzare stabilizzazione)
zd = [20 zeros(1,5) 40 zeros(1,n_primo-7)];
pos = [1 7 14 26 36 37 38]; % posizioni nodi nello stato z_{k}

P{N} = S;
for k = N-1:-1:1 % risolvo Riccati (per Bellman) ricorsivamente all'indietro
    P{k} = Q+(A_t)'*P{k+1}*A_t-A_t'*P{k+1}*B_t*inv(R+(B_t)'*P{k+1}*B_t)*(B_t)'*P{k+1}*A_t;
end

% Non ho bisogno di verificare che P_{k} >= 0 per ogni k in quanto Q ed S
% sono def positive (x_{k}'*P{k}*x_{k} = J*(u_{k}) >= 0 per questo prob).

%% FASE ONLINE: RICOSTRUZIONE DEL CONTROLLO OTTIMO
% Calcolo preventivamente (teoria a supporto) il costo ottimo

z{1} = zeros(n_primo,1);
x0 = [0 0 5 10 10 20 15]'; % livello iniziale magazzini
for i = 1:n
    z{1}(pos(i)) = x0(i);
end

e{1} = z{1} - zd';
J_star = e{1}'*P{1}*e{1};

% implementazione controllo ottimo e calcolo ricorsivo 
J_calc = zeros(1,N);
err(k) = norm(e{1});
for k = 1:N-1
    u{k} = - (R + B_t'*P{k+1}*B_t)^(-1)*B_t'*P{k+1}*A_t*(z{k} - zd');
    energy(k) = (u{k})'*u{k};
    e{k+1} = A_t * e{k} + B_t * u{k};
    err(k+1) = norm(e{k+1});
    z{k+1} = A_t * z{k} + B_t * u{k};
    if k == 1
        J_calc(k) = e{k}'*Q*e{k} + u{k}'*R*u{k};
    else
        J_calc(k) = J_calc(k-1) + e{k}'*Q*e{k} + u{k}'*R*u{k};
    end
end

J_calc(N) = J_calc(N-1) + e{N}'*S*e{N};


% In primis sicuramente è interessante il grafico del costo 
K = 1:1:N;
figure(1)
hold on
box on
grid on
title("Costo cumulato per LQ su intervallo suff. ampio")
xlabel('k')
ylabel('Cumulata di J nel tempo')
plot(K,J_calc,'bo','MarkerFaceColor','blue','DisplayName','cumulata costi')
plot(K,err,'bo','MarkerFaceColor','black','DisplayName','norm(e_k)')
y_line = J_star;
plot([1, N], [y_line, y_line], 'r:', 'LineWidth', 1,'DisplayName','J^{*}') % Linea tratteggiata rossa e più spessa
set(figure(1), 'WindowStyle', 'Docked');
legend("Location","northwest")
hold off

% Vogliamo poi graficare l'andamento di norm(u(k))
figure(2)
hold on
box on
grid on
title("energia di controllo (componente sostanziale del costo istantaneo")
xlabel('k')
ylabel('energia controllo')
plot((1:N-1),energy,'bo','MarkerFaceColor','blue')
y_line = 0;
plot([1, N], [y_line, y_line], 'r:', 'LineWidth', 1) % Linea tratteggiata rossa e più spessa
set(figure(2), 'WindowStyle', 'Docked');
hold off


%% TENTIAMO DI RISOLVERE IL SISTEMA APPROX LA FUNZIONE DI COSTO CON BATCH
% J_seg = sum_{k} u_{k}'*u_{k}
% Verifico anzitutto l'Hp di controllabilità per l'errore
fprintf('Il rango della matrice di raggiungibilità del sistema è:')
rank(ctrb(A_t,B_t))

if rank([ctrb(A_t,B_t) -A_t^38 * e{1}]) == rank(ctrb(A_t,B_t)) 
    fprintf('Posso portare il sistema in zd <=> sistema controllabile')
end

% Definisco la matrice di S_bar in 9 passi (# passi = cammino critico su
% rete)
S_bar = [];
for i = 0:8
    S_bar = [S_bar A_t^i*B_t];
end
rank(S_bar)

% Poichè rank(S_bar) = rank(ctrb(A_t,B_t)) posso controllare il sistema il
% 9 passi => risolvo -A_t^9 * e{1} = S_bar * U tramite gramiana
N = 9;
beta = (S_bar*S_bar')\(-A_t^9 * e{1});

U = S_bar'*beta;
J_nove_stat = zeros(1,10);
for k = 1:N
    u_stat{k} = U((9-k)*m + 1:(9-k)*m + m); % ricostruisco controllo ottimo sezionando U
    e{k+1} = A_t * e{k} + B_t * u_stat{k};
    if k == 1
        J_nove_stat(k) = e{k}'*Q*e{k} + u_stat{k}'*R*u_stat{k};
    else
        J_nove_stat(k) = J_nove_stat(k-1) + e{k}'*Q*e{k} + u_stat{k}'*R*u_stat{k};
    end
end

J_nove_stat(N+1) = J_nove_stat(N) + e{N+1}'*S*e{N+1};

K = 1:1:N+1;
figure(5)
hold on
box on
grid on
title("Costo cumulato di j tramite Gramiana - intervallo minimo")
xlabel('k')
ylabel('Cumulata di J nel tempo')
plot(K,J_nove_stat,'bo','MarkerFaceColor','blue','DisplayName','cumulata costi')
y_line = U'*U;
ylim([0,y_line + 100]);
plot([1, N+1], [y_line, y_line], 'r:', 'LineWidth', 1,'DisplayName','J^{*}_{gram}') % Linea tratteggiata rossa e più spessa
y_line_2 = J_nove_stat(N);
plot([1, N+1], [y_line_2, y_line_2], 'g:', 'LineWidth', 1,'DisplayName','J^{*}')
set(figure(5), 'WindowStyle', 'Docked');
legend("Location","southeast")
hold off
%% Vogliamo confrontare questa prestazione sulla finestra [0,9] con quella equivalente trovata con LQ
%%FASE OFFLINE: CALCOLO P_{k} MEDIANTE EQUAZIONE DI RICCATI%%
N = 10;
zd = [20 zeros(1,5) 40 zeros(1,n_primo-7)];
pos = [1 7 14 26 36 37 38]; % posizioni nodi nello stato z_{k}

P{N} = S;
for k = N-1:-1:1 % risolvo Riccati (per Bellman) ricorsivamente all'indietro
    P{k} = Q+(A_t)'*P{k+1}*A_t-A_t'*P{k+1}*B_t*inv(R+(B_t)'*P{k+1}*B_t)*(B_t)'*P{k+1}*A_t;
end

% Non ho bisogno di verificare che P_{k} >= 0 per ogni k in quanto Q ed S
% sono def positive (x_{k}'*P{k}*x_{k} = J*(u_{k}) >= 0 per questo prob).

%% FASE ONLINE: IMPLEMENTO IL CONTROLLO
J_nove_star = e{1}'*P{1}*e{1}; % calcolo il costo alla fine dell'intervallo
% implementazione controllo ottimo e calcolo ricorsivo 
J_nove_calc = zeros(1,N);

for k = 1:(N-1)
    u{k} = - (R + B_t'*P{k+1}*B_t)^(-1)*B_t'*P{k+1}*A_t*(z{k} - zd');
    e{k+1} = A_t * e{k} + B_t * u{k};
    z{k+1} = A_t * z{k} + B_t * u{k};
    if k == 1
        J_nove_calc(k) = e{k}'*Q*e{k} + u{k}'*R*u{k};
    else
        J_nove_calc(k) = J_nove_calc(k-1) + e{k}'*Q*e{k} + u{k}'*R*u{k};
    end
end

J_nove_calc(N) = J_nove_calc(N-1) + e{N}'*S*e{N};

K = 1:1:N;
figure(4)
hold on
box on
grid on
title('Costo cumulato per LQ su intervallo minimo')
xlabel('k')
ylabel('Cumulata di J nel tempo')
plot(K,J_nove_calc,'bo','MarkerFaceColor','blue','DisplayName','cumulata costi')
ylim([0,40])
y_line = J_nove_star;
plot([1, N], [y_line, y_line], 'r:', 'LineWidth', 1,'DisplayName','J^{*}') % Linea tratteggiata rossa e più spessa
set(figure(4), 'WindowStyle', 'Docked');
legend("Location","southeast")
hold off

%% Prova matrice di ragg
P_bar = [];
i = -1;
    while rank(P_bar) < rank(ctrb(A_t,B_t))
        i = i + 1;
        P_bar = [P_bar A_t^i * B_t];
    end

i