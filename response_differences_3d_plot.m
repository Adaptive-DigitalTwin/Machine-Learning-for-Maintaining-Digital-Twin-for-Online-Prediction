function response_differences_3d_plot(ax, data_with_IDs, meas_data, model_output, data_idx, data_type,Ids_type, files_name, files_dir)
    
    position_ID_1 = data_with_IDs{data_idx}(:,1);
    
    [sorted_position_ID_1, idx] = sort(position_ID_1);

    meas_response_data =  meas_data{data_idx}(:,end);
    
    meas_response_data = meas_response_data(idx);
    
    output_response_data =  model_output{data_idx}(:,end);
    
    output_response_data = output_response_data(idx);
    
    gdf_file = strcat(files_name, '.gdf');
    
    if strcmp(Ids_type, 'Internal Points') || strcmp(Ids_type, 'Mesh Points')
        
        dat_file = strcat(files_name, '.dat');
        
        IDs_coordinate_data = py.BEASY_IN_OUT1.xyz_coordinates_for_IDS(py.list(int64(sorted_position_ID_1)), fullfile(files_dir, dat_file), Ids_type);
        
    elseif strcmp(Ids_type, 'Element Points')
        
        IDs_coordinate_data = py.BEASY_IN_OUT1.xyz_coordinates_for_element_IDS(py.list(int64(sorted_position_ID_1)), fullfile(files_dir, gdf_file));
        
    end
    
    IDs_coordinate_data = convert_py_dict_lists_to_array(IDs_coordinate_data);
    
    heat_plot(ax, meas_response_data, output_response_data, IDs_coordinate_data, data_type);
    
end

function arr = convert_py_list_to_arr1(py_list)
    arr = zeros(1,length(py_list));
    for i = 1:length(py_list)
        arr(1,i) = py.float(py_list{i});
    end
end


function heat_plot(ax, meas_data, model_output, coordinate_data, data_type) 

difference_data = model_output- meas_data;
%difference_data = model_output;

%scatter3(ax, coordinate_data(:,[2]),coordinate_data(:,[3]),coordinate_data(:,[4]),40,difference_data,'filled')    % draw the scatter plot

%scatter3(ax, coordinate_data(1:4:end,[2]),coordinate_data(1:4:end,[3]),coordinate_data(1:4:end,[4]),40, difference_data(1:4:end), 'filled');   % draw the scatter plot
scatter3(ax, coordinate_data(1:2:end,[2]),coordinate_data(1:2:end,[3]),coordinate_data(1:2:end,[4]),40, difference_data(1:2:end), 'filled');   % draw the scatter plot


ax.ZDir = 'reverse';
view(21,21)
xlabel(ax, 'x pos');
ylabel(ax, 'y pos');
zlabel(ax, 'z pos');

cb = colorbar;    
% create and label the colorbar
%caxis([-20 20]);
if strcmp(data_type, 'voltage')
    %cb.Label.String = 'difference in p.d. (mV) (model output - measured)';
    cb.Label.String = 'difference in potential difference mv Ag/Agcl ';

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
