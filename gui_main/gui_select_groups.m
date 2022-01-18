function [groups,my_trajectories] = gui_select_groups(my_trajectories)
%SELECT_GROUPS allows the user to select which one or two groups he wants
%in order to generate the results

% groups = -1: only one group is available, no need for input request
% groups = -2: error, wrong input

    % find available animal groups
    groups_all = arrayfun( @(t) t.group, my_trajectories.items);
    groups = unique(groups_all);
    % if we have more than one groups ask which one or two groups
    if length(groups) > 1
        prompt={'Choose one or two animal groups (example: 2 or 1,3. In case groups need to be merged type 1:2,3:4 to merge the equivalent groups)'};
        name = 'Choose groups';
        defaultans = {''};
        options.Interpreter = 'tex';
        user = inputdlg(prompt,name,[1 30],defaultans,options);
        if isempty(user)
            groups = -2;
            return
        end
    else
        groups = -1;
        return
    end    
    
    user = user{1};
    [groups,my_trajectories] = select_groups(my_trajectories,user)
end
