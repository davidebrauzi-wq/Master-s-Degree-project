%PROGETTO MOVIMENTAZIONE OTTIMA SC CON LQ%
%%DAVIDE BRAUZI - A.A. 2024/2025%%
%PRIMO SCRIPT PER SINTESI MATRICI x_{k+1} = Ax_{k} + Bu_{k}

clear all
close all
clc

%scrivo la matrice dei lead time sui nodi della supply chain (da 7 a 1 <=> da valle a monte)
D = [zeros(2,7);
     2 4 0 0 0 0 0;
     3 2 0 0 0 0 0;
     0 0 3 4 0 0 0;
     0 0 3 3 0 0 0;
     0 0 5 2 0 0 0];

D = D'; % traspongo per avere la matrice comoda dal punto di vista algoritmico D(i,j) = L sse i riceve merce da j in L unita di tempo

%%
num_controlli = 0; % numero controlli del sistema
n = 7; % numero dei nodi della supply chain
pos = [1 zeros(1,6)]; % vettore delle posizioni dei nodi nello spazio dello stato
for i = 1:n
    if i == 1
        A = 1;
    else
        A = blkdiag(A,1);
        pos(i) = height(A);
    end
    for j = 1:n
        if D(i,j) >= 1 % ho un effettiva possibilita di trasporto
            num_controlli = num_controlli + 1;
            A = blkdiag(A,diag(ones(D(i,j)-1, 1), 1)); % inserisco la matrice di trasp in diagonale
        end
    end
end

size(A)
% Manca da aggiungere alla matrice A gli 1^{i} relativi agli elementi delle
% righe dei nodi in corrispondenza dei buffer più prossimi (lo facciamo
% nella prossima sezione)

%% Scrivo Matrice A_t
% A_t = A + A_p
p = 0; % indice riga A_p
q = 0; % indice colonna A_p
m = 0; % indice per tenere conto delle varie relazioni tra nodi in termini di L complessivo

A_p = zeros(height(A),height(A)); % inizializzo

for i = 1:n
    m = 0;
    q = q + 1;
    p = p + 1;
    for j = 1:n
        if D(i,j) >= 1
           m = m + D(i,j);
           q = q + 1; 
           A_p(p,q) = 1;
           q = q + D(i,j) - 1;
        end
    end
    p = p + m;
end

A_t = A + A_p;

writematrix(A_t,"Matrice_A_t.xlsx","Sheet","Sheet1")
% Manca da scrivere la matrice A_t su excel.
% Matrice A_t ben elaborata, per il resto del codice viene presa in input
% da Excel

%% Scrittura matrice B del sistema dinamico x_{k + 1} = A x_{k} + B u_{k}
A_t = readmatrix("Matrice_A_t.xlsx", 'Sheet', 'Sheet1', 'Range','B2:AM39');
m = 10;
n_primo = height(A_t);
B_t = zeros(n_primo,m);
l = 0; % contatore colonne B
eta = 0; % contatore coppie monte-valle nodi
n = 7;
pos = [1 7 14 26 36 37 38]; % posizioni nodi nello stato z_{k}
for i = 1:n
    eta = 1; % inizializzo il contatore del lead time complessivo per ogni nodo
    for j = 1:n
        if D(i,j) > 0 % solita condizione del Lead Time>0 (ho possibilita di mandare merce)
            l = l + 1;
            B_t(pos(j),l) = - 1; % controllo uscente dal nodo più a monte
            B_t(pos(i) + eta + D(i,j) - 1,l) = 1; % controllo entrante nel buffer più vicino al nodo più a monte
            eta = eta + D(i,j); % incremento eta e passo al primo buffer del secondo nodo più a monte di i
        end
    end
end

writematrix(B_t,"Matrice_B_t.xlsx","Sheet","Sheet1")
