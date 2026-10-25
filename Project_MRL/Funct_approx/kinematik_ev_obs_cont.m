% function for kinematic model with obstacles
function [sp,r,isTerminal,coll] = kinematik_ev_obs_cont(s,a,tau,L1,L2,obs,s0,EE_d)
    % EE_d is the desider position of the end effector
   
    % angular tik
    [t1,t2] = ind2sub([3,3],a);
    t1 = t1 - 2;
    t2 = t2 - 2;

    % map angular positions
    q1 = s(1);
    q2 = s(2);

    % next angular positions (we are in the kinematik wolrd)
    q1p = q1 + t1 * tau;
    q2p = q2 + t2 * tau;

    % saturate
    if q1p > 2 *pi 
        q1p = q1p - 2*pi;
    elseif q1p < 0 
        q1p = 2*pi - abs(q1p);
    end

    if q2p > 2 *pi 
        q2p = q2p - 2*pi;
    elseif q2p < 0 
        q2p = 2*pi - abs(q2p);
    end

    sp = [q1p;q2p];
    r = -1;

    p = direct_kin_cont(sp,L1,L2);

    if obstacles_collision(p,obs) == 1
        sp = s0; % reset state
        r = -20;
        coll = 1;
        isTerminal = 0;
    elseif norm(p(3:4) - EE_d) <= 1e-2
        isTerminal = 1;
        coll = 0;
    else
        isTerminal = 0;
        coll = 0;
    end
end