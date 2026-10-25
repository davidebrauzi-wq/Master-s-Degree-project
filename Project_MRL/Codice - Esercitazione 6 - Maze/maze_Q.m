clear all
close all
clc

% initialize parameters
numEpisodes = 1e3;
epsilon = 0.1;
alpha = 1e-2;
gamma = 1;

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
        a = epsilon_greedy(s, Q, A, epsilon);
        % apply action
        [sp, r, isTerminal] = step(env, a);
        % update corresponding total return
        totalReturn(e) = totalReturn(e) + r;
        % apply directly Q learning
        Q(s,a) = Q(s,a) + alpha*(r + gamma*max(Q(sp,:)) - Q(s,a));
        % go to next state
        s = sp;
    end
end

figure()
plot(totalReturn)