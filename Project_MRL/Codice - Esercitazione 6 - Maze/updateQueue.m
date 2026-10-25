function PQueue = updateQueue(PQueue, s, a, P)

% if the queue is empty, just add
if isempty(PQueue)
    PQueue = [PQueue; s, a, P];
else
    % check if state and actions is already in the queue
    ind = find(PQueue(:,1) == s & PQueue(:,2) == a, 1, 'first');
    if isempty(ind)
        % if it is not in the queue, add them
        PQueue = [PQueue; s, a, P];
    else
        % if it is in the queue, update the priority if the new one is higher
        PQueue(ind, 3) = max(PQueue(ind, 3), P);
    end
end

if s == 0
    error
end