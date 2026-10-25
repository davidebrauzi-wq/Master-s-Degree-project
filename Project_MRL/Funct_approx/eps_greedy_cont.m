function a = eps_greedy_cont(s, w, Q1, Q2, N, M, A, epsilon)

% with probobaility epsilon take a random action
if rand < epsilon
    a = randi(A);
else
    q = zeros(A,1);
    for i = 1:A
        q(i) = w'*state_action_features(s, i, Q1, Q2, N, M, A);
    end
    a = find(q == max(q),1,'first');
end