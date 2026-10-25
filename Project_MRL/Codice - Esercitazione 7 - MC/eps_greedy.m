function a = eps_greedy(s, w, X, V, N, M, A, epsilon)

% with probobaility epsilon take a random action
if rand < epsilon
    a = randi(A);
else
    q1 = w'*state_action_features(s, 1, X, V, N, M, A);
    q2 = w'*state_action_features(s, 2, X, V, N, M, A);
    a = (q2 > q1) + 1;
end