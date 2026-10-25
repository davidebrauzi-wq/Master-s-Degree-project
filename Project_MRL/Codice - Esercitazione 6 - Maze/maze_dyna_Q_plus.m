clear all
close all
clc

% initialize parameters
numEpisodes = 1e3;
numUpdates = 20;
alpha = 1e-2;
gamma = 1;
kappa = 1e-2;

% initialize gridworld environment
GW = createGridWorld(20,10);
GW.CurrentState = '[1,1]';
GW.TerminalStates = '[1,10]';

% define string for obstacles
obstacles = [];
for ii = 1:19
    obstacles = [obstacles; string(['[',num2str(ii),',3]'])];
end

% add obstacles to gridworld
GW.ObstacleStates = obstacles;
updateStateTranstionForObstacles(GW);

% define environment for gridworld
env = rlMDPEnv(GW);
% set the initial state
env.ResetFcn = @() 1;

% display environmnet
% plot(env)

% get numer of states and actions
S = length(env.Model.States);
A = length(env.Model.Actions);

% set reward to -1
env.Model.R = -1*ones(S, S, A);

% initialize quality function
Q = zeros(S,A);
tau = zeros(S,A);
% initialize model
modelSp = sparse(S,A);
modelR = sparse(S,A);

% returns for each episode
totalReturn = zeros(numEpisodes,1);

% cycle over episodes
for e = 1:numEpisodes
    % disp numer of episode
    disp(['Episode - ', num2str(e)])
    % reset environment
    s = reset(env);
    % initialize terminality
    isTerminal = 0;
    % proceed until termination
    while ~isTerminal
        % choose epsilon-greedy action
        a = epsilon_greedy(s, Q + kappa*sqrt(tau), A, 0);
        % apply action
        [sp, r, isTerminal] = step(env, a);
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
        for i = 1:numUpdates
            % get explored states
            pairs_index = find(modelSp ~= 0);
            % pick random explored state
            r_ix = pairs_index(randi(length(pairs_index)));
            % get corresponding state and action
            [s_ix, a_ix] = ind2sub([S, A], r_ix);
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
plot(totalReturn)