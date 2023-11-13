function plot_and_save(meas_dict, model_output, name_for_plot, measurement_folder)
    
    figure1 = figure('visible','on');
    ax1 = subplot( 2, 1, 1 );
    
    ax2 = subplot(2,1,2);
    
    position_ID_1 = py.model_validation1.get_list_of_keys(meas_dict{1});
    
    %potential_IDs_coordinate_data = py.BEASY_IN_OUT.xyz_coordinates_for_Mesh_point_IDS(position_ID_1, fullfile(measurement_folder,'BU_TimeStepped_01_10.dat'));
    
    position_ID_1 = convert_py_list_to_arr(position_ID_1);
    
    position_ID_2 = py.model_validation1.get_list_of_keys(meas_dict{2});
    
    position_ID_2 = convert_py_list_to_arr(position_ID_2);
    
    %meas_potential = ;
    %}
    meas_potential = convert_py_list_to_arr1(py.model_validation1.get_list_of_values(meas_dict{1}));
    
    meas_current_density = convert_py_list_to_arr1(py.model_validation1.get_list_of_values(meas_dict{2}));
    
    
    
    output_potential = convert_py_list_to_arr1(py.model_validation1.get_list_of_values(model_output{2}));
    
    output_current_density = convert_py_list_to_arr1(py.model_validation1.get_list_of_values(model_output{3}));
    
        
    [sorted_position_ID_2, idx] = sort(position_ID_2);
    
    meas_current_density = meas_current_density(idx);
    
    output_current_density = output_current_density(idx);
    
    %data1 = tableA{:,[2,6]};
   
    plot(ax1, position_ID_1,meas_potential , 'DisplayName', 'Measurement data');

    
    plot(ax2, sorted_position_ID_2,meas_current_density , 'DisplayName', 'Measurement data');

    %data2 = tableB{:,[2,6]};
    
    hold(ax1, 'on');
    
    hold(ax2, 'on');
    
    plot(ax1, position_ID_1,output_potential , 'DisplayName', 'Model Output');
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
    
    plot(ax2, sorted_position_ID_2,output_current_density , 'DisplayName', 'Measurement data');
    xlabel(ax2, 'Element ID');
    xlim(ax2, [sorted_position_ID_2(1) sorted_position_ID_2(end)]);
    xticks(ax2, sorted_position_ID_2(1:2:end));
    xticklabels(ax2, uint64(sorted_position_ID_2(1:2:end)));
    ylabel(ax2, 'Normal Current density (mAmp/sq m)');

    legend(ax1, {'Measurement data','solution Model Output'}, 'Location','southeast');
    
    legend(ax2, {'Measurement data','solution Model Output'}, 'Location','southeast');
    
    ax3 = axes('position',[.25 .35 .15 .15], 'NextPlot', 'add');
    plot(ax3, sorted_position_ID_2(2:3), meas_current_density(2:3));
    plot(ax3, sorted_position_ID_2(2:3), output_current_density(2:3));
    xticks(ax3, sorted_position_ID_2(2:3));
    xticklabels(ax3, uint64(sorted_position_ID_2(2:3)));
    %hold on;
    
    %plot(x6(indexOfInterest2), y6(indexOfInterest2));
    
    %saveas(figure1, fullfile('Plots',name_for_plot));
     %{
    figure2 = figure('visible','off');
    %figure2 = figure;
    %}
    %{
    ax3 = subplot( 1, 1, 1 );
    
    potential_IDs_coordinate_data = convert_py_dict_lists_to_array(potential_IDs_coordinate_data);
    
    heat_plot(ax3, meas_potential, output_potential, potential_IDs_coordinate_data, 'potential');
    
    name_for_file = compose('heat_potential_%s', name_for_plot);
    saveas(figure2, fullfile('Plots',name_for_file{1}));
    %}
    figure3 = figure('visible','off');
    
    %{
    ax4 = subplot(1,1,1);
    
    current_IDs_coordinate_data = py.BEASY_IN_OUT.xyz_coordinates_for_element_IDS(py.list(sorted_position_ID_2), fullfile(measurement_folder,'BU_Jacket_newCurves.gdf'));
    
    current_IDs_coordinate_data = convert_py_dict_lists_to_array(current_IDs_coordinate_data);
    
    heat_plot(ax4, meas_current_density, output_current_density, current_IDs_coordinate_data, 'current density');
    
    name_for_file = compose('heat_current_density_%s', name_for_plot);
    saveas(figure3, fullfile('Plots',name_for_file{1}));
    %}
end

function arr1 = convert_py_list_to_arr(py_list)
    arr1 = zeros(1,length(py_list));
    for i = 1:length(py_list)
        arr1(1,i) = py.int(py_list{i});
    end
end

function arr = convert_py_list_to_arr1(py_list)
    arr = zeros(1,length(py_list));
    for i = 1:length(py_list)
        arr(1,i) = py.float(py_list{i});
    end
end


function heat_plot(ax, meas_data, model_output, coordinate_data, data_type) 

%difference_data = model_output- meas_data;
difference_data =  meas_data;

scatter3(ax, coordinate_data(:,[2]),coordinate_data(:,[3]),coordinate_data(:,[4]),40,difference_data,'filled')    % draw the scatter plot

ax.ZDir = 'reverse';
view(221,21)
xlabel(ax, 'x pos')
ylabel(ax, 'y pos')
zlabel(ax, 'z pos')

cb = colorbar;    
% create and label the colorbar
%caxis([-20 20]);
if strcmp(data_type, 'potential')
    cb.Label.String = 'difference in p.d. (mV) (model output - measured)';

else
    cb.Label.String = 'difference in current density (model output - measured)';

end

end

function arr1 = convert_py_dict_lists_to_array(dict_with_lists)

keys = py.model_validation1.get_list_of_keys(dict_with_lists);

multiple_lists  = py.model_validation1.get_list_of_values(dict_with_lists);

arr1 = zeros(length(multiple_lists{1}), length(keys));

for i = 1:length(keys)
    arr1(:,i) = convert_py_list_to_arr1(multiple_lists{i});
end

end
