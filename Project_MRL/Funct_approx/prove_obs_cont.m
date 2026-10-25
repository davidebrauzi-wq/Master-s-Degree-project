close all
clear all
clc

% robot parameters
L1 = 3;
L2 = 5;

% obstacles position
obs(1).center = [-3, -2];   % [x, y]
obs(1).radius = 2;

obs(2).center = [8 -4];
obs(2).radius = 3;

obs(3).center = [8 4];
obs(3).radius = 4;

obs(4).center = [2 6];
obs(4).radius = 2;

obs(5).center = [-2 6];
obs(5).radius = 2;

obs(6).center = [-6 5];
obs(6).radius = 2;

% obs(1).center = [10, 10];   % [x, y]
% obs(1).radius = 2;


k = zeros(length(obs),1);

% Plot obstacles and operative space
figure(1); hold on;
axis equal
theta = linspace(0, 2*pi, 100);

% now plot operative space
x = (L1+L2) * cos(theta);
y = (L1+L2) * sin(theta);
fill(x, y, 'blue','FaceAlpha', 0.1);

x = abs(L1-L2) * cos(theta);
y = abs(L1-L2) * sin(theta);
fill(x, y, 'white','FaceAlpha', 1);

grid on;

% now obstacles
for i = 1:length(obs)
    x = obs(i).center(1) + obs(i).radius * cos(theta);
    y = obs(i).center(2) + obs(i).radius * sin(theta);
    k(i) = fill(x, y, 'g', 'FaceAlpha', 0.5);
end

%% SARSA(lambda)
% Algorithm with obstacles
rng(1)

% number of episodes 
numEpisodes = 5000; 
epsilon = 0.2;
epsilon_min = 0.01;
beta = 0.999;

alpha = 1e-3;
gamma = 1;
lambda = .1;

% boundaries of the state space
Q1 = [0, 2*pi];
Q2 = [0, 2*pi];

% parameter for shift in angular position
tau = 2*pi / 32;

% action space
A = 9;
% we have continuous state space 
% we implement tile coding for function approximation
N = 6; % number of subdivision for each axis
M = 36; % number of grids

% dimension of weights
d = (N+1)^2*M*A;

% approximation for state space
w = randn(d,1);

% total return
totalReturn = zeros(numEpisodes,1);

%% check if it starts and ends not on obstacles
s0 = [-pi/2, 0];
sf = [3/4 * pi, pi/2];
p1 = direct_kin_cont(s0,L1,L2);
p2 = direct_kin_cont(sf,L1,L2);
EE_d = p2(3:4); % desired pos of EE
figure(1)
hold on
h1 = robot(p1);
h2 = robot(p2);
grid on
axis equal
% xlim([-10 10]);
% ylim([-10 10]);

obstacles_collision(p1,obs)
obstacles_collision(p2,obs)

%% Algorithm run (SARSA_SGD_ET)
delete(h2);
for e = 1:numEpisodes
    disp(e)
    epsilon = max(epsilon_min,epsilon *  beta);
    % initialize episode
    s = s0;
    % initialize eligibility traces
    z = zeros(d,1);
    % take epsilon greedy action
    a = eps_greedy_cont(s, w, Q1, Q2, N, M, A, epsilon);
    % compute current vector of features
    x = state_action_features(s, a, Q1, Q2, N, M, A);
    % initialize isTerminal
    isTerminal = false;
    m = 0;
    while isTerminal == 0
        m = m+1;
        % disp(w);
        % apply action and measure sp and r
        [sp,r,isTerminal,coll] = kinematik_ev_obs_cont(s,a,tau,L1,L2,obs,s0,EE_d);
        % if coll == 1
        %     fprintf('obstacle hit \n')
        % end
        totalReturn(e) = totalReturn(e) + r;
        z = gamma*lambda*z + x;
        % plot a configuration
        % if mod(m,10000) == 0
        %     delete(h1)
        %     figure(1)
        %     hold on
        %     p = direct_kin_cont(s,L1,L2);
        %     h1 = robot(p);
        %     pause(2)
        % end
        if isTerminal
            % temporal difference error
            delta = r - w'*x;
            % Update weights based on the reward received
            w = w + alpha*delta*z;
        else
            % precommitment of next action
            ap = eps_greedy_cont(sp, w, Q1, Q2, N, M, A, epsilon);
            % compute next vector of features
            xp = state_action_features(sp, ap, Q1, Q2, N, M, A);
            % temporal difference error
            delta = r + w'*(gamma*xp - x);
            % apply update
            w = w + alpha*delta*z;

            % go to next state and action
            s = sp;
            a = ap;
            x = xp;
        end
    end
    % print total return
    disp(totalReturn(e))
    % if isTerminal == 1
    %     delete(h1)
    %     figure(1)
    %     hold on
    %     p = direct_kin_cont(s,L1,L2);
    %     h1 = robot(p);
    %     pause(2)
    % end
