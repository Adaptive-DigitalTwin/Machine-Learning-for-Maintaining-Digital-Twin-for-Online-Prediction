%%
parameters= {'CA25','CB25'};

calibration_data_type = {'voltage', 'normal current density'};
%calibration_data_type = {'voltage'};
%calibration_data_type = {'voltage', 'current density', 'Z_ELECTRIC_FIELD'};

metric = 'nmsq';

IP_dir = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_5\Measurement_data";

meas_data_Internal_Points = csvread(fullfile(IP_dir, 'Internal_Points.csv'),1,1);

MPs_IDs = meas_data_Internal_Points(:,1);

MPs_IDs1 = MPs_IDs(1:3:end);

length(MPs_IDs1);

%MP_IDs_normal_current_density = [1225, 4270, 925, 7870, 3709];

%IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802];

IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802, 30002, 23822,21212, 8437];
IDs_current_density = IDs_current_density(1:2:end);

IDs = {py.list(MPs_IDs1), py.list(IDs_current_density)};

%IDs = meas_data_Internal_Points(:,1);

%limit_considered = [-1.5 1.5];

%DOE_range1 = predicted_p_value_25.'+limit_considered; 
%DOE_range1 = [13.3040, 16.3040; 8.8900, 11.8900];
DOE_range1 = [13.7433, 17.5; 9.3293, 13.5];
%DOE_range2 = [1.4, 2.5; 2.6, 3.8];
%DOE_range3 = [1.8, 2.8; 2.2, 3.7];

%}
%DOE experiment for 2 varaibles using Central Composite Design
Central_composite_points = ccdesign(2, 'type', 'inscribed', 'center' , 4);

DOE_sample_points1 = reverse_normalization(Central_composite_points, DOE_range1);
%DOE_sample_points2 = reverse_normalization(Central_composite_points, DOE_range2);
%DOE_sample_points3 = reverse_normalization(Central_composite_points, DOE_range3);

%DOE_sample_points = [DOE_sample_points ;reverse_normalization(Central_composite_points, DOE_range2)];
root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_25';
simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%simulation_seed_folder  = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_linear\Parameter_BARE_Zone1\Initial_files1";

collection_dir = fullfile(root_folder, 'Simulation_results');

IDs_types = {'Internal Points', 'Mesh Points'};

parameters_np_array1 = convert_arr_to_python_2d_list(DOE_sample_points1);

snapshots_py = py.BEASY_IN_OUT1.snapshots_for_given_parameters_and_IDs(py.list(parameters), parameters_np_array1, py.list(IDs), py.list(calibration_data_type), simulation_seed_folder, collection_dir, py.list(IDs_types));

snapshots = double(snapshots_py);

surrogates = response_surface(DOE_sample_points1, snapshots);
%}
%%
meas_dir = fullfile(root_folder,'Measurement_data');
%meas_dir1 = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_nonlinear\Parameter_BARE_BBS\Measurement_results3';

files_name = 'BU_TimeStepped_01_25';
%meas_dict = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(meas_dir, files_name, py.list(calibration_data_type),  py.list(IDs), py.list(IDs_types));

%meas_data = convert_pydict2data(meas_dict,0);

meas_data_file_err_inc = 'data_with_error.xlsx';

if ~isfile(fullfile(meas_dir, meas_data_file_err_inc))
    all_position_dict = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(meas_dir, files_name, py.list(calibration_data_type),  py.list({py.list(MPs_IDs), py.list(IDs_current_density)}), py.list(IDs_types));
    all_position_data = convert_pydict2data(all_position_dict,0);
    all_position_dict_with_error = introduce_error_and_write_file(all_position_data, meas_dir, meas_data_file_err_inc,3);
else
    data_from_tables(fullfile(meas_dir, meas_data_file_err_inc), {MPs_IDs, IDs_current_density},3);
end
%model_out = output_from_surrogates([16.0, 11.0], surrogates, [length(IDs{1}), length(IDs{2})]);

