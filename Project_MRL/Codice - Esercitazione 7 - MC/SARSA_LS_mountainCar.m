clear all
close all
clc

rng(1)

% number of episodes 
numEpisodes = 100; 
epsilon = 0.1;
% alpha = 1e-2; no more needed since we directly go to the solution
gamma = 1;

% boundaries of the state space
X = [-1.2, 0.5];
V = [-0.07, 0.07];

% action space
A = 2;
% we have continuous state space 
% we implement tile coding for function approximation
N = 3; % number of subdivision for each axis
M = 6; % number of grids

% dimension of weights
d = (N+1)^2*M*A;

% approximation for inv(A) and b
iA = 1e6*eye(d);
b = zeros(d,1);
% approximation for state space
w = iA*b;

% total return
totalReturn = zeros(numEpisodes,1);

for e = 1:numEpisodes
    % initialize episode
    s = [0, 0];
    % take epsilon greedy action
    a = eps_greedy(s, w, X, V, N, M, A, epsilon);
    % compute current vector of features
    x = state_action_features(s, a, X, V, N, M, A);
    % initialize isTerminal
    isTerminal = false;
    while isTerminal == 0
        % apply action and measure sp and r
        [sp, r, isTerminal] = mc_dynamics(s, a, X, V);
        totalReturn(e) = totalReturn(e) + r;
        % precommitment of next action
        ap = eps_greedy(sp, w, X, V, N, M, A, epsilon);
        % compute next vector of features
        xp = state_action_features(sp, ap, X, V, N, M, A);
        % apply the least squares
        b = b + r*x;
        iA = iA - (iA*x*(x-gamma*xp)'*iA)/(1 + (x-gamma*xp)'*iA*x);
        % go to next state and action
        s = sp;
        a = ap;
        x = xp;

        if mod(e,numEpisodes) == 0
            figure(1)
            clf
            xx = linspace(X(1),X(end),100);
            yy = sin(3*xx);
            plot(xx,yy,'LineWidth',1.1)
            hold on
            plot(xx(end),yy(end),'s','MarkerSize',13,...
                'MarkerEdgeColor','g',...
                'MarkerFaceColor','g')
            plot(s(1),sin(3*s(1)), 'o','MarkerSize',13,...
                'MarkerEdgeColor','r',...
                'MarkerFaceColor','r')
            xlim(X)
            pause(.1)
        end
        % update w
        w = iA*b;
    end
    % print time
    disp(totalReturn(e))
end

figure()
plot(totalReturn)

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
        Q1(i1,i2) = w'*state_action_features([xxx(i1,i2),...
            vvv(i1,i2)], 1, X, V, N, M, A);
        % compute quality function for action 2
        Q2(i1,i2) = w'*state_action_features([xxx(i1,i2),...
            vvv(i1,i2)], 2, X, V, N, M, A);
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