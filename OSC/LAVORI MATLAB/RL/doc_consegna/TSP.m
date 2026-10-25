% Tentiamo un approccio SARSA per la risoluzione del TSP
close all
clear all
clc

% Il primo passo è mappare gli stati
n = 7;
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

rng(77);
% generatore numeri casuali sempre uguali per ogni simulazione

%genero coordinate casuali
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

% Matrice distanze br17

% D = [
% 9999    3    5   48   48    8    8    5    5    3    3    0    3    5    8    8    5;
%     3 9999    3   48   48    8    8    5    5    0    0    3    0    3    8    8    5;
%     5    3 9999   72   72   48   48   24   24    3    3    5    3    0   48   48   24;
%    48   48   74 9999    0    6    6   12   12   48   48   48   48   74    6    6   12;
%    48   48   74    0 9999    6    6   12   12   48   48   48   48   74    6    6   12;
%     8    8   50    6    6 9999    0    8    8    8    8    8    8   50    0    0    8;
%     8    8   50    6    6    0 9999    8    8    8    8    8    8   50    0    0    8;
%     5    5   26   12   12    8    8 9999    0    5    5    5    5   26    8    8    0;
%     5    5   26   12   12    8    8    0 9999    5    5    5    5   26    8    8    0;
%     3    0    3   48   48    8    8    5    5 9999    0    3    0    3    8    8    5;
%     3    0    3   48   48    8    8    5    5    0 9999    3    0    3    8    8    5;
%     0    3    5   48   48    8    8    5    5    3    3 9999    3    5    8    8    5;
%     3    0    3   48   48    8    8    5    5    0    0    3 9999    3    8    8    5;
%     5    3    0   72   72   48   48   24   24    3    3    5    3 9999   48   48   24;
%     8    8   50    6    6    0    0    8    8    8    8    8    8   50 9999    0    8;
%     8    8   50    6    6    0    0    8    8    8    8    8    8   50    0 9999    8;
%     5    5   26   12   12    8    8    0    0    5    5    5    5   26    8    8 9999
% ];

D

COLORS = ["#FF5733", "#33FF57", "#3357FF", "#FF33A8", "#33FFF6", ...
          "#F6FF33", "#8E44AD", "#1ABC9C", "#E67E22", "#2ECC71", ...
          "#E74C3C", "#3498DB", "#9B59B6", "#34495E", "#16A085", ...
          "#F39C12", "#D35400", "#7F8C8D", "#BDC3C7", "#2C3E50"];

%%
close all % chiudo le figure
clc
syms s a s_primo a_primo
syms eps alpha

figure(3)
hold on
% Tracciamo tutti i punti
scatter(punti(:,1), punti(:,2), 'filled', 'MarkerFaceColor', 'black');

% Aggiungimo etichette ai punti
for i = 1:size(punti,1)
    stringa = string(i);
    text(punti(i,1)+0.1, punti(i,2), stringa, 'FontSize', 12);
end

title('Visualizzazione dei punti e del percorso');
xlabel('X');
ylabel('Y');

hold off


T = 1500; % numero di episodi che simuleremo
costi = zeros(1,T);
gamma = 1;
Q = zeros(m+2,n);

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

% La funzione restituisce l'output corretto
function a = eps_greedy(logic,Q,epsilon,A)
    % logic è il vettore logico che uso per la ricerca in Q
    if rand < epsilon 
        k = randi([1 length(A)]);
        a = A(k); % prendi il k-esimo elemento scelto random
    else 
        %fprintf("Prendo il massimo sui disponibili \n");
        [~,indice] = max(Q(logic,A)); % prendo l'arg-max
        a = A(indice);
    end
end

% Test funzione
% Q(sottoinsiemi == "1 , 2   3   4   5   6   7   8   9  11 , 12",3) = 50;
% Q(sottoinsiemi == "1 , 2   3   4   5   6   7   8   9  11 , 12",8) = 80;
% a = eps_greedy(sottoinsiemi == "1 , 2   3   4   5   6   7   8   9  11 , 12", Q, 0,1:n)

for t = 1:T % itero sui vari episodi
    A = 2:n;
    C_cum = 0; % non ci sono costi per il tour
    % Definizione dei parametri
    % Piu la simulazione avanza piu Q(s,a) non viene aggiornato
    alpha = 1 * 0.99995^t;
    eps = 1 * 0.945^t; % Par per epsilon Greedy
    %gamma = (1 * 0.99999^t);
    gamma = 1;

    % Il primo elemento del tour è sempre 1
    s = "1";
    X(1) = 1;
    for j = 1:n % itero sui nodi (visito il grafo)
        s,A
        if isempty(A) == 1 % non ho altri nodi da visitare (fine tour)
            a = 1; % torna al nodo 1 (stato terminale)
            s_primo = sottoinsiemi(m+2); % lo stato successivo è terminale
            a_primo = 1;
        end

        if isempty(A) == 0 % ho almeno un altro nodo da visitare
            a = eps_greedy(sottoinsiemi == s,Q,eps,A);
            A = setdiff(A,a); % elimino il nodo dai visitabili
            X(j+1) = a;
            v = str2num(s{1}(5:strlength(s))); % vettore contenente il set non ordinato in modo crescente
            v = sort(v); % vettore contenente il vettore dei nodi ordinati in modo crescente

            % A questo punto calcolo s_primo
            if isempty(v) == 1 % siamo alla prima iter dell'episodio
                s_primo = strcat("1 , ",string(a));
            else
                s_primo = strcat("1 , ",num2str(v)," , ",string(a));
            end

            % E infine calcolo a_primo
            if isempty(A) == 1
                A = 1;
            end
            a_primo = eps_greedy(sottoinsiemi == s_primo,Q,eps,A);
        end
        
        if strlength(s) >= 2 % prendo l'ultimo elemento del percorso attuale 
            caratteri = strlength(s) - 1:strlength(s);
        else
            caratteri = strlength(s);
        end
        r = - D(str2double(s{1}(caratteri)),a);
        % Aggiorno a questo punto Q(s,a)
        Q(sottoinsiemi == s,a) = Q(sottoinsiemi == s,a) * (1-alpha) + alpha * (r + gamma * Q(sottoinsiemi == s_primo, a_primo));
        s = s_primo;
        a, r
        X
        Q(1,:)
    end % fine episodio
    % Calcolo il costo cumulato
    for k = 1:n-1
        C_cum = C_cum + D(X(k),X(k+1));
    end
    C_cum = C_cum + D(X(n),1);
    costi(t) = C_cum;
    figure(1)
    scatter(t,C_cum,"magenta")
    if mod(t,100) == 0
        figure(3)
        hold on
        if t >= 100+1
            h_all = findobj(gca, 'Type', 'quiver');
            delete(h_all);
        end
        colore = COLORS(randi([1 length(COLORS)]));
        for i = 1:(length(X)-1)
            p1 = punti(X(i),1);
            p2 = punti(X(i),2);
            dx = punti(X(i+1),1) - punti(X(i),1);
            dy = punti(X(i+1),2) - punti(X(i),2);
            quiver(p1, p2, dx, dy, 0, 'LineWidth', 1, 'MaxHeadSize', 0.1, Color = colore);
        end
        hold off
    end
end % fine simulazione
%%
figure(2)
hold on
grid on
xlim([0 T])
title('Costo del tour durante la progressione episodica')
xticks(0:500:T)
plot(costi,LineStyle="--",Color="b",DisplayName="Valori");
plot(movmean(costi,20),LineStyle="-",Color="r",LineWidth=2,DisplayName="Media Mobile");
legend 






