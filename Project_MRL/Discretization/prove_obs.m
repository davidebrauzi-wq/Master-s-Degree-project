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
% number of divisions of 2pi
N = 32;
rng(1)

% we have to angular positions
S = N^2; 

% action space : [clockwise, stay, counterclockwise]
A = 9; 

% initialize parameters
numEpisodes = 5e3;
epsilon = 0.4;
alpha = 0.1;
beta = 0.99999;
gamma = 1;
lambda = 0.1;

% to implement SARSA(lambda) initialize Q and E
Q = zeros(S,A);
E = zeros(S,A);

% total reward
total_reward = zeros(numEpisodes,1);

% Establish a desider position of the EE
q1 = 3/4 * pi;
q2 = pi / 2;
idx1 = q1 / (2*pi/N); idx2 = q2 / (2*pi/N);
s = sub2ind([N,N],idx1,idx2);
f = direct_kin(s,L1,L2,N);
EE_d = f(3:4);

% set initial condition
% idx01 = (3/2 * pi) / (2*pi/N);
idx01 = 3/2*pi / (2*pi/N);
idx02 = N;
s0 = sub2ind([N,N],idx01,idx02);

%% check if it starts and ends not on obstacles
p1 = direct_kin(s0,L1,L2,N);
figure(1)
hold on
h1 = robot(p1);
h2 = robot(f);
grid on
axis equal
% xlim([-10 10]);
% ylim([-10 10]);

obstacles_collision(p1,obs)
obstacles_collision(f,obs)

%% Algorithm run SARSA(lambda)
delete(h1)
delete(h2)
% profile on is to analyze calls
% profile on 
for e = 1:numEpisodes
    disp(e)
    % diminish epsilon for GLIE
    epsilon = max(0.05,beta*epsilon);
    % reset robot pose (all down)
    s = s0;
    % reset eligibility traces
    E = zeros(S,A);
    % take epsilon greedy action
    a = epsilon_greedy(s, Q, A, epsilon);
    isTerminal = 0;
    % proceed until termination
    while isTerminal ~= 1
        % disp(Q(s0,:))
        % apply action and measure r and sp
        [sp, r, isTerminal,coll] = kinematik_ev_obs(s,a,N,L1,L2,obs,s0,EE_d);
        if coll == 1
            fprintf('obstacle hit \n')
        end
        %sp
        total_reward(e) = total_reward(e) + r;
        % decrement the eligibility traces
        E = gamma*lambda*E;
        % increment eligibility trace of visited state action
        % E(s,a) = E(s,a) + 1; % accumulating
        % E(s,a) = 1; % replacing
        E(s,a) = (1-alpha)*E(s,a) + 1; % dutch
        % precommitment of actions
        ap = epsilon_greedy(sp, Q, A, epsilon);
        % apply SARSA update
        % temporal difference error
        if isTerminal || coll
            delta = r - Q(s,a);
        else
            delta = r + gamma*Q(sp,ap) - Q(s,a);
        end
        % update of Q
        Q = Q + alpha*delta*E;

        % pass to next state and next action
        s = sp;
        a = ap;
        
        % % display eligibility traces
        % figure(1)
        % clf
        % imshow(E,'InitialMagnification','fit')
        % pause(.1)
    end
end
% profile viewe displays the analysis
% profile viewer
figure()
plot(total_reward,'-b',DisplayName='r_e')
hold on
plot(movmean(total_reward,10),'-r',DisplayName='\mu_r^{10}',LineWidth=2)
grid on
legend
title('SARSA(\lambda)',Interpreter='latex')

tR_Sl = total_reward;
Q_Sl = Q;

% compute optimal policy
policy = zeros(S,1);

for s = 1:S
    policy(s) = find(Q(s,:) == max(Q(s,:)), 1, "first");
end

pi_Sl = policy;

save Sl.mat tR_Sl Q_Sl pi_Sl


%% Algorithm run Dyna-Q+
% initialize parameters
numEpisodes = 5e3;
epsilon = 0.4;
epsilon_min = 0.05;
beta = 0.99999;
gamma = 1;

numUpdates = 20; % for inner loop
alpha = 1e-2;
kappa = 1e-2;

% initialize quality function and pref param
Q = zeros(S,A);
tau = zeros(S,A);
% initialize model to do planning 
% remember this is a method that mixes planning
% and learning
modelSp = sparse(S,A);
modelR = sparse(S,A);

% returns for each episode
totalReturn = zeros(numEpisodes,1);

% cancel figure
delete(h2);

