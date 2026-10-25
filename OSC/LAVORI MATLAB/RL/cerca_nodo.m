close all
clear all

A = [
    5 3 9 2 8;
    1 4 7 6 0
];



riga = 1;
colonne_da_cercare = [1, 3, 5];

valori = A(riga, colonne_da_cercare);        % estrai i valori selezionati
[valore_max, idx_local] = max(valori);       % max tra i selezionati

indice_colonna = colonne_da_cercare(idx_local);  % indice nella matrice originale

% Output
fprintf('Il massimo è %d nella colonna %d\n', valore_max, indice_colonna);