% function for kinematic model with obstacles
function [sp,r,isTerminal,coll] = kinematik_ev_obs(s,a,N,L1,L2,obs,s0,EE_d)
    % EE_d is the desider position of the end effector
    [idx1, idx2] = ind2sub([N,N],s);

    % angular tik
    [t1,t2] = ind2sub([3,3],a);
    t1 = t1 - 2;
    t2 = t2 - 2;


    % angular shift
    idx1p = idx1 + t1;
    idx2p = idx2 + t2;

    % saturate
    if idx1p > N 
        idx1p = 1;
    elseif idx1p < 1
        idx1p = N;
    end

    if idx2p > N 
        idx2p = 1;
    elseif idx2p < 1
        idx2p = N;
    end

    sp = sub2ind([N N], idx1p, idx2p);
    r = -1;

    p = direct_kin(sp,L1,L2,N);

    if obstacles_collision(p,obs) == 1
        sp = s0; % reset state
        r = -N*10;
        coll = 1;
        isTerminal = 0;
    elseif p(3:4) == EE_d
        isTerminal = 1;
        coll = 0;
    else
        isTerminal = 0;
        coll = 0;
    end
end