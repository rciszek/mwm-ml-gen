function one_group_metrics( animals_trajectories_map, vars, total_trials, sessions, trials_per_session )
%results_latency_speed_length for one group only

    names = {'latency' , 'speed' , 'length'};
    ylabels = {'latency [s]', 'speed [cm/s]', 'path length [m]'};
    fontsize = 10;
    
    for i = 1:size(vars, 1)
        figure
        values = vars(i, :);
        data = [];
        groups = [];
        d = .1;
        idx = 1;
        pos = zeros(1, total_trials);
        grp = 1;
        for s = 1:sessions
            for t = 1:trials_per_session                   
                pos(idx) = d;
                d = d + 0.1;
                idx = idx + 1;
                d = d + 0.07;
            end
            d = d + 0.15;
        end
                         
        for t = 1:total_trials    
            g = 1;
            map = animals_trajectories_map{g};
            tmp = values(map(t, :));                 
            data = [data, tmp(:)'];          
            groups = [groups, repmat(t*2 - 1 + g - 1, 1, length(tmp(:)))];
        end
                                                   
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0]);
        set(gca, 'LineWidth', 1.5, 'FontSize', fontsize);
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     
        
        set(gca, 'XLim', [0, max(pos) + 0.1], 'XTickLabel', lbls, 'FontSize', fontsize);                 
        set (gca, 'Yscale', 'linear');        

        ylabel(ylabels{i}, 'FontSize', fontsize);
        xlabel('trial', 'FontSize', fontsize);

        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
        end
        set([h], 'LineWidth', 0.8);
   
        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', 2);
        end
        
        h = findobj(gca, 'Tag', 'Outliers');
        for j=1:length(h)
            set(h(j), 'MarkerEdgeColor', [0 0 0]);
        end
        
        set(gcf, 'Color', 'w');
        box off;        
        set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);
        export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'/'), sprintf('animals_%s', names{i}));           
    end        
end

