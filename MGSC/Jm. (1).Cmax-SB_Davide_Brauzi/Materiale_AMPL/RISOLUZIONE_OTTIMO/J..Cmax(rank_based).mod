param m; # numero macchine
set MACHINE := 1 .. m;

param n; # numero job
set JOB := 1 .. n;

param num_oper{JOB}; # numero operazioni del job
set OPERATION{j in JOB} := 1 .. num_oper[j];

set POSITION := {1..card{JOB}};

param mu{j in JOB, h in OPERATION[j]} in MACHINE; # macchina impiegata dall'operazione h-esima del job j
param proc_time{j in JOB, h in OPERATION[j]} >= 0; # tempo di processamento dell'operazione h-esima del job j

#param M := sum{j in JOB, h in OPERATION[j]} proc_time[j,h]; # Big-M
param T;

var x{i in MACHINE, j in JOB, h in OPERATION[j], k in POSITION: mu[j,h] = i} >= 0, <= 1, integer; # se l'operazione h-esima del job j � schedulata in posizione k sulla macchina mu[j,h] = i
var f{i in MACHINE, k in POSITION union {0}} >= 0; # finish time operazione in posizione k sulla macchina i, la posizione 0 � fittizia

var Cmax;

minimize makespan : Cmax + 1e-6 * sum{i in MACHINE, k in POSITION} f[i,k];

subject to operation_pos_assignment{i in MACHINE, j in JOB, h in OPERATION[j]: mu[j,h] = i}: sum{k in POSITION} x[i,j,h,k] = 1;
subject to machine_pos_assignment{i in MACHINE, k in POSITION}: sum{j in JOB, h in OPERATION[j]: mu[j,h] = i} x[i,j,h,k] <= 1;

subject to makesp{i in MACHINE, k in POSITION}: f[i,k] <= Cmax;

subject to finish_time{i in MACHINE, k in POSITION}: f[i,k-1] + sum{j in JOB, h in OPERATION[j]: mu[j,h] = i} proc_time[j,h] * x[i,j,h,k] <= f[i,k];

subject to precedence_job{j in JOB, h in 1..num_oper[j]-1, k in POSITION, kbis in POSITION}:
sum{i in MACHINE: mu[j,h] = i} (f[i,k] - T*(1 - x[i,j,h,k])) <= sum{ibis in MACHINE: mu[j,h+1] = ibis} (f[ibis,kbis] - proc_time[j,h+1] * x[ibis,j,h+1,kbis] + T*(1 - x[ibis,j,h+1,kbis]));


