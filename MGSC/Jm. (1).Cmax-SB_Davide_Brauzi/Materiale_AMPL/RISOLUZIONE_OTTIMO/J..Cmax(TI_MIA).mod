# Mia formulazione Time Indexed: TI(2) nella tesina
reset;
param m; # numero macchine
set MACHINE := 1 .. m;

param n; # numero job
set JOB := 1 .. n;

param num_oper{JOB}; # numero operazioni del job
set OPERATION{j in JOB} := 1 .. num_oper[j];
param mu{j in JOB, h in OPERATION[j]} in MACHINE; # macchina impiegata dall'operazione h-esima del job j
param proc_time{j in JOB, h in OPERATION[j]} >= 0; # tempo di processamento dell'operazione h-esima del job j

#param T := sum{j in JOB, h in OPERATION[j]} proc_time[j,h]; # numero di time slot unitari del tipo [t, t+1), upper bound sul makespan
param T;
set HORIZON := 0 .. T-1;
# Tempo di inizio minimo o massimo a causa dei vincoli precedenza sulle attivita del job j
param r1{j in JOB, h in OPERATION[j]}; # Minimo starting time
param r2{j in JOB, h in OPERATION[j]}; # Massimo starting time
param phi;

var x{j in JOB, h in OPERATION[j], t in HORIZON: t >= r1[j,h] and t <= r2[j,h]} >= 0, <= 1, integer; # se l'operazione h-esima del job j inizia al tempo t, cio� nel time slot [t, t+1), con t = 0 .. T - proc_time[j,h]

var Cmax;

minimize makespan : Cmax;# + 1e-6 * sum{j in JOB, h in OPERATION[j], t in HORIZON: t <= T - proc_time[j,h]} t * x[j,h,t];

subject to operation_start_time{j in JOB, h in 1..num_oper[j]}: sum{t in HORIZON: t >= r1[j,h] and t <= r2[j,h]} x[j,h,t] = 1;

subject to makesp{j in JOB}: (sum{t in HORIZON: t >= r1[j,num_oper[j]] and t <= r2[j,num_oper[j]]} t * x[j,num_oper[j],t]) + proc_time[j,num_oper[j]] <= Cmax;

subject to precedence_job{j in JOB, h in 1..num_oper[j]-1}: 
	(sum{t in HORIZON: t >= r1[j,h] and t <= r2[j,h]} t *x[j,h,t]) + proc_time[j,h] <= sum{t in HORIZON: t >= r1[j,h+1] and t <= r2[j,h+1]} t * x[j,h+1,t];

subject to machine_constraint{i in MACHINE, t in HORIZON}: 
	sum{j in JOB, h in OPERATION[j]: mu[j,h] = i and proc_time[j,h] > 0} sum{theta in HORIZON: theta >= max(t-proc_time[j,h]+1,r1[j,h]) and theta <= min(t,r2[j,h])} x[j,h,theta] <= 1;
	