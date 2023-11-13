
figure1 = figure('visible','on');

ax1 = subplot( 2, 1, 1 );
    
ax2 = subplot(2,1,2);

%parameters_set = [0.4 0.3; 0.4 0.6; 0.8 0.3; 0.8 0.6];
parameters_set = combvec(DOE_range1(1,:), DOE_range1(2,:)).';

position_ID_1 = IPs_IDs1;

[sorted_position_ID_2, idx] = sort(IDs_current_density);

p1 = cell(length(length(parameters_set)),1);
plot_lines1 = zeros(length(parameters_set),1);

p2 = cell(length(length(parameters_set)),1);
plot_lines2 = zeros(length(parameters_set),1);


for i = 1:length(parameters_set)
    
    model_output = output_from_surrogates(parameters_set(i,:), surrogates, [17,10]);
    
    %meas_potential = ;
    %}
    output_potential = model_output{1};
   
    output_current_density = model_output{2};
    
    output_current_density = output_current_density(idx);
    
    %data1 = tableA{:,[2,6]};
   
    p1{i} = plot(ax1, position_ID_1,output_potential, 'DisplayName', strcat('Output from ', i, ' th prediction'));

    plot_lines1(i) = p1{i}(1);
    p2{i} = plot(ax2, sorted_position_ID_2,output_current_density , 'DisplayName', strcat('Output from ', i, ' th prediction'));
    plot_lines2(i) = p2{i}(1);
    %data2 = tableB{:,[2,6]};
    
    hold(ax1, 'on');
    
    hold(ax2, 'on');
    
    xlim(ax1, [position_ID_1(1) position_ID_1(end)]);
    xlabel(ax1, 'Mesh Position ID');
    ylabel(ax1, 'Potential value (mV)');
    %string(uint64(position_ID_1))
    %xticklabels(ax1, uint64(position_ID_1));
    
    %set(ax1,'XTickLabel',uint64(position_ID_1)),set(ax1,'XTick',1:numel(position_ID_1))

    xticks(ax1, position_ID_1(1:2:end));
    xticklabels(ax1, uint64(position_ID_1(1:2:end)));

    ylabel(ax1, 'Potential value (mV)');
    %plot(data2(:,1), data2(:,2),'DisplayName', 'Model Output');

    xlabel(ax2, 'Element ID');
    xlim(ax2, [sorted_position_ID_2(1) sorted_position_ID_2(end)]);
    xticks(ax2, sorted_position_ID_2(1:2:end));
    xticklabels(ax2, uint64(sorted_position_ID_2(1:2:end)));
    ylabel(ax2, 'Normal Current density (mAmp/sq m)');

    %legend(ax1, {'Measurement data','solution Model Output'}, 'Location','southeast');
    
    %legend(ax2, {'Measurement data','solution Model Output'}, 'Location','southeast');
    %{
    ax3 = axes('position',[.25 .35 .15 .15], 'NextPlot', 'add');
    plot(ax3, sorted_position_ID_2(2:3), output_current_density(2:3));
    xticks(ax3, sorted_position_ID_2(2:3));
    xticklabels(ax3, uint64(sorted_position_ID_2(2:3)));
    %}
end

%legend(ax1, plot_lines1, strcat('Output from combination: ', string(1:length(parameters_set))));
legend(ax1, plot_lines1, strcat('Output from combination: ', string(parameters_set(:,1)),'-',string(parameters_set(:,2))));
  
    %hold on;