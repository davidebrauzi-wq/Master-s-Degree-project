clear all
close all
clc

% initialize parameters
numEpisodes = 1e4;
epsilon = 0.1;
alpha = 0.1;
beta = 1; %0.99999;
gamma = 1;
lambda = 0.5;

% load the environment
env = rlPredefinedEnv('WaterFallGridWorld-Stochastic');

% determine the dimension of state and action spaces
S = length(env.Model.States);
A = length(env.Model.Actions);

% to implement SARSA(lambda) initialize Q and E
Q = zeros(S,A);
E = zeros(S,A);

% total reward
total_reward = zeros(numEpisodes,1);

for e = 1:numEpisodes
    % diminish epsilon for GLIE
    epsilon = beta*epsilon;
    % reset environment
    s = reset(env);
    % reset eligibility traces
    E = zeros(S,A);
    isTerminal = 0;
    % proceed until termination
    while isTerminal ~= 1
        % take epsilon greedy action
        a = epsilon_greedy(s, Q, A, epsilon);
        % apply action and measure r and sp
        [sp, r, isTerminal] = step(env, a);
        total_reward(e) = total_reward(e) + r;
        % decrenebt the eligibility traces
        E = gamma*lambda*E;
        % increment eligibility trace of visited state action
        E(s,a) = E(s,a) + 1; % accumulating
        % apply ESARSA update
        % temporal difference error
        if isTerminal
            delta = r - Q(s,a);
        else
            delta = r ...
                + gamma*((1-epsilon)*max(Q(sp,:)) + epsilon/A*sum(Q(sp,:)))...
                - Q(s,a);
        end
        % update of Q
        Q = Q + alpha*delta*E;

        % pass to next state and next action
        s = sp;
        
        % % display eligibility traces
        % figure(1)
        % clf
        % imshow(E,'InitialMagnification','fit')
        % pause(.1)
        
        % if mod(e, 10) == 0
        %     clf
        %     plot(env)
        %     pause(1)
        % end
    end
end

figure()
plot(total_reward)

% gather optimal value function from Q
optimalValueFunction = max(Q, [], 2);