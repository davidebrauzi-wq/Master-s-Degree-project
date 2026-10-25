param n_primo;
set JOB := {1..n_primo};
set POSITION := {1..n_primo};

param proc_time{JOB} >= 0;
param release_date{JOB} >= 0;
param due_date{JOB} >= 0;

var x{JOB,POSITION} >= 0, <= 1, integer;
var comp_time{POSITION union {0}} >= 0;
var Lmax;

minimize z : Lmax;
subject to job_assignment{j in JOB}: sum{l in POSITION} x[j,l] = 1;
subject to pos_assignment{l in POSITION}: sum{j in JOB} x[j,l] = 1;

subject to compl_time_constr_1{l in POSITION}: comp_time[l] >= sum{j in JOB} release_date[j] * x[j,l] + sum{j in JOB} proc_time[j] * x[j,l];
subject to compl_time_constr_2{l in POSITION}: comp_time[l] >= comp_time[l-1] + sum{j in JOB} proc_time[j] * x[j,l];
subject to compl_time_pos_0: comp_time[0] = 0;

subject to L_job_in_position{l in POSITION}: comp_time[l] - sum{j in JOB} due_date[j] * x[j,l] <= Lmax;
