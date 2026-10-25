function [sp, r, isTerminal] = mc_dynamics(s, a, X, V)
% environment for learning
% implementation of the dynamics

% map actions in accelerations
switch a
    case 1
        acc = -1;
    case 2
        acc = 1;
end

% position
x = s(1);
% velocity
v = s(2);

% next position
xp = min(max(x + v, X(1)),X(2));
% next velocity
if xp == X(1)
    v = 0;
end
vp = min(max(v + 0.001*acc - 0.0025*cos(3*x),V(1)),V(2));

% determine next state
sp = [xp; vp];

% check if we reach the targer
if xp == X(2)
    isTerminal = true;
else
    isTerminal = false;
end

% reward 
r = -1;
