% Tentiamo un approccio SARSA per la risoluzione del TSP
close all
clear all
clc

% Il primo passo è mappare gli stati
n = 12;
% Insieme di base
N = 2:n;

m_primo = 2^(n-2);
m = (2^(n-2)) * (n-1); % Numero stati

% Inizializzo cell array per i sottoinsiemi
sottoinsiemi = strings(m+1+1,1); % aggiungo stato iniziale e terminale
sottoinsiemi(1) = '1';

for j = 2:n
    S = setdiff(N,j); % non posso prendere tutti i nodi di N
    % Genera tutti i sottoinsiemi
    succ = (j - 2) * m_primo;
    stringa = string(j);
    for i = 1:(m_primo-1)
        k = length(dec2bin(i) - '0');
        maschera = logical([zeros(1,n-k-2) , dec2bin(i) - '0']);  % bitmask binaria (vettore <-> double)
        sottoinsiemi(succ + i + 1) = strcat("1 , ",num2str(S(maschera))," , ",stringa);    % seleziona elementi inclusi
    end
    sottoinsiemi(succ + m_primo + 1) = strcat("1 , ",stringa);
end
sottoinsiemi(m+1+1) = strcat("1 , ",num2str(2:n)," , ",string(1));
sottoinsiemi

%%

COLORS = ["#FF5733", "#33FF57", "#3357FF", "#FF33A8", "#33FFF6", ...
          "#F6FF33", "#8E44AD", "#1ABC9C", "#E67E22", "#2ECC71", ...
          "#E74C3C", "#3498DB", "#9B59B6", "#34495E", "#16A085", ...
          "#F39C12", "#D35400", "#7F8C8D", "#BDC3C7", "#2C3E50"];

punti = zeros(n,2);

rng(42);
% generatore numeri casuali sempre uguali per ogni simulazione

% genero coordinate casuali
for j = 1:n 
    punti(j,1) = randi([10 20]);
    punti(j,2) = randi([10 20]);
end

D = zeros(n,n);

for i = 1:n
    for j = 1:n
        if i == j 
            D(i,j) = 0;
        else
            D(i,j) = sqrt((punti(i,1) - punti(j,1))^2 + (punti(i,2) - punti(j,2))^2);
        end
    end
end

D

%%
close all % chiudo le figure
clc
syms s a s_primo a_primo
syms eps alpha

T = 1000; % numero di episodi che simuleremo
gamma = 1;
Q = zeros(m+2,n);
Q(1,:) = - D(1,:);
% Ho già inizializzato al valore corretto la Q sullo stato terminale
X = zeros(1,n);
X_star = 1:n; % vettore ottimo iniziale arbitrario
C_star = 0;
% Calcolo il costo del vettore iniziale arbitrario
for k = 1:n-1
    C_star = C_star + D(k,k+1);
end
C_star = C_star + D(n,1);

% Creo la figura per il plot del valore del ciclo tra i vari episodi
figure(1)
hold on 
grid on
xlim([0 T])
title('Costo del tour durante la progressione episodica')
xticks(0:500:T)

for t = 1:T
    A = 2:n; % reinizializzo le azioni possibili
    C_cum = 0;
    alpha = max(0.5 * 0.935^t);
    eps = max(0.01, 1 * 0.991^t);
    gamma = (1 * 0.895^t);
    % if t <= T/3
    %     eps = 1 - 0.9*3/T * t;
    % elseif (T/3 < t) && (t <= 2/3*T)
    %     eps = 0.1 - 0.1*3/T * (t - T/3);
    % else
    %     eps = 0;
    % end
    % Inizializzo l'episodio
    s = "1";
    X(1) = 1;
    for j = 1:n % itero sui nodi (visito il grafo)
        fprintf("Step \n")
        n
        A
        s
        if isempty(A) == 1 
            a = 1; % torno al nodo 1 e sono pronto a terminare l'episodio
        else % Posso eseguire un'azione
            if rand + 0.08 < eps 
                k = randi([1 length(A)]);
                %k
                a = A(k); % prendi il k-esimo elemento scelto random
            else 
                %fprintf("Prendo il massimo sui disponibili \n");
                [phi,indice] = max(Q(sottoinsiemi==s,A)); % prendo l'arg-max
                a = A(indice);
            end
            X(j+1) = a;
            A = setdiff(A,a); % Aggiorno le azioni possibili
        end
        % Calcolo in ogni caso il ricavo
        if strlength(s) >= 2
            caratteri = strlength(s) - 1:strlength(s);
        else
            caratteri = strlength(s);
        end
        r = - D(str2double(s{1}(caratteri)),a);
        v = str2num(s{1}(5:strlength(s))); % vettore contenente il set ordinato in modo crescente
        % metto lo stato finale nell'insieme e aggiorno s_primo
        v = sort(v); 
        a, r
        if isempty(v) == 1 % siamo alla prima iter dell'episodio
            s_primo = strcat("1 , ",string(a));
        else
            s_primo = strcat("1 , ",num2str(v)," , ",string(a));
        end
        if isempty(A) == 1 
            a_primo = 1; % spdg metto un controllo verso 1
        elseif isempty(A) == 0 % posso andare in un altro nodo
            if rand + 0.08 < eps 
                k = randi([1 length(A)]);
                a_primo = A(k); % prendi il k-esimo elemento scelto random
            else
                [phi,indice] = max(Q(sottoinsiemi == s_primo,A)); % prendo l'arg-max
                a_primo = A(indice);
            end
        end
        Q(sottoinsiemi == s,a) = Q(sottoinsiemi == s,a) + alpha * (r + gamma * Q(sottoinsiemi == s_primo, a_primo) - Q(sottoinsiemi == s,a));
        s = s_primo;
    end % sono arrivato ad un nodo terminale
    for k = 1:n-1
        C_cum = C_cum + D(X(k),X(k+1));
    end
    C_cum = C_cum + D(X(n),1);
    % if C_cum < C_star
    %     C_star = C_cum;
    %     X_star = X;
    % end
    figure(1)
    scatter(t,C_cum,"magenta")

    % figure(2);
    % hold on;
    % axis equal;
    % grid on;
    % 
    % if t >= 2 
    %     delete(findall(gca, 'Type', 'line')); 
    % end
    % % Tracciamo tutti i punti
    % scatter(punti(:,1), punti(:,2), 'filled', 'MarkerFaceColor', 'black');
    % 
    % % Aggiungimo etichette ai punti
    % for i = 1:size(punti,1)
    %     stringa = string(i);
    %     text(punti(i,1)+0.1, punti(i,2), stringa, 'FontSize', 12);
    % end
    % 
    % % Disegnamo il percorso seguendo la sequenza
    % colore = COLORS(randi([1 length(COLORS)]));
    % for i = 1:(length(X)-1)
    %     p1 = punti(X(i), :);
    %     p2 = punti(X(i+1), :);
    %     plot([p1(1), p2(1)], [p1(2), p2(2)], 'LineStyle', '--', 'LineWidth', 1, 'Color', colore);
    % end
    % 
    % title('Visualizzazione dei punti e del percorso');
    % xlabel('X');
    % ylabel('Y');
    % 
    % hold off
end
    