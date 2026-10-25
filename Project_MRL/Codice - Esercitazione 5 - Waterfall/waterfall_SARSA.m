clear all
close all
clc

% initialize parameters
numEpisodes = 1e4;
epsilon = 0.1;
alpha = 0.1;
gamma = 1;

% load the environment
env = rlPredefinedEnv('WaterFallGridWorld-Stochastic');

% determine the dimension of state and action spaces
S = length(env.Model.States);
A = length(env.Model.Actions);

% to implement SARSA initialize Q
Q = zeros(S,A);

% total reward
total_reward = zeros(numEpisodes,1);

for e = 1:numEpisodes
    % reset environment
    s = reset(env);
    % take epsilon greedy action
    a = epsilon_greedy(s, Q, A, epsilon);
    isTerminal = 0;
    % proceed until termination
    while isTerminal ~= 1
        % apply action and measure r and sp
        [sp, r, isTerminal] = step(env, a);
        total_reward(e) = total_reward(e) + r;
        % precommitment of actions
        ap = epsilon_greedy(sp, Q, A, epsilon);
        % apply SARSA update
        % temporal difference error
        if isTerminal
            delta = r - Q(s,a);
        else
            delta = r + gamma*Q(sp,ap) - Q(s,a);
        end
        % update of Q
        Q(s,a) = Q(s,a) + alpha*delta;

        % pass to next state and next action
        s = sp;
        a = ap;
        % if mod(e, 10) == 0
        %     clf
        %     plot(env)
        %     pause(1)
        % end
    end
end

figure()
plot(total_reward)