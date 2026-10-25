reset;
param nome symbolic; # nome istanza in processamento;
param n;
param m;
set J := {1..n};
set M := {1..m};
set M_primo := {1..2*m};
param P{J,M_primo};
