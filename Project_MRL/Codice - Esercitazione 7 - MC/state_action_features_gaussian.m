function x = state_action_features_gaussian(s, a, X, V, N, M, A, sigma)
% state action features

% features for states
xs = get_features_gaussian(s, X, V, N, M, sigma);

% construct identity matrix of suitable dimension
IA = eye(A);

% get extended features
x = kron(IA(:,a),xs);