function a = epsilon_greedy(s, Q, A, epsilon)
% take epsilon greedy actions

if rand < epsilon
    % take random action
    a = randi(A);
else
    % take greedy action
    a = find(Q(s,:) == max(Q(s,:)), 1, "first");
end