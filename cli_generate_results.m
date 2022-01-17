function error_all = cli_generate_results(project_path,groups,sfile,lfile,class,varargin)

    error_all = 1;

    METRICS = 0;
    STRATEGIES = 0;
    PROBABILITIES = 0;
    TRANSITIONS = 0;
    INTERIM_FIGURES = 1;
    TRAJ_TO_SEGMENT = 0;
    STR_DISTR = 3;
    TRANS_DISTR = 3;
    SIGMA = 0;
    INTERVAL = 0; 
    R_SIGMA = 0;
    R_INTERVAL = 0;
    DISTRIBUTION = 3;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'METRICS')
            METRICS = varargin{i+1};
        elseif isequal(varargin{i},'STRATEGIES')
            STRATEGIES = varargin{i+1};
        elseif isequal(varargin{i},'PROBABILITIES')
            PROBABILITIES = varargin{i+1};
        elseif isequal(varargin{i},'TRANSITIONS')
            TRANSITIONS = varargin{i+1};
        elseif isequal(varargin{i},'INTERIM_FIGUES')
            INTERIM_FIGURES = varargin{i+1};
        elseif isequal(varargin{i},'INTERIM_FIGURES')
            INTERIM_FIGURES = varargin{i+1};
        elseif isequal(varargin{i},'STR_DISTR')
            STR_DISTR = varargin{i+1};
        elseif isequal(varargin{i},'TRANS_DISTR')
            TRANS_DISTR = varargin{i+1};
        elseif isequal(varargin{i},'SIGMA')
            SIGMA = varargin{i+1};
        elseif isequal(varargin{i},'INTERVAL')
            INTERVAL = varargin{i+1};
        elseif isequal(varargin{i},'R_SIGMA')
            R_SIGMA = varargin{i+1};
        elseif isequal(varargin{i},'R_INTERVAL')
            R_INTERVAL = varargin{i+1};
        elseif isequal(varargin{i},'TRAJ_TO_SEGMENT')
            TRAJ_TO_SEGMENT = varargin{i+1};
        elseif isequal(varargin{i},'DISTRIBUTION')
            DISTRIBUTION = varargin{i+1};
        end
    end


    if isempty(project_path)
        error_messages(8);
        return
    end
    % Load the full trajectories
    try
        load(fullfile(project_path,'settings','my_trajectories.mat'));
        load(fullfile(project_path,'settings','my_trajectories_features.mat'));
        load(fullfile(project_path,'settings','new_properties.mat'));
    catch
        error_messages(1);
        return
    end

    % Select groups
    [groups,my_trajectories] = select_groups(my_trajectories,groups);
    try
        if groups == -2
            return
        elseif groups == -1
            groups_all = arrayfun( @(t) t.group, my_trajectories.items);
            groups = unique(groups_all);
            if length(groups) ~= 1
                return
            end
        end
    catch
    end
    % Construct the trajectories_map and equalize the groups
    [exit, animals_trajectories_map, animals_ids] = trajectories_map(my_trajectories,my_trajectories_features,groups,'Friedman');
    if exit
        return
    end
    
    if METRICS
        str = num2str(groups);
        str = regexprep(str,'[^\w'']',''); %remove gaps
        str = strcat('group',str);   
        output_dir = fullfile(project_path,'results','metrics',str);
        if ~exist(output_dir,'dir')
            mkdir(output_dir);
        end
        try
            results_latency_speed_length(new_properties,my_trajectories,my_trajectories_features,animals_trajectories_map,1,output_dir);
            error_all = 0;
        catch
            error_messages(22);
        end
        return
    end
    
    % Check selected segmentation 
    segmentation_path = fullfile(project_path,'segmentation',sfile);
    try
        load(segmentation_path)
    catch
        fprintf('Cannot load segmentation');
        return;
    end     
    % Get the advanced options:
    EXTRA_NAME = '';
    if STRATEGIES
        DISTRIBUTION = STR_DISTR;
    end
    if TRANSITIONS || PROBABILITIES
        DISTRIBUTION = TRANS_DISTR;
    end
    if DISTRIBUTION == 2 %no smooth, skip rest and add indication in the folder name
        EXTRA_NAME = '_nosmooth';
        SIGMA = 0;
        INTERVAL = 0;
    else
        SIGMA = SIGMA*R_SIGMA;
        if SIGMA == 0 %default
            SIGMA = segmentation_configs.COMMON_PROPERTIES{8}{1}; %equals R
        end
        INTERVAL = INTERVAL*R_INTERVAL;
        if INTERVAL == 0 %default
            INTERVAL = segmentation_configs.COMMON_PROPERTIES{8}{1}; %equals R
        end      
        if SIGMA*R_SIGMA~= 0 || INTERVAL*R_INTERVAL~= 0 %custom smooth
            EXTRA_NAME = strcat('_smooth_S',num2str(SIGMA),'_I',num2str(INTERVAL));
        end
    end

    % Full trajectories
    full_traj = 0;
    if segmentation_configs.SEGMENTATION_PROPERTIES(1) == 0 && segmentation_configs.SEGMENTATION_PROPERTIES(2) == 0
        if TRANSITIONS || PROBABILITIES
            fprintf(1,'Transitions and Probabilities not available for full trajectories');
            return;
        elseif STRATEGIES
            full_traj = 1;
        end
    end
    
    % Full trajectories strategies with manual labelling 
    if full_traj == 1
        error_all = results_strategies_distributions_manual_full(project_path,sfile,lfile,animals_trajectories_map,1);
        return
    end
    
    % Check selected classification
    if isempty(class)
        return
    end
    [error,name,classifications,~] = check_classification(project_path,segmentation_configs,class);
    if error 
        return
    end
    
    if STRATEGIES
        % Convert some of the remaining full trajectories to segments?
        if TRAJ_TO_SEGMENT
            if ~iscell(project_path)
               tmp_path = {project_path};
            end    
            [~,extra_segments] = browse(tmp_path,segmentation_configs);
             error_all = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, 'Strategies', groups,...
                 'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL,'extra_segments',extra_segments, 'FIGURES', INTERIM_FIGURES, 'EXTRA_NAME', EXTRA_NAME);
        else
             error_all = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, 'Strategies', groups,...
                 'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL,'FIGURES', INTERIM_FIGURES, 'EXTRA_NAME', EXTRA_NAME);
        end    
     end
     if PROBABILITIES
        error_all = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, 'Probabilities', groups,...
            'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL,'FIGURES', INTERIM_FIGURES, 'EXTRA_NAME', EXTRA_NAME);
    end
    if TRANSITIONS
          error_all = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, 'Transitions', groups,...                                                           
            'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL,'FIGURES', INTERIM_FIGURES, 'EXTRA_NAME', EXTRA_NAME);

    end

end

