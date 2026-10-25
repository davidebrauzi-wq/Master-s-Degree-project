% Direct kinematics function
function p = direct_kin_cont(s,L1,L2)
    q1 = s(1);
    q2 = s(2);
    x1 = L1 * cos(q1);
    y1 = L1 * sin(q1);
    x2 = x1 + L2 * cos(q1+q2);
    y2 = y1 + L2 *sin(q1+q2);
    p = [x1;y1;x2;y2];

    % % Display angles if you want
    % l1 = q1 - (floor(q1 / (2 * pi))* 2 * pi);
    % l2 = q2 - (floor(q2 / (2 * pi))* 2 * pi);
    % k1 = l1 / pi;
    % k2 = l2 / pi;
    % 
    % disp([strcat(rats(k1), ' pi'), strcat(rats(k2), ' pi')])

end