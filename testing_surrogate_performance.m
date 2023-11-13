
%function NMSE_arr = testing_surrogate_performance(parameters, input_sample_points, surrogates, simulation_seed_folder,  collection_dir, calibration_data_type, py_modules_involved,  current_density_type, calibration_data_count, py_data_count, metric_wt_constant)

[parameters, input_sample_points, surrogates, simulation_seed_folder,  collection_dir, calibration_data_type, py_modules_involved,  current_density_type, calibration_data_count, py_data_count, metric_wt_constant] = deal(parameters, DOE_sample_points2, Fits_2nd_order, simulation_seed_folder,  collection_dir, calibration_data_type, py_modules_involved,  current_density_type, calibration_data_count, py_calibration_data_count, metric_wt_constant);

NMSE_arr = zeros(size(input_sample_points,1),1);

for i = 1:size(input_sample_points,1)
    
    simulation_outp  = py.BEASY_IN_OUT.get_output_data_for_given_parameters(py.list(parameters),  py.list(input_sample_points(i,:)), simulation_seed_folder,  collection_dir, py.list(calibration_data_type), py_modules_involved,  current_density_type, py_data_count);
    
    simulation_outp_cells = convert_pydict2data(simulation_outp,1);
    %data_counts = calibration_data_count;
    surrogate_output = output_from_surrogates(input_sample_points(i,:), surrogates,  calibration_data_count);

    %data_involved = calibration_data_type;
    NMSE_arr(i)= normalised_mean_sq_diff(surrogate_output, simulation_outp_cells, calibration_data_type, metric_wt_constant);
    
    if isequal(i ,5)
        %title_for_com_plot = sprintf('Comparison plot between surrogate and simulation output for 
        comparision_plot(simulation_outp(2:3), simulation_outp_cells, surrogate_output, '');
    end
    %NMSE_arr(i) = obj_from_surrogate(input_sample_points(i,:), parameter_bounds, surrogates, calibration_data_type, calibration_data_count, simulation_outp,metric_wt_constant);
end


function f = normalised_mean_sq_diff(model_output, meas_data, data_involved, weightage_constant)

    if length(data_involved) > 1
        f = 0;
        for i = 1:length(data_involved)
            f = f + weightage_constant(i)* sqrt( mean((model_output{i}-meas_data{i}).^2./meas_data{i}.^2 ));
        end
        
        f = f/length(data_involved);
        
    elseif strcmp(data_involved{1}, 'voltage')
        f = sqrt( mean((model_output{1}-meas_data{1}).^2./meas_data{1}.^2));
    elseif strcmp(data_involved{1}, 'current density')
        f = sqrt( mean((model_output{2}-meas_data{2}).^2./meas_data{2}.^2));
    end
   
end

function output_data = convert_pydict2data(py_dict_data, extra_cell_provided)

output_data = cell(size(py_dict_data,2)-extra_cell_provided,1);

for i = 1:size(py_dict_data,2)-extra_cell_provided
    output_data{i} = convert_py_list_to_mat_arr(py.model_validation1.get_list_of_values(py_dict_data{i+extra_cell_provided}));
end
end