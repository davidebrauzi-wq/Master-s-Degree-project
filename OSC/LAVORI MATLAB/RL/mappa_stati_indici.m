% Creiamo una mappa stati-indici per il TSP

% Anzitutto scrivo un vettore ausiliario
% serve per gli indici
% Ogni blocco di sottoinsiemi sono r(n-2,2)
n = 6;
r = zeros(n-2,2);
r(1,1) = 1;
r(1,2) = n-2;
for i = 2:n-2
    r(i,1) = r(i-1,2) + 1;
    r(i,2) = r(i,1) - 1 + nchoosek(n-2,i);
end

r

%%
clear all
% Insieme base
S = 1:5;

% Numero di sottoinsiemi: 2^n
n = numel(S);
numSottoinsiemi = 2^n;

% Inizializza cell array per contenere i sottoinsiemi
sottoinsiemi = cell(numSottoinsiemi - 1, 1);

% Genera tutti i sottoinsiemi
for i = 1:(numSottoinsiemi - 1)
    k = length(dec2bin(i) - '0');
    maschera = logical([zeros(1,n-k) , dec2bin(i) - '0']);  % bitmask binaria (vettore <-> double)
    sottoinsiemi{i} = S(maschera);    % seleziona elementi inclusi
end

% Visualizza i primi 5 sottoinsiemi come esempio
for k = 1:5
    disp(sottoinsiemi{k})
end

%% Capito come generare i sottoinsiemi, generiamo gli stati
clear all
clc
n = 6;
% Insieme di base
N = 2:n;

m_primo = 2^(n-2) - 1;
m = (2^(n-2) - 1) * (n-1); % Numero stati

% Inizializzo cell array per i sottoinsiemi
sottoinsiemi = strings(m,1);

for j = 2:n
    S = setdiff(N,j); % non posso prendere tutti i nodi di N
    % Genera tutti i sottoinsiemi
    succ = (j - 2) * m_primo;
    stringa = string(j);
    for i = 1:(m_primo)
        k = length(dec2bin(i) - '0');
        maschera = logical([zeros(1,n-k-2) , dec2bin(i) - '0']);  % bitmask binaria (vettore <-> double)
        sottoinsiemi(succ + i) = strcat(num2str(S(maschera))," , ",stringa);    % seleziona elementi inclusi
    end
end

sottoinsiemi

%%
parole = ["matlab", "è", "potente"];
v = strings(0,1);

for i = 1:length(parole)
    v(end+1) = parole(i);   % crea nuovo string array dinamicamente
end