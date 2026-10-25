clear all
close all
clc

rng(1)

% number of episodes 
numEpisodes = 1000; 
epsilon = 0.1;
alpha = 1e-3;
gamma = 0.999;
sigma = 0.2;

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

% approximation for state space
w = randn(d,1);

% total return
totalReturn = zeros(numEpisodes,1);

for e = 1:numEpisodes
    % initialize episode
    s = [0, 0];
    % take epsilon greedy action
    a = eps_greedy(s, w, X, V, N, M, A, epsilon);
    % compute current vector of features
    x = state_action_features_gaussian(s, a, X, V, N, M, A, sigma);
    % initialize isTerminal
    isTerminal = false;
    while isTerminal == 0
        % apply action and measure sp and r
        [sp, r, isTerminal] = mc_dynamics(s, a, X, V);
        totalReturn(e) = totalReturn(e) + r;
        if isTerminal
            % Update weights based on the reward received
            w = w + alpha*(r - w'*x)*x ;
        else
            % precommitment of next action
            ap = eps_greedy(sp, w, X, V, N, M, A, epsilon);
            % compute next vector of features
            xp = state_action_features_gaussian(sp, ap, X, V, N, M, A, sigma);
            % temporal difference error
            delta = r + w'*(gamma*xp - x);
            % apply update
            w = w + alpha*delta*x;

            % go to next state and action
            s = sp;
            a = ap;
            x = xp;
        end

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
Vstar = zeros(size(xxx));
PolicyOpt = zeros(size(xxx));
for i1 = 1:size(xxx,1)
    for i2 = 1:size(xxx,2)
        % compute quality function for action 1
        Q1(i1,i2) = w'*state_action_features_gaussian([xxx(i1,i2),...
            vvv(i1,i2)], 1, X, V, N, M, A, sigma);
        % compute quality function for action 2
        Q2(i1,i2) = w'*state_action_features_gaussian([xxx(i1,i2),...
            vvv(i1,i2)], 2, X, V, N, M, A, sigma);
        % compute optimal value function
        Vstar(i1,i2) = max([Q1(i1,i2),Q2(i1,i2)]);
        % compute optimal policy
        PolicyOpt(i1,i2) = (Q2(i1,i2) > Q1(i1,i2)) + 1;
    end
end

figure('Position',[10, 10, 1200, 400])
subplot(1,2,1)
surf(xxx,vvv,Vstar)
xlabel('$x$','Interpreter','latex')
ylabel('$v$','Interpreter','latex')
zlabel('$V_\star$','Interpreter','latex')
subplot(1,2,2)
surf(xxx,vvv,PolicyOpt)
xlabel('$x$','Interpreter','latex')
ylabel('$v$','Interpreter','latex')
zlabel('Corresponding optimal policy','Interpreter','latex')