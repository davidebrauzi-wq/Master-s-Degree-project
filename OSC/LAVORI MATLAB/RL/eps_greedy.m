% Proviamo la eps-greedy
close all
clear all
clc
T = 1000;
figure(1)
hold on 
grid on
xlim([0 T])
title('Costo del tour durante la progressione episodica')
xticks(0:100:T)
for t = 1:T
    eps = max(0.01, 1 * 0.990^t);
     if rand + 0.03 < eps 
        k = 1;
    else 
        k = 0;
    end
    figure(1)
    scatter(t,k,"magenta")
end
