close all
clear all
clc

% subdivisions of 2 pi
N = 4;

% robot parameters
L1 = 3;
L2 = 5;

% unit for angles
tau = 2 * pi / N;

idx1 = 3;
idx2 = N;
s = sub2ind([N,N],idx1,idx2);

% compute direct kinematics
p = direct_kin(s,L1,L2,N)
%%
figure()
h = robot(p);
hold on
grid on
axis equal
xlim([-10 10]);
ylim([-10 10]);

%% Simulate kinematics
% idxi = qi / tau
% move always my power of 2 to have pi/2, pi, 3/2 pi, 2 pi ..
idx1 = 3;
idx2 = N;
s = sub2ind([N,N],idx1,idx2);
EE_d = [L2;L1];
K = 10;
figure(2)
xlim([-8 8])
ylim([-8 8])
grid on
hold on
p = direct_kin(s,L1,L2,N);
h = robot(p);
for k = 1:K
    a = randi(9);
    [sp,r,isTerminal] = kinematik_ev(s,a,N,L1,L2,EE_d);
    s = sp;
    p = direct_kin(s,L1,L2,N);
    pause(5)
    if k <= K
        delete(h)
    end
    h = robot(p);
end

%% Actual algorithm
% First thing first: without obstacles
% number of divisions of 2pi
N = 32;

% we have to angular positions
S = N^2; 

% action space : [clockwise, stay, counterclockwise]
A = 9; 

% initialize parameters
numEpisodes = 2e4;
epsilon = 0.1;
alpha = 0.1;
beta = 0.99999;
gamma = 1;
lambda = 0.5;

% to implement SARSA(lambda) initialize Q and E
Q = zeros(S,A);
E = zeros(S,A);

% total reward
total_reward = zeros(numEpisodes,1);

% Establish a desider position of the EE
q1 = pi/4;
q2 = pi/2;
idx1 = q1 / (2*pi/N); idx2 = q2 / (2*pi/N);
s = sub2ind([N,N],idx1,idx2);
f = direct_kin(s,L1,L2,N);
EE_d = f(3:4);

% set initial condition
idx01 = (3/2 * pi) / (2*pi/N);
idx02 = N;

% generate obstacles


for e = 1:numEpisodes
    disp(e)
    % diminish epsilon for GLIE
    epsilon = beta*epsilon;
    % reset robot pose (all down)
    s = sub2ind([N,N],idx01,idx02);
    % reset eligibility traces
    E = zeros(S,A);
    % take epsilon greedy action
    a = epsilon_greedy(s, Q, A, epsilon);
    isTerminal = 0;
    % proceed until termination
    while isTerminal ~= 1
        % apply action and measure r and sp
        [sp, r, isTerminal] = kinematik_ev(s,a,N,L1,L2,EE_d);
        total_reward(e) = total_reward(e) + r;
        % decrement the eligibility traces
        E = gamma*lambda*E;
        % increment eligibility trace of visited state action
        % E(s,a) = E(s,a) + 1; % accumulating
        % E(s,a) = 1; % replacing
        E(s,a) = (1-alpha)*E(s,a) + 1; % dutch
        % precommitment of actions
        ap = epsilon_greedy(sp, Q, A, epsilon);
        % apply SARSA update
        % temporal difference error
        if isTerminal
            delta = r - Q(s,a);
        else
            delta = r + gamma*Q(sp,ap) - Q(s,a);
        end
        % update of Q
        Q = Q + alpha*delta*E;

        % pass to next state and next action
        s = sp;
        a = ap;
        
        % % display eligibility traces
        % figure(1)
        % clf
        % imshow(E,'InitialMagnification','fit')
        % pause(.1)
    end
end

figure()
plot(total_reward)

%% Place obstacles in the map
obs(1).center = [1, 1];   % [x, y]
obs(1).radius = 4;

obs(2).center = [2, 4];
obs(2).radius = 3;

k = zeros(length(obs),1);

