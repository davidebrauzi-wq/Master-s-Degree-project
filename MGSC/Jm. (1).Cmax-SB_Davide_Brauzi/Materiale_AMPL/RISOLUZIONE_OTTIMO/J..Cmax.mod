# Modello disgiuntivo
# Confrontare con la rank based.
reset;
param m; # numero macchine
set MACHINE := 1 .. m;

param n; # numero job
set JOB := 1 .. n;

param num_oper{JOB}; # numero operazioni del job
set OPERATION{j in JOB} := 1 .. num_oper[j];

param mu{j in JOB, h in OPERATION[j]} in MACHINE; # macchina impiegata dall'operazione h-esima del job j
param proc_time{j in JOB, h in OPERATION[j]} >= 0; # tempo di processamento dell'operazione h-esima del job j

#param T := sum{j in JOB, h in OPERATION[j]} proc_time[j,h]; # Big-M
param T;

var s{j in JOB, h in OPERATION[j]} >= 0; # starting time operazione h-esima del job j
var x{i in MACHINE, j in 1..n-1, h in OPERATION[j], j_primo in j+1..n, h_primo in OPERATION[j_primo]: mu[j,h] = i and mu[j_primo,h_primo] = i} >= 0, <= 1, integer;
# definisce la sequenza delle operazioni dei job che richiedono la macchina i in MACHINE

var Cmax;

minimize makespan : Cmax; # + 1e-6 * sum{j in JOB, h in OPERATION[j]} s[j,h];

subject to makesp{j in JOB}: s[j,num_oper[j]] + proc_time[j,num_oper[j]] <= Cmax;
#subject to makesp{j in JOB, h in OPERATION[j]}: s[j,h] + proc_time[j,h] <= Cmax;

subject to precedence_job{j in JOB, h in 1..num_oper[j]-1}: 
	s[j,h] + proc_time[j,h] <= s[j,h+1];

subject to precedence_machine_1{i in MACHINE, j in 1..n-1, h in OPERATION[j], j_primo in j+1..n, h_primo in OPERATION[j_primo]: mu[j,h] = i and mu[j_primo,h_primo] = i}: 
	s[j,h] + proc_time[j,h] <= s[j_primo,h_primo] + T * (1 - x[i,j,h,j_primo,h_primo]);
subject to precedence_machine_2{i in MACHINE, j in 1..n-1, h in OPERATION[j], j_primo in j+1..n, h_primo in OPERATION[j_primo]: mu[j,h] = i and mu[j_primo,h_primo] = i}: 
	s[j_primo,h_primo] + proc_time[j_primo,h_primo] <= s[j,h] + T * x[i,j,h,j_primo,h_primo];
