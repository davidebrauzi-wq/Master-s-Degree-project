function x = state_action_features(s, a, X, V, N, M, A)
% state action features

% features for states
xs = get_features(s, X, V, N, M);

% construct identity matrix of suitable dimension
IA = eye(A);

% get extended features
x = kron(IA(:,a),xs);