% Visualizza
figure(1); hold on;
theta = linspace(0, 2*pi, 100);
for i = 1:length(obs)
    x = obs(i).center(1) + obs(i).radius * cos(theta);
    y = obs(i).center(2) + obs(i).radius * sin(theta);
    k(i) = fill(x, y, 'r', 'FaceAlpha', 0.5);
end
clear x y 
%% Code for obstacles collision (IT WORKS)
function coll = obstacles_collision(p,obs)
    % given coordinates of joints and obstacles compute if there is
    % collision
    % We must solve an equation of intersection between
    % circle and segment
    coll = 0; % default value
    syms lambda1 lambda2
    x1 = p(1); y1 = p(2); x2 = p(3); y2 = p(4);
    for i = 1:length(obs)
        cx = obs(i).center(1);
        cy = obs(i).center(2);
        r = obs(i).radius;
        % solve equation
        sol = solve([((lambda1*x1+(1-lambda1)*x2)-cx)^2+((lambda2*y1+(1-lambda2)*y2)-cy)^2 == r^2, lambda1 + lambda2 == 1], [lambda1, lambda2]);
        % class(sol.lambda1) 
        % check if solution found
        for j = 1:length(sol.lambda1)
            if (double(sol.lambda1(j)) >= 0) && (double(sol.lambda2(j)) >= 0)
                % solution found with positive weights
                coll = 1;
                return
            end
        end
    end
    for i = 1:length(sol.lambda1)
        if (sol.lambda1(i) >= 0) && (sol.lambda2(i) >= 0)
            fprintf('Solution found \n')
            fprintf(strcat(string(sol.lambda1(i)),' ; ',string(sol.lambda2(i)),'\n'))
        end
    end
end

syms lambda1 lambda2 x y
x1 = 2; y1 = 4;
x2 = 3; y2 = 6;
cx = 1; cy = 1;
r = 4;

p = [x1;y1;x2;y2];

obstacles_collision(p,obs)
% sol = solve([((lambda1*x1+(1-lambda1)*x2)-cx)^2+((lambda2*y1+(1-lambda2)*y2)-cy)^2 == r^2, lambda1 + lambda2 == 1], [lambda1, lambda2])
% 
% for i = 1:length(sol.lambda1)
%     if (sol.lambda1(i) >= 0) && (sol.lambda2(i) >= 0)
%         fprintf('Solution found \n')
%         fprintf(strcat(string(sol.lambda1(i)),' ; ',string(sol.lambda2(i)),'\n'))
%     end
% end
% 
% p = zeros(2,1);
% Cx = cx + r*cos(theta);
% Cy = cy + r*sin(theta);
% figure(2)
% axis equal
% axis square
% grid on
% hold on
% p(1) = plot([x1 x2],[y1 y2],'k','LineWidth',1.5);
% p(2) = fill(Cx, Cy, 'r', 'FaceAlpha', 0.5);

%% Now plot the optimal policy
% Greedy policy respect to the Q matrix found in the algorithm
policy = zeros(S,1);
for s = 1:S
    policy(s) = find(Q(s,:) == max(Q(s,:)), 1, "first");
end

% intial state
idx1 = (3 / 2 * pi) / (2*pi/N);
idx2 = N;
isTerminal = 0; % reinitialize
s = sub2ind([N,N],idx1,idx2);

figure(2)
axis equal
xlim([-10 10])
ylim([-10 10])
grid on
hold on
p = direct_kin(s,L1,L2,N);
h = robot(p);
while isTerminal ~= 1
    a = policy(s);
    [sp,r,isTerminal] = kinematik_ev(s,a,N,L1,L2,EE_d);
    s = sp;
    p = direct_kin(s,L1,L2,N);
    pause(1)
    if k <= K
        delete(h)
    end
    h = robot(p);
end

%% We need to map joint coordinates in an array
a = (2*pi / N) * 5;
l = a - (floor(a / (2 * pi))* 2 * pi);
idx1 = l / (2*pi / N)
k = l / pi;

disp(strcat(rats(k), ' pi'))

% Now we can make the connection
s = sub2ind([N N], idx1, 3)
