close all
clear all
clc

load("Sl.mat")
load("Qp.mat")
load("DQ.mat")

%%
Q_DQ = (Q1_DQ + Q2_DQ) / 2;

v = size(Q_DQ);
S = v(1);
A = v(2);

v_DQ = zeros(S,1);
v_Qp = zeros(S,1);
v_Sl = zeros(S,1);

% compute value functions
for s = 1:S
    v_DQ(s) = max(Q_DQ(s,:));
    v_Qp(s) = max(Q_Qp(s,:));
    v_Sl(s) = max(Q_Sl(s,:));
end

%%
% plot value functions
figure()
plot(v_DQ,'-r',LineWidth=2,DisplayName='v_{DQ}')
hold on
plot(v_Qp,'-b',DisplayName='v_{dQ+}')
plot(v_DQ,'-g',DisplayName='v_{S\lambda}')
grid on
legend

%% Plot rewards

figure()

subplot(3,1,1)
plot(tR_DQ(10:100),'-r')
hold on
grid on
%plot(movmean(tR_DQ,10),'-r',LineWidth=2)
title('Rewards DQ',Interpreter='latex')

subplot(3,1,2)
plot(tR_Qp(10:100),'b')
hold on
grid on
%plot(movmean(tR_Qp,10),'-b',LineWidth=2)
title('Rewards dQ+',Interpreter='latex')

subplot(3,1,3)
plot(tR_Sl(10:100),'g')
hold on
grid on
%plot(movmean(tR_Sl,10),'-g',LineWidth=2)
title('Rewards S$\lambda$',Interpreter='latex')