end

figure()
plot(totalReturn,'-b',DisplayName='r_e')
hold on
plot(movmean(totalReturn,10),'-r',DisplayName='\mu_r^{10}',LineWidth=2)
grid on
legend


%% Now plot the optimal policy
% intial state
states = [];
s0 = [-pi/2, 0];
s = s0;
states = [states s'];


figure(1)
grid on
hold on
p = direct_kin_cont(s,L1,L2);
h = robot(p);
pause(1);
isTerminal = 0;
while isTerminal ~= 1
    a = eps_greedy_cont(s, w, Q1, Q2, N, M, A, 0);
    [sp,r,isTerminal,coll] =  kinematik_ev_obs_cont(s,a,tau,L1,L2,obs,s0,EE_d);
    s = sp;
    states = [states s];
    p = direct_kin_cont(s,L1,L2);
    pause(1)
    delete(h)
    h = robot(p);
end

%% Plots
% subdivide state space
qq1 = linspace(Q1(1),Q1(end),90);
qq2 = linspace(Q2(1),Q2(end),100);
[qqq1, qqq2] = meshgrid(qq1, qq2);
QQ = zeros([size(qq1) A]);
PolicyOpt = zeros(size(qqq1));
for i1 = 1:size(qqq1,1)
    for i2 = 1:size(qqq1,2)
        % compute quality function for actions
        for a = 1:A
            QQ(i1,i2,a) = w'*state_action_features([qqq1(i1,i2),...
            qqq2(i1,i2)], a, Q1, Q2, N, M, A);
        end
        % compute optimal policy
        PolicyOpt(i1,i2) = find(QQ(i1,i2,:) == max(QQ(i1,i2,:)), 1,"first");
    end
end

% figure('Position',[10, 10, 1200, 400])
figure('Position',[10, 10, 1200, 1200])
subplot(1,3,1)
surf(qqq1,qqq2,QQ(:,:,1))
xlabel('$q_1$','Interpreter','latex')
ylabel('$q_2$','Interpreter','latex')
zlabel('$Q(s,1)$','Interpreter','latex')
subplot(1,3,2)
surf(qqq1,qqq2,QQ(:,:,A))
xlabel('$q_1$','Interpreter','latex')
ylabel('$q_2$','Interpreter','latex')
zlabel('$Q(s,A)$','Interpreter','latex')
subplot(1,3,3)
surf(qqq1,qqq2,PolicyOpt)
xlabel('$q_1$','Interpreter','latex')
ylabel('$q_2$','Interpreter','latex')
zlabel('Optimal policy','Interpreter','latex')

%% Find the optimal trajectory 
states(:,1) = [3/2*pi;0];

figure()

subplot(2,1,1)
plot(cos(states(1,:)),'-b','DisplayName','c_1')
hold on
grid on
plot(sin(states(1,:)),'-r','DisplayName','s_1')
legend

subplot(2,1,2)
plot(cos(states(2,:)),'-b','DisplayName','c_2')
hold on
grid on
plot(sin(states(2,:)),'-r','DisplayName','s_2')
legend

figure()
plot(states(1,:),'DisplayName','q_1')
hold on
grid on
plot(states(2,:),'DisplayName','q_2')
legend