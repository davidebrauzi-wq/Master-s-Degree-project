function a = epsgreedy(Q, s, epsilon)
% pick epsilon - greedy actions

% dimension of action spaces
A = size(Q,2);

if rand < epsilon
    % pick random action
    a = randi(A);
else
    % pick greedy wrt Q
    a = find(Q(s,:) == max(Q(s,:)), 1, "first");
end