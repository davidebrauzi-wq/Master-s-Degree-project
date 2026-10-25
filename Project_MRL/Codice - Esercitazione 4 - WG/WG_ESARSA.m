clear all
close all
clc

% dimension of the gridworld
N1 = 10;
N2 = 7;

% discount factor
gamma = 1;
% define number of episodes
numEpisodes = 1e5;
% exploration index
epsilon = 0.1;
% update index
alpha = 0.01;

% dimension of the state space
S = N1*N2;
% dimension of action space
A = 4;

% initilize the estimate of Q function
Q = zeros(S,A); % opimistic initialization

% totalReturn
totalReturn = zeros(numEpisodes,1);

for e = 1:numEpisodes
    % track evolution
    visitedStates = [];
    % pick initial state
    s = 1; %randi(S);
    % update visited states
    visitedStates = [visitedStates, s];
    % check if s is terminal
    [row, col] = ind2sub([N1 N2], s);
    if row == 8 && col == 4
        continue;
    else
        % proceed up to termination
        while s ~= -1
            % pick epsilon greedy action wrt Q
            a = epsgreedy(Q, s, epsilon);
            % pick action a and observer r and sp
            [sp, r] = windy_gridworld(s, a, N1, N2);
            % update total return
            totalReturn(e) = totalReturn(e) + r;
            % if next state is terminal do not bootstrap
            if sp == -1
                Q(s,a) = Q(s,a) + alpha*(r  - Q(s,a));
            else
                % apply Q learning update
                Q(s,a) = Q(s,a) + alpha*(r + ...
                    gamma*((1-epsilon)*max(Q(sp,:)) ...
                    + epsilon/A*sum(Q(sp,:))) - Q(s,a));
            end
            % go to next state
            s = sp;
            visitedStates = [visitedStates, s];
        end
    end
    % check positions of visited states
    [rows, cols] = ind2sub([N1 N2], visitedStates(1:end-1));
    if mod(e,1e9) == 0 % plot each 100 episodes
        figure(1)
        plot([rows, 8],[cols, 4])
        xlim([1, N1])
        ylim([1, N2])
        grid on
        pause(0.5)
    end
end

figure(2)
plot(totalReturn)

save ESARSA.mat totalReturn Q