meas_data_inc_error = data_from_tables(fullfile(meas_dir, meas_data_file_err_inc), {MPs_IDs1, IDs_current_density},3);
meas_data_no_error = data_from_tables(fullfile(meas_dir, meas_data_file_err_inc), {MPs_IDs1, IDs_current_density},2);

calibration_data2 = {out_frm_surr3{1}(1:3:end,:); out_frm_surr3{2}(1:2:end,:)};

%plot_and_save(meas_dict, meas_data, 'adfa', meas_dir)
figure;

ax =gca;

%[Zmin, min_out_pos] = plot_objective_with_surrogates(ax, DOE_range1, surrogates, meas_data_inc_error, 'nmsq', calibration_data_type, [length(IDs{1}), length(IDs{2})],[1,0.5], [0.05,0.05]);
%[Zmin2, min_out_pos2] = plot_objective_with_surrogates(ax, DOE_range1, surrogates, calibration_data, 'nmsq', calibration_data_type, [length(IDs{1}), length(IDs{2})],[1,0.5], [0.05,0.05]);
[Zmin2, min_out_pos3] = plot_objective_with_surrogates(ax, DOE_range1, surrogates, calibration_data2, 'nmsq', calibration_data_type, [length(IDs{1}), length(IDs{2})],[1,0.5], [0.05,0.05]);
%surrogate_sol_out = output_from_surrogates(min_out_pos, surrogates, [length(IDs{1}), length(IDs{2})])
%min_out_pos = [];
%%
%repetitive_calibration_count = 2;
solution_folder = '';
for i = 1:length(parameters)
    solution_folder =   strcat(solution_folder, parameters{i},'_', num2str(min_out_pos3(i), '%.4f'));
    if i~=length(parameters)
        solution_folder = strcat(solution_folder, '_');
    end
end
solution_dir = fullfile(root_folder,'Simulation_results', solution_folder);

if ~isfolder(solution_dir)
    solution_dict = py.BEASY_IN_OUT1.get_response_data_for_IDs_and_input_parameters(py.list(parameters), min_out_pos3, simulation_seed_folder, collection_dir,  py.list(calibration_data_type), py.list(IDs),  py.list(IDs_types));
    solution_data = convert_pydict2data(solution_dict,1);
else

    solution_dict = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(solution_dir, files_name, py.list(calibration_data_type),  py.list(IDs), py.list(IDs_types));
    solution_data = convert_pydict2data(solution_dict,0);
end

%%
%response_dict = py.BEASY_IN_OUT1.get_response_data_for_IDs_and_input_parameters(py.list(parameters), [16.0 11.0], simulation_seed_folder, collection_dir,  py.list(calibration_data_type), py.list(IDs),  py.list(IDs_types));
    
%response_data = convert_pydict2data(response_dict,1);
figure;
ax = gca;
%difference_in_bar_chart(ax,simulation_data{1}(1:4:end,:), out_frm_nnet{1}(1:4:end,:),{'simuation predicted data','nnet model predicted data', 'difference'});
difference_in_bar_chart(ax,meas_data_inc_error{1}(1:2:end,:), solution_data{1}(1:2:end,:),{'Inspection data','solution model output calibrated with predicted data', 'difference'});



function output_data = convert_pydict2data2(py_dict_data, extra_cell_provided)

output_data = cell(size(py_dict_data,2)-extra_cell_provided,1);

for i = 1:size(py_dict_data,2)-extra_cell_provided
    output_data{i} = convert_py_list_to_mat_arr(py.model_validation1.get_list_of_values(py_dict_data{i+extra_cell_provided}));
end
end


function de_normaised_data = reverse_normalization(normalised_data, value_ranges)

de_normaised_data = zeros(size(normalised_data));

for i = 1:size(normalised_data, 2)
    
    de_normaised_data(:,i) = value_ranges(i,1)+ diff(value_ranges(i,:))/2 * (normalised_data(:,i)-(-1));
    
end
end