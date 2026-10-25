function x = get_features_gaussian(s, X, V, N, M, sigma)
% implementation of Gaussian features
% N number of subdivision for each grid
% M number of grids

% number of cells
N_cell = (N+1)^2;

% vector of features
x = sparse(N_cell, M);

% subdivide axes in N cells
x_cell = linspace(X(1), X(end), N);
v_cell = linspace(V(1), V(end), N);

% dimensions of cells
w_x = x_cell(2)-x_cell(1);
w_v = v_cell(2)-v_cell(1);

% augment axes
x_cell = [x_cell(1)-w_x, x_cell];
v_cell = [v_cell(1)-w_v, v_cell];

% choice of displacement
dlm = [1, 3];
% normalize displacement
dlm = dlm/max(dlm);
% basic step for the offset
off_x = w_x*dlm(1)/M;
off_v = w_v*dlm(2)/M;

% identify points in the grid
for i = 1:M
    % positions over x axis
    x_pos = ((i-1)*off_x + x_cell - s(1))./(X(2)-X(1));
    % positions over v axis
    v_pos = ((i-1)*off_v + v_cell - s(2))./(V(2)-V(1));
    % combine the two vectors
    [xx_pos, vv_pos] = meshgrid(x_pos, v_pos);
    % compute numerator of features
    num = sqrt(xx_pos.^2 + vv_pos.^2);
    % determine features vectos
    x(:,i) = exp(-num(:)/sigma^2);
end

% reshape x as a vector
x = x(:);

