clear all
close all
clc

% initialize parameters
numEpisodes = 10;
epsilon = 0.1;
alpha = 1e-2;
gamma = 1;
theta = 9e-1;

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
% initialize model and inverse model
modelSp = sparse(S,A);
modelR = sparse(S,A);
inverseModel = cell(S,1);
% initialize priority queue
PQueue = [];

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
        % update model
        modelSp(s, a) = sp;
        modelR(s, a) = r;
        % update inverse model by avoiding to keep duplicates
        inverseModel{sp} = unique([inverseModel{sp}; s, a],'rows');
        % update corresponding total return
        totalReturn(e) = totalReturn(e) + r;
        % evaluate priority
        P = abs(r + gamma*max(Q(sp,:)) - Q(s,a));
        % if priority is above treshold add to the queue
        if P > theta
            PQueue = updateQueue(PQueue, s, a, P);
        end
        % do updates for states in the Queue
        while ~isempty(PQueue)
            % disp the length of the queue
            % disp(length(PQueue))
            % get highest priority couple
            ix = find(PQueue(:,3) == max(PQueue(:,3)), 1, 'first');
            s_ix = PQueue(ix,1);
            a_ix = PQueue(ix,2);
            % use model to get next state and reward
            sp_ix = modelSp(s_ix, a_ix);
            r_ix = modelR(s_ix, a_ix);
            % eliminate the gathered state-action from the Queue
            PQueue(ix,:) = [];
            % use Q-learning as planning update
            Q(s_ix,a_ix) = Q(s_ix,a_ix) ...
                + alpha*(r_ix + gamma*max(Q(sp_ix,:)) - Q(s_ix,a_ix));
            % previous states and actions
            psa_ix = inverseModel{s_ix};
            % for all such states and actions
            for i = 1:size(psa_ix,1)
                % get state and action
                ps_ix = psa_ix(i,1);
                pa_ix = psa_ix(i,2);
                % get next state and next reward using model
                psp_ix = modelSp(ps_ix, pa_ix);
                pr_ix = modelR(ps_ix, pa_ix);
                % compute priority
                P_ix = abs(pr_ix+gamma*max(Q(psp_ix,:))-Q(ps_ix,pa_ix));
                % if the priority is above the treshold
                if P_ix > theta
                    % put it in the queue
                    PQueue = updateQueue(PQueue, ps_ix, pa_ix, P_ix);
                end
            end
        end
        % go to next state
        s = sp;
    end
end

figure()
plot(totalReturn)