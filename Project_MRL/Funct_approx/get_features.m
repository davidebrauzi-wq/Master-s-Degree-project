function x = get_features(s, X, V, N, M)
% implementation of tile coding
% N number of ticks for each grid
% M number of grids

% number of cells (we must augment it)
N_cell = (N+1)^2;

% vector of features
x = sparse(N_cell, M);

% subdivide axes in N cells 
% V and X are the linear intervals for the tile coding
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

% identify position in each grid
for i = 1:M
    % identify cell for each axis
    i_x = find(s(1) <= (i-1)*off_x + x_cell, 1, "first");
    i_y = find(s(2) <= (i-1)*off_v + v_cell, 1, "first");
    % identify the actual cell
    i_cell = sub2ind([N+1, N+1], i_x, i_y);
    % update feature vector
    x(i_cell, i) = 1;
end

% reshape x as a vector
x = x(:);

