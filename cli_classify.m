function cli_classify(project_path,seg_name,lab_name,varargin)

    weka_init;

    CLASSIFICATION_MODE = "Re-generate";
    classification_settings = [0,100,0,25,40,0];

    for i = 1:length(varargin)
        if isequal(varargin{i},'CV_ERROR')
            classification_settings(1) = varargin{i+1};        
        elseif isequal(varargin{i},'CV_K')
            classification_settings(2) = varargin{i+1};
        elseif isequal(varargin{i},'CV_START')
            classification_settings(3) = varargin{i+1};
        elseif isequal(varargin{i},'CV_END')
            classification_settings(4) = varargin{i+1};
        elseif isequal(varargin{i},'CV_SIZE')
            classification_settings(5) = varargin{i+1};
        elseif isequal(varargin{i},'CV_KS')
            classification_settings(6) = varargin{i+1};
        elseif isequal(varargin{i},'CLASSIFICATION_MODE')
            CLASSIFICATION_MODE = varargin{i+1};
        end
    end
    fprintf(1,"Loading settings...\n")
    %% Load the settings
    try
        load(fullfile(project_path,'settings','new_properties.mat'));
        load(fullfile(project_path,'settings','animal_groups.mat'));
        load(fullfile(project_path,'settings','my_trajectories.mat'));   
        %full_trajectory_features(project_path,'WAITBAR',0,'DISPLAY',0); % Trajectories
        load(fullfile(project_path,'settings','my_trajectories_features.mat'));
    catch ME
        fprintf(2,'Cannot load project settings');
        fprintf(2,'%s',ME.message);
        return
    end        

   groups = unique(trajectory_groups{:}(:,2));
   datapath = fullfile(project_path,'settings');

    %% Animal Trajectories Map
    [~, animals_trajectories_map, animals_ids] = trajectories_map(my_trajectories,my_trajectories_features,groups,'Friedman');

    %%Classification
    fprintf(1,"Performing classification\n");
    error = default_classification(project_path,seg_name,lab_name,classification_settings,CLASSIFICATION_MODE);
    if error == 2 %perform cv first 
        options = 'labels';
        p = strsplit(lab_name,'.mat');
        p = p{1};
        output_path = char(fullfile(project_path,'labels',strcat(p,'_check'),options));
        mkdir(output_path);
        labels = char(fullfile(project_path,'labels',lab_name));
        load(char(fullfile(project_path,'segmentation',seg_name)));
        if classification_settings(6) == 0
            load(labels);
            tags = unique(cell2mat(LABELLING_MAP));
            tmp = find(tags <= 0);
            tags = length(tags) - length(tmp) + 2;
        end
        [nc,res1bare,res2bare,res1,res2,res3,covering] = cross_validation(segmentation_configs,labels,10,[tags,classification_settings(2),1],output_path,options,0,'WAITBAR',0,'DISPLAY',0);
        output_path = char(fullfile(project_path,'results',strcat(p,'_cross_validation'),options));
        mkdir(output_path);
        [nc,per_errors1,per_undefined1,coverage,per_errors1_true] = algorithm_statistics(1,1,nc,res1bare,res2bare,res1,res2,res3,covering);
        data = [nc', per_errors1', per_undefined1', coverage', per_errors1_true'];
        % export results to CSV (inside the results and the labels folders)
        export_num_of_clusters(output_path,data);
        output_path2 = char(fullfile(project_path,'labels',strcat(p,'_check'),options));
        export_num_of_clusters(output_path2,data);     
        error = default_classification(project_path,seg_name,lab_name,classification_settings,CLASSIFICATION_MODE);
    elseif error == 1
        fprintf(2,"Cannot create classification folder")
        return
    end
    if ~error
        fprintf(1,'Operation successfully completed\n')
    end 
       
end

