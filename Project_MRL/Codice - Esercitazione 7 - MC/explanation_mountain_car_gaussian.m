clear all
close all
clc

% sigma 
sigma = .1;

% boundaries of the state space
X = [-1.2, 0.5];
V = [-0.07, 0.07];

% % draw profile
% xx = linspace(X(1),X(end),100);
% yy = sin(3*xx);
% figure()
% plot(xx,yy,'LineWidth',1.1)
% hold on
% plot(xx(end),yy(end),'s','MarkerSize',13,...
%     'MarkerEdgeColor','g',...
%     'MarkerFaceColor','g')
% xlim(X)

% action space
A = 2;
% we have continuous state space 
% we implement tile coding for function approximation
N = 3; % number of subdivision for each axis
M = 6; % number of grids

% dimension of weights
d = (N+1)^2*M*A;

% approximation for state space
w = randn(d,1);

% subdivide state space
xx = linspace(X(1),X(end),90);
vv = linspace(V(1),V(end),100);
[xxx, vvv] = meshgrid(xx, vv);
Q1 = zeros(size(xxx));
Q2 = zeros(size(xxx));
PolicyOpt = zeros(size(xxx));
for i1 = 1:size(xxx,1)
    for i2 = 1:size(xxx,2)
        % compute quality function for action 1
        Q1(i1,i2) = w'*state_action_features_gaussian([xxx(i1,i2),...
            vvv(i1,i2)], 1, X, V, N, M, A, sigma);
        % compute quality function for action 2
        Q2(i1,i2) = w'*state_action_features_gaussian([xxx(i1,i2),...
            vvv(i1,i2)], 2, X, V, N, M, A, sigma);
        % compute optimal policy
        PolicyOpt(i1,i2) = (Q2(i1,i2) > Q1(i1,i2)) + 1;
    end
end

figure('Position',[10, 10, 1200, 400])
subplot(1,3,1)
surf(xxx,vvv,Q1)
xlabel('$x$','Interpreter','latex')
ylabel('$v$','Interpreter','latex')
zlabel('$Q(s,1)$','Interpreter','latex')
subplot(1,3,2)
surf(xxx,vvv,Q2)
xlabel('$x$','Interpreter','latex')
ylabel('$v$','Interpreter','latex')
zlabel('$Q(s,2)$','Interpreter','latex')
subplot(1,3,3)
surf(xxx,vvv,PolicyOpt)
xlabel('$x$','Interpreter','latex')
ylabel('$v$','Interpreter','latex')
zlabel('Corresponding optimal policy','Interpreter','latex')