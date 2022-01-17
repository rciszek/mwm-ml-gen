function batch_run(project_path,seg_name,lab_name,class_name,varargin)

    %% Set main path
    main_path = cd(fileparts(mfilename('fullpath')));
    addpath(genpath(main_path));

    fid = fopen(fullfile(project_path,'settings','batch_settings.json')); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    batch_settings = jsondecode(str);
    
    CLASSIFICATION = 1;
    PROBABILITIES = 1;
    METRICS = 1;
    STRATEGIES = 1;
    TRANSITIONS = 1;
    INTERIM_FIGURES = 0;

    for i = 1:length(varargin)
        if isequal(varargin{i},'CLASSIFICATION')
            CLASSIFICATION = varargin{i+1};
        elseif isequal(varargin{i},'PROBABILITIES')
            PROBABILITIES = varargin{i+1};
        elseif isequal(varargin{i},'METRICS')
            METRICS = varargin{i+1};
        elseif isequal(varargin{i},'STRATEGIES')
            STRATEGIES = varargin{i+1};
        elseif isequal(varargin{i},'TRANSITIONS')
            TRANSITIONS = varargin{i+1};
        elseif isequal(varargin{i},'INTERIM_FIGURES')
            INTERIM_FIGURES = varargin{i+1};
        end
    end

   if CLASSIFICATION
       fprintf(1,"Starting classification...\n")
       cli_classify(project_path,seg_name,lab_name,'CV_ERROR',batch_settings.cv_error,'CV_K',batch_settings.cv_k,'CV_START',batch_settings.cv_start,...
                   'CV_END', batch_settings.cv_end, 'CV_SIZE', batch_settings.cv_size, 'CV_KS', batch_settings.cv_ks, 'CLASSIFICATION_MODE', batch_settings.classification_mode)
       fprintf(1,"Classification completed\n")

       [labs,len,ovl,note,~] = split_labels_name(lab_name);
       [~,segs,~,~] = split_segmentation_name(seg_name);
       %When classification is performed results will be computed based on the classification just performed
       class_name=strcat('class','_',labs,'_',segs,'_',len,'_',ovl,'-',note);
   end 
    
   if METRICS
      fprintf(1,"Generating metrics...\n")
      cli_generate_results(project_path,batch_settings.groups,seg_name,lab_name,class_name,'PROBABILITIES',0,'METRICS',METRICS,'STRATEGIES',0,...
                 'TRANSITIONS',0,'INTERIM_FIGURES',INTERIM_FIGURES,'TRAJ_TO_SEGMENT',batch_settings.traj_to_segment,'STR_DISTR',batch_settings.str_distr,...
                 'SIGMA',batch_settings.sigma,'INTERVAL',batch_settings.interval,'R_SIGMA',batch_settings.r_sigma,'R_INTERVAL',batch_settings.r_interval )
   end    
   if STRATEGIES
      fprintf(1,"Generating strategies...\n")
      cli_generate_results(project_path,batch_settings.groups,seg_name,lab_name,class_name,'PROBABILITIES',0,'METRICS',0,'STRATEGIES',STRATEGIES,...
                 'TRANSITIONS',0,'INTERIM_FIGURES',INTERIM_FIGURES,'TRAJ_TO_SEGMENT',batch_settings.traj_to_segment,'STR_DISTR',batch_settings.str_distr,...
                 'SIGMA',batch_settings.sigma,'INTERVAL',batch_settings.interval,'R_SIGMA',batch_settings.r_sigma,'R_INTERVAL',batch_settings.r_interval )
   end
   if TRANSITIONS
      fprintf(1,"Generating transitions...\n")
      cli_generate_results(project_path,batch_settings.groups,seg_name,lab_name,class_name,'PROBABILITIES',0,'METRICS',0,'STRATEGIES',0,...
                 'TRANSITIONS',TRANSITIONS,'INTERIM_FIGURES',INTERIM_FIGURES,'TRAJ_TO_SEGMENT',batch_settings.traj_to_segment,'STR_DISTR',batch_settings.str_distr,...
                 'SIGMA',batch_settings.sigma,'INTERVAL',batch_settings.interval,'R_SIGMA',batch_settings.r_sigma,'R_INTERVAL',batch_settings.r_interval )
   end
   if PROBABILITIES
      fprintf(1,"Generating probabilities...\n")
      cli_generate_results(project_path,batch_settings.groups,seg_name,lab_name,class_name,'PROBABILITIES',1,'METRICS',0,'STRATEGIES',0,...
                 'TRANSITIONS',0,'INTERIM_FIGURES',INTERIM_FIGURES,'TRAJ_TO_SEGMENT',batch_settings.traj_to_segment,'STR_DISTR',batch_settings.str_distr,...
                 'SIGMA',batch_settings.sigma,'INTERVAL',batch_settings.interval,'R_SIGMA',batch_settings.r_sigma,'R_INTERVAL',batch_settings.r_interval )
   end

    if batch_settings.smoothing == 'Before'
        [error,~,~] = class_statistics(project_path, class_name);
    else
        try
            tmp = strsplit(class_name,'_');
            tmp = strcat('segmentation_configs_',tmp{3},'_',tmp{4},'_',tmp{5},'.mat');
            load(fullfile(project_path,'segmentation',tmp));
        catch
            fprintf(1,'Cannot load segmentation object');
            return
        end
        [error,~,~] = class_statistics(project_path, class_name, 'SEGMENTATION', segmentation_configs);
   end

end