% cycle over episodes
for e = 1:numEpisodes
    % disp numer of episode
    disp(['Episode - ', num2str(e)])
    % reset environment
    s = s0;
    % initialize terminality
    isTerminal = 0;
    % proceed until termination
    while ~isTerminal
        epsilon = max(epsilon_min,epsilon*beta);
        % choose epsilon-greedy action
        a = epsilon_greedy(s, Q + kappa*sqrt(tau), A, epsilon);
        % apply action
        [sp, r, isTerminal,coll] = kinematik_ev_obs(s,a,N,L1,L2,obs,s0,EE_d);
        % update model
        modelSp(s, a) = sp;
        modelR(s, a) = r;
        % update tau
        tau = tau + 1;
        tau(s,a) = 0;
        % update corresponding total return
        totalReturn(e) = totalReturn(e) + r;
        % apply directly Q learning
        Q(s,a) = Q(s,a) + alpha*(r + gamma*max(Q(sp,:)) - Q(s,a));
        % go to next state
        s = sp;
        % before proceeding to next state do some updates
        % to exploit information learned from experience
        for i = 1:numUpdates
            % get explored states
            pairs_index = find(modelSp ~= 0);
            % pick random explored state
            ix = pairs_index(randi(length(pairs_index)));
            % get corresponding state and action
            [s_ix, a_ix] = ind2sub([S, A], ix);
            % use model to get next state and reward
            sp_ix = modelSp(s_ix, a_ix);
            r_ix = modelR(s_ix, a_ix);
            % use Q-learning as planning update
            Q(s_ix,a_ix) = Q(s_ix,a_ix) ...
                + alpha*(r_ix + gamma*max(Q(sp_ix,:)) - Q(s_ix,a_ix));
        end
        % figure(1)
        % clf
        % imshow(tau,'InitialMagnification','fit')
        % pause(0.01)
    end
end

figure()
plot(totalReturn,'-b',DisplayName='r_e')
hold on
plot(movmean(totalReturn,10),'-r',DisplayName='\mu_r^{10}',LineWidth=2)
grid on
legend
title('Dyna-Q+',Interpreter='latex')

tR_Qp = totalReturn;
Q_Qp = Q;

% compute optimal policy
policy = zeros(S,1);

for s = 1:S
    policy(s) = find(Q(s,:) == max(Q(s,:)), 1, "first");
end

pi_Qp = policy;

save Qp.mat tR_Qp Q_Qp pi_Qp

%% Algorithm run Double-Q
% initialize parameters
numEpisodes = 5e3;
epsilon = 0.4;
epsilon_min = 0.05;
beta = 0.99999;
gamma = 1;
alpha = 1e-2;

% initialize quality functions 
Q1 = zeros(S,A);
Q2 = zeros(S,A);

% returns for each episode
totalReturn = zeros(numEpisodes,1);

% cancel figure
delete(h2);

% cycle over episodes
for e = 1:numEpisodes
    % disp numer of episode
    disp(['Episode - ', num2str(e)])
    % reset environment
    s = s0;
    % proceed up to termination
    isTerminal = 0;
    epsilon = max(epsilon_min,epsilon*beta);
    while ~isTerminal
        % choose epsilon-greedy action
        a = epsilon_greedy(s, Q1 + Q2, A, epsilon);
        % see next state and reward
        [sp, r, isTerminal,coll] = kinematik_ev_obs(s,a,N,L1,L2,obs,s0,EE_d);
        % update total return
        totalReturn(e) = totalReturn(e) + r;
        % update randomly one or the other estimate of Q
        if rand < 0.5
            % update Q1
            if isTerminal % force to have 0 in Q2
                Q1(s,a) = Q1(s,a) + alpha*(r - Q1(s,a));
            else
                % estimate optimal action in next state according to Q1
                apstar = find(Q1(sp,:) == max(Q1(sp,:)), 1, "first");
                % value of next optimal action according to Q2
                apQ = Q2(sp, apstar);
                % update Q1
                Q1(s,a) = Q1(s,a) + alpha*(r + gamma*apQ - Q1(s,a));
            end
        else
            % update Q2
            if isTerminal % force 0 in Q1
                Q2(s,a) = Q2(s,a) + alpha*(r - Q2(s,a));
            else
                % estimate optimal action on the basis Q2
                apstar = find(Q2(sp,:) == max(Q2(sp,:)), 1, "first");
                % estimate value function on the basis of Q1
                apQ = Q1(sp, apstar);
                % update Q2
                Q2(s,a) = Q2(s,a) + alpha*(r + gamma*apQ - Q2(s,a));
            end
        end
            % go to next state
            s = sp;
    end
end

figure()
plot(totalReturn,'-b',DisplayName='r_e')
hold on
plot(movmean(totalReturn,10),'-r',DisplayName='\mu_r^{10}',LineWidth=2)
grid on
legend
title('Double Q',Interpreter='latex')

tR_DQ = totalReturn;
Q1_DQ = Q1;
Q2_DQ = Q2;

% compute optimal policy
policy = zeros(S,1);
Q = Q1+Q2;
for s = 1:S
    policy(s) = find(Q(s,:) == max(Q(s,:)), 1, "first");
end

pi_DQ = policy;

save DQ.mat tR_DQ Q1_DQ Q2_DQ pi_DQ
%% Now plot the optimal policy
% Greedy policy respect to the Q matrix found in the algorithm
policy = zeros(S,1);
for s = 1:S
    policy(s) = find(Q(s,:) == max(Q(s,:)), 1, "first");
end

% intial state
idx1 = 3*pi/2 / (2*pi/N);
idx2 = N;
isTerminal = 0; % reinitialize
s = sub2ind([N,N],idx1,idx2);

figure(1)
grid on
hold on
p = direct_kin(s,L1,L2,N);
h = robot(p);
while isTerminal ~= 1
    a = policy(s);
    [sp,r,isTerminal] = kinematik_ev(s,a,N,L1,L2,EE_d);
    s = sp;
    p = direct_kin(s,L1,L2,N);
    pause(1)
    delete(h)
    h = robot(p);
end