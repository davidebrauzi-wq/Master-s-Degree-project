% FIRST FUNCTION REALLY SLOW BECAUSE OF SOLVE
% function coll = obstacles_collision(p,obs)
%     % given coordinates of joints and obstacles compute if there is
%     % collision
%     % We must solve an equation of intersection between
%     % circle and segment
%     coll = 0; % default value
%     syms lambda1 lambda2
%     x1 = p(1); y1 = p(2); x2 = p(3); y2 = p(4);
%     for i = 1:length(obs)
%         cx = obs(i).center(1);
%         cy = obs(i).center(2);
%         r = obs(i).radius;
%         % solve equation
%         sol = solve([((lambda1*x1+(1-lambda1)*x2)-cx)^2+((lambda2*y1+(1-lambda2)*y2)-cy)^2 == r^2, lambda1 + lambda2 == 1], [lambda1, lambda2]);
%         % class(sol.lambda1) 
%         % check if solution found
%         for j = 1:length(sol.lambda1)
%             if (double(sol.lambda1(j)) >= 0 && isreal(double(sol.lambda1(j)))) ...
%                 && (double(sol.lambda2(j)) >= 0 && isreal(double(sol.lambda2(j))))
%                 %double(sol.lambda1(j))
%                 %double(sol.lambda2(j))
%                 % solution found with positive weights
%                 coll = 1;
%                 return
%             end
%         end
%     end
% end

% FASTER FUNCTION
function coll = obstacles_collision(p,obs)
    coll = 0;
    p0 = [0 0];
    p1 = [p(1) p(2)];
    p2 = [p(3) p(4)];
    for i = 1:length(obs)
        % distance (link 1 - c1)
        d1 = dist_point_segment(obs(i).center, p0, p1);
        % distance (link 1 - c2)
        d2 = dist_point_segment(obs(i).center, p1, p2);

        if d1 < obs(i).radius || d2 < obs(i).radius
            coll = 1;
            return   % exit if collision
        end
    end
end

function d = dist_point_segment(p, a, b)
% distance from p (point) to segment of extrem (a,b)
    ab = b - a;
    ap = p - a;
    t  = dot(ap, ab) / dot(ab, ab);
    % dot is more robust to dimensions of arrays
    t  = max(0, min(1, t)); % saturate for segment 
    closest = a + t*ab;
    d = norm(p - closest);
end