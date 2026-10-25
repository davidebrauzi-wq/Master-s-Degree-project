%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ESEMPIO DP PER LOT SIZING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
clc

% parametri costanti
Mp = 5;         % produzione massima giornaliera
Mm = 10;        % capacità massima di magazzino
N = 12;         % orizzonte temporale (da 0 a 11)
nx = Mm;        % numero massimo di stati (dimensione vettore stati - 1 in quanto includo lo 0) 
x = 0:1:nx;     % definisco x come un vettore di (nx + 1 componenti)

% definizione di domanda e costi di produzione e magazzino
rng(1)
dmax = 5;
d = randi(dmax,N-1,1);    % generazione casuale di domanda 
p = 2;                    % costo unitario di produzione
h = 0.2;                  % costo unitario di immagazzinamento
A = 10;                   % costo fisso di produzione

% calcolare la funzione Valore
% pre-allocazione della funzione valore
% V_k(x_k) -> V(k,x), per ogni k e per ogni x
V = inf*ones(N,nx+1); % devo includere anche lo 0 nello stato x
% V(k, x), V dipende da tempo k e stato x

% condizione terminale, end = N
V(end,1) = 0;
V(end,2:end) = 2; %*[1:nx];
% g_N(0) = 0; g_N(x) = 2; per ogni x in {1, ..., Mm}

% pre-allocazione del controllo ottimo (spdg a vettore di zeri)
u_star = zeros(N,nx);

% vogliamo calcolare la soluzione dell'equazione di Bellman

% iterazione rispetto al tempo (V(n) la conosco <=> condizione al contorno)
for k = (N-1):-1:1
    
    % iterazione rispetto agli stati x
    for i = 1:nx+1
        
        % determiniamo l'insieme ammissibile per u
        u_min = max(0,d(k)-x(i));
        u_max = min(Mp,Mm+d(k)-x(i));
        
        % risolviamo l'equazione di DP
        Vmin = inf; % pre-allocazione della variabile da aggiornare sui vari u possibili
        for u = u_min:u_max
            Vu = p*u+A*sign(u)^2+h*x(i)+V(k+1,x(i)+u-d(k)+1); % V_{k+1}(x_{k+1}), ricordando che x_{k+1} = x_{k} + u_{k} - d_{k} (+1, per colpa di Matlab, primo indice pari a 1)
            if Vu < Vmin % faccio bubble sort su u 
                Vmin = Vu;
                u_star(k,i) = u;
            end
            V(k,i) = Vmin; % si sarebbe potuto spostare giù probabilmente prima dell'end for sugli stati i
        end
        
    end
    
end

K = 1:1:N; %definisco vettore tempi
X = 0:1:nx; %definisco vettore stati
% funzione valore (funzione di x e k --> tabella)
V
figure(1)
hold on
grid on
xlim([0 nx])
ylim([1 N])
xlabel('x')
ylabel('k')
zlabel('V')
box on
addToolbarExplorationButtons(gcf)
surf(X,K,V)
% controllo ottimo (funzione di x e k --> tabella)
u_star
figure(2)
hold on
grid on
xlim([0 nx])
ylim([1 N])
xlabel('x')
ylabel('k')
zlabel('u')
box on
addToolbarExplorationButtons(gcf)
surf(X,K,u_star)
% domanda reale
d

%%

% evoluzione del magazzino (fase online dipendente ovviamente da x0 che è
% lo starting point)
clear x
x0 = 9; % quantità in magazzino all'inizio
x(1) = x0;  

costo = 0;
for j = 1:1:N-1 % (u(n) non esiste e x arriva fino ad x(n)
    u(j) = u_star(j,x(j)+1); % metto il +1 perchè la colonna x == 0 è la prima
    x(j+1) = x(j)+u(j)-d(j); 
    costo = costo + p*u(j)+A*sign(u(j))^2+h*x(j);
end

% grafico
figure(3)
hold on
box on
grid on
hold on
xlabel('k')
ylabel('x (verde),u (rosso)')
plot([0:1:N-1],x','go','MarkerFaceColor','green')  % grafico del magazzino 
plot([0:1:N-2],u','ro','MarkerFaceColor','red')    % grafico del controllo (produzione)
% plot([0:1:N-2],d,'bo','MarkerFaceColor','blue')  % grafico della domanda

