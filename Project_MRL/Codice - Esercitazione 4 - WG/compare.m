clear all
close all
clc

% load SARSA data
load SARSA.mat
timeS = totalReturn;
QS = Q;

% load ESARSA data
load ESARSA.mat
timeES = totalReturn;
QES = Q;

% load Qlearning data
load Qlearning.mat
timeQ = totalReturn;
QQ = Q;

% load Qlearning data off policy
load Qlearning_off.mat
QQ_off = Q;

% load Qlearning data
load DoubleQlearning.mat
timeDQ = totalReturn;
QDQ = 1/2*(Q1+Q2);

% estimate the value functions and the optimal policy
% state and action spaces
S = size(QQ,1);
A = size(QQ,2);

% optimal value function
VS = zeros(S,1);
VES = zeros(S,1);
VQ = zeros(S,1);
VQ_off = zeros(S,1);
VDQ = zeros(S,1);

% optimal policies
pistarS = zeros(S,1);
pistarES = zeros(S,1);
pistarQ = zeros(S,1);
pistarQ_off = zeros(S,1);
pistarDQ = zeros(S,1);

% compute optimal value and policy on the basis of Q
for s = 1:S
    % value function
    VS(s) = max(QS(s,:));
    VES(s) = max(QES(s,:));
    VQ(s) = max(QQ(s,:));
    VQ_off(s) = max(QQ_off(s,:));
    VDQ(s) = max(QDQ(s,:));

    % policy
    pistarS(s) = find(QS(s,:) == max(QS(s,:)), 1, "first");
    pistarES(s) = find(QES(s,:) == max(QES(s,:)), 1, "first");
    pistarQ(s) = find(QQ(s,:) == max(QQ(s,:)), 1, "first");
    pistarQ_off(s) = find(QQ_off(s,:) == max(QQ_off(s,:)), 1, "first");
    pistarDQ(s) = find(QDQ(s,:) == max(QDQ(s,:)), 1, "first");
end

figure()
plot(timeQ);
hold on
plot(timeS);
plot(timeES);
plot(timeDQ);
legend("Q-learning","SARSA","Expected SARSA","Double Q-learning")

figure()
plot(VQ);
hold on
plot(VQ_off);
plot(VS);
plot(VES);
plot(VDQ);
legend("Q-learning","Q-learning off policy","SARSA","Expected SARSA",...
    "Double Q-learning")


figure()
stairs(pistarQ);
hold on
stairs(pistarQ_off);
stairs(pistarS);
stairs(pistarES);
stairs(pistarDQ);
legend("Q-learning","Q-learning off policy","SARSA","Expected SARSA",...
    "Double Q-learning")