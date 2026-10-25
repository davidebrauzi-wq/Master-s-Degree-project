% Tentiamo un approccio SARSA per la risoluzione del TSP
close all
clear all
clc

% Codifichiamo un'istanza arbitrariamente piccola
% Matrice delle distanze quadrata
% D =  [9999    3    5   48   48    8    8    5    5    3    3    0    3    5    8    8 5;
%     3 9999    3   48   48    8    8    5    5    0    0    3    0    3    8    8 5;
%     5    3 9999   72   72   48   48   24   24    3    3    5    3    0   48   48 24;
%    48   48   74 9999    0    6    6   12   12   48   48   48   48   74    6    6 12;
%    48   48   74    0 9999    6    6   12   12   48   48   48   48   74    6    6 12;
%     8    8   50    6    6 9999    0    8    8    8    8    8    8   50    0    0 8;
%     8    8   50    6    6    0 9999    8    8    8    8    8    8   50    0    0 8;
%     5    5   26   12   12    8    8 9999    0    5    5    5    5   26    8    8 0;
%     5    5   26   12   12    8    8    0 9999    5    5    5    5   26    8    8 0;
%     3    0    3   48   48    8    8    5    5 9999    0    3    0    3    8    8 5;
%     3    0    3   48   48    8    8    5    5    0 9999    3    0    3    8    8 5;
%     0    3    5   48   48    8    8    5    5    3    3 9999    3    5    8    8 5;
%     3    0    3   48   48    8    8    5    5    0    0    3 9999    3    8    8 5;
%     5    3    0   72   72   48   48   24   24    3    3    5    3 9999   48   48 24;
%     8    8   50    6    6    0    0    8    8    8    8    8    8   50 9999    0 8;
%     8    8   50    6    6    0    0    8    8    8    8    8    8   50    0 9999 8;
%     5    5   26   12   12    8    8    0    0    5    5    5    5   26    8    8 9999];
% 

COLORS = ["#FF5733", "#33FF57", "#3357FF", "#FF33A8", "#33FFF6", ...
          "#F6FF33", "#8E44AD", "#1ABC9C", "#E67E22", "#2ECC71", ...
          "#E74C3C", "#3498DB", "#9B59B6", "#34495E", "#16A085", ...
          "#F39C12", "#D35400", "#7F8C8D", "#BDC3C7", "#2C3E50"];

M = 5;

punti = zeros(M,2);

rng(101);
% generatore numeri casuali sempre uguali per ogni simulazione

% genero coordinate casuali
for j = 1:M 
    punti(j,1) = randi([10 20]);
    punti(j,2) = randi([10 20]);
end

D = zeros(M,M);
for i = 1:M
    for j = 1:M
        if i == j 
            D(i,j) = 9999;
        else
            D(i,j) = sqrt((punti(i,1) - punti(j,1))^2 + (punti(i,2) - punti(j,2))^2);
        end
    end
end

%%
syms alpha eps gamma;

% Inizializzo la matrice Q
Q = zeros(M,M);

syms r s a s_primo a_primo; % parametri per l'aggiornamento SARSA
syms k; % parametro per scegliere un elemento random dell' insieme dei nodi da visitare

N = 300; % numero di episodi per l'apprendimento
costi = zeros(1,N);
eps_s = zeros(1,N);
alpha_s = zeros(1,N);
norma_Q = zeros(1,N);

X = zeros(1,M); % vettore rappresentativo del tour in esecuzione
X_star = 1:M; % vettore ottimo iniziale arbitrario
C_star = 0;
for k = 1:M-1
    C_star = C_star + D(k,k+1);
end
C_star = C_star + D(M,1);

C_cum = 0; % costo cumulato dell'episodio

