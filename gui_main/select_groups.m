function [groups,my_trajectories] = select_groups(my_trajectories, user)
%SELECT_GROUPS selects group or groups used to generate the results

% groups = -1: only one group is available, no need for input request
% groups = -2: error, wrong input

    groups_all = arrayfun( @(t) t.group, my_trajectories.items);
    groups = unique(groups_all);

    % Check the user's input
    numbers = []; %groups
    comma = 0; % ',' index
    merge = []; % ':' indexes
    for i = 1:length(user)
        tmp = str2double(user(i));
        if ~isnan(tmp)
            numbers = [numbers,tmp];
        else
            if isequal(user(i),',') && comma == 0
                comma = i;
            elseif isequal(user(i),':')    
                merge = [merge,i];
            else
                groups = -2;
            end
        end
    end
    if groups == -2
        return;
    end
    
    if length(numbers) == 1
        groups = numbers;
        return
    end
    
    % No group merging
    if isempty(merge)
        if ~isempty(find(groups_all == numbers(1))) && ~isempty(find(groups_all == numbers(2)))
            groups = [numbers(1),numbers(2)];
            return;
        else
            groups == -2
            return;            
        end
    end
    
    % Arrange selected groups
    group1 = find(merge < comma);
    tmp = str2double(user(merge(group1(end))+1));
    tmp = find(numbers==tmp);
    if length(tmp) > 1
        groups = -2;
        return;
    else
        group1 = numbers(1:tmp);
    end
    group2 = find(merge > comma);
    tmp = str2double(user(merge(group2(end))-1));
    tmp = find(numbers==tmp);
    if length(tmp) > 1
        groups = -2;
        return;
    else
        group2 = numbers(tmp:end);
    end
    % Merge selected groups
    g1 = str2num(strrep(num2str(group1), ' ', ''));
    g2 = str2num(strrep(num2str(group2), ' ', ''));
    for i = 1:length(my_trajectories.items)
        g = my_trajectories.items(i).group;
        tmp = find(group1==g);
        if isempty(tmp) %if this number is not in group1 it must be in group2
            tmp = find(group2==g);
            if isempty(tmp)
                return
            else
                my_trajectories.items(i).group = g2;
            end
        else
            my_trajectories.items(i).group = g1;
        end
    end
    groups = [g1,g2];
end

