function [sp, r] = windy_gridworld(s, a, N1, N2)
% environment that determines next state and reward on the basis of the
% current state and current action

% map the state in the position
[row, col] = ind2sub([N1 N2], s);

% model the wind
wind = [0, 0, 0, 1, 1, 1, 2, 2, 1, 0];

% actual wind
awind = randi(wind(row)+1)-1;

% modify position on the basis of wind
col = col + awind;

% determine next state on the basis of action
switch a
    case 1 % down
        row = row - 1;
    case 2 % right
        col = col + 1;
    case 3 % up
        row = row + 1;
    case 4 % left
        col = col - 1;
end

% saturate position to remain in the gridwworld
row = min(max(row, 1), N1);
col = min(max(col, 1), N2);

% determine next state
sp = sub2ind([N1, N2], row, col);
r = -1;

% if you reached the target, the next state is terminal
if row == 8 && col == 4
    sp = -1;
end