% Iteriamo sugli episodi
for t = 1:N
    X = [zeros(1,M)]; % inizializzo tour episodio corrente
    A = 2:M; % Aggiorno le azioni possibili
    C_cum = 0; % inizializzo il costo cumulato
    %alpha = 1 / t;
    alpha = 0;
    % if t <= N/3
    %     eps = 1 - 0.9*3/N * t;
    % elseif (N/3 < t) && (t <= 2/3*N)
    %     eps = 0.1 - 0.1*3/N * (t - N/3);
    % else
    %     eps = 0;
    % end
    eps = 0;
    %gamma = gamma_min + (gamma_max - gamma_min) * (t - 1) / (N + 1);
    gamma = 1;

    for j = 1:M-1 % itero tra i nodi 
        %A
        Q
        if j == 1 % primo nodo del ciclo spdg e sempre 1 
            s = 1;
            X(1) = 1;
        end
        % Seleziona l'azione u secondo logica eps-greedy
        if rand < eps 
            k = randi([1 length(A)]);
            %k
            a = A(k); % prendi il k-esimo elemento scelto random
        else 
            fprintf("Prendo il massimo sui disponibili \n");
            [m,indice] = max(Q(s,A)); % prendo l'arg-max
            a = A(indice);
        end
        %a
        A = setdiff(A,a); % Aggiorno le azioni possibili
        X(j+1) = a; % Aggiorno nodo nel tour
        C_cum = C_cum + D(s,a); % Aggiorno costo cumulato
            if length(A) >= 1
                r = - D(s,a);
                s_primo = a;
                if rand < eps 
                    k = randi([1 length(A)]);
                    a_primo = A(k); % prendi il k-esimo elemento scelto random
                else
                    [m,indice] = max(Q(s_primo,A)); % prendo l'arg-max
                    a_primo = A(indice);
                end
                Q(s,a) = Q(s,a) + alpha * (r + gamma * Q(s_primo,a_primo) - Q(s,a));
            end
        s
        a
        s = a;
        %A
    end
    X
    C_cum = C_cum + D(X(M),X(1));
    if C_cum < C_star
        C_star = C_cum;
        X_star = X;
    end

    figure(1);
    hold on;
    axis equal;
    grid on;
    
    if t >= 2 
        delete(findall(gca, 'Type', 'line')); 
    end
    % Tracciamo tutti i punti
    scatter(punti(:,1), punti(:,2), 'filled', 'MarkerFaceColor', 'black');
    
    % Aggiungimo etichette ai punti
    for i = 1:size(punti,1)
        stringa = string(i);
        text(punti(i,1)+0.1, punti(i,2), stringa, 'FontSize', 12);
    end
    
    % Disegnamo il percorso seguendo la sequenza
    colore = COLORS(randi([1 length(COLORS)]));
    for i = 1:(length(X)-1)
        p1 = punti(X(i), :);
        p2 = punti(X(i+1), :);
        plot([p1(1), p2(1)], [p1(2), p2(2)], 'LineStyle', '--', 'LineWidth', 1, 'Color', colore);
    end
    
    title('Visualizzazione dei punti e del percorso');
    xlabel('X');
    ylabel('Y');

    hold off
    costi(t) = C_cum;
    eps_s(t) = eps;
    alpha_s(t) = alpha;
    norma_Q(t) = norm(Q,2);
    if C_cum < C_star
        C_star = C_cum;
        X_star = X;
    end
end
C_star
X_star;
Q;

%%

figure(2)
hold on
grid on 
plot(costi, 'Color','blue')
title('Costo del tour')
xlabel('Episodi')

figure(3)
hold on
grid on 
plot(alpha_s, 'Color','green')
title('andamento di \alpha , parametro comb lineare')
ylabel('\alpha(t)')
xlabel('Episodi')

figure(4)
hold on
grid on 
plot(eps_s, 'Color','red')
title('andamento di \epsilon per l esplorazione greedy')
ylabel('\epsilon(t)')
xlabel('Episodi')

figure(5)
hold on
grid on 
plot(norma_Q, 'Color','black')
title('andamento norma Q')
ylabel('norm(Q)')
xlabel('Episodi')

%% 
prova_costo = 0;
for k = 1:M-1
    prova_costo = prova_costo + D(X_star(k),X_star(k+1));
end
prova_costo = prova_costo + D(X_star(M),X_star(1));