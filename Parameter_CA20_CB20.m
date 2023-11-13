

%%
source_parameters = {'BARE','BARE'};

parameters= {'CA20','CB20'};

x0 = [1.5, 2.5];
%x0 = [2.0, 3.33];
%tru_sol_x0 = [2.0, 3.33333, 7.0, 7.0, 0.66667];

%data_type = {'voltage', 'anode related'};
response_data_type = {'voltage', 'normal current density', 'anode related'};

%data_type = {'voltage', 'normal current density'};
%calibration_data_type = {'voltage'};
%calibration_data_type = {'voltage', 'current density', 'Z_ELECTRIC_FIELD'};

metric = 'nmsq';

IP_dir = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_5\Measurement_data";

meas_data_Internal_Points = csvread(fullfile(IP_dir, 'Internal_Points.csv'),1,1);

%MPs_IDs1 = MPs_IDs(1:3:end);
IPs_IDs = meas_data_Internal_Points(:,1);

IPs_IDs1 = IPs_IDs(1:2:end);

IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802, 30002, 23822,21212, 8437];
%IDs_current_density =[27791       27813       27839       27859];

anode_related_IDs = 1:2;

IDs = {py.list(IPs_IDs1), py.list(IDs_current_density), py.list(anode_related_IDs)};


%%
%DOE_range1 = [8, 12; 5.5, 8.5]; 

DOE_range2 = [0.2, 0.3; 0.15,  0.22];
%DOE_range1 = [0.3, 0.4; 0.22,  0.32];calib_data_IDs

%DOE_range2 = [1.4, 2.5; 2.6, 3.8];
%DOE_range3 = [1.8, 2.8; 2.2, 3.7];

%DOE experiment for 2 varaibles using Central Composite Design
Central_composite_points = ccdesign(2, 'type', 'inscribed', 'center' , 1);

DOE_sample_points20 = reverse_normalization(Central_composite_points, DOE_range2);
%DOE_sample_points2 = reverse_normalization(Central_composite_points, DOE_range2);
%DOE_sample_points3 = reverse_normalization(Central_composite_points, DOE_range3);

%DOE_sample_points = [DOE_sample_points ;reverse_normalization(Central_composite_points, DOE_range2)];
root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_20';
simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%simulation_seed_folder  = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_linear\Parameter_BARE_Zone1\Initial_files1";

collection_dir = fullfile(root_folder, 'Simulation_results');

IDs_types = {'Internal Points','Mesh Points', 'MASS_LOSS_RATE'};
%%
parameters_np_array1 = convert_arr_to_python_2d_list(DOE_sample_points20);

snapshots_py = py.BEASY_IN_OUT2.snapshots_for_given_parameters_and_IDs(py.list(source_parameters),  py.list(parameters), parameters_np_array1, py.list(IDs), py.list(response_data_type), simulation_seed_folder, collection_dir, py.list(IDs_types));

snapshots_20 = double(snapshots_py);
%%
%merging_snapshots

previous_sample_points = [DOE_sample_points1(4:2:end,:) ;DOE_sample_points1(end,:)];
%DOE_sample_points_updated = [DOE_sample_points1; DOE_sample_points20(5:end,:)];
added_sample_Points = [DOE_sample_points20(1:4,:); DOE_sample_points20(end,:)];

DOE_sample_points_updated = [previous_sample_points; added_sample_Points];
%DOE_sample_points_updated = [DOE_sample_points1; DOE_sample_points20(1:4,:)];

indices1 = find(ismember(DOE_sample_points1, previous_sample_points,'rows'));
indices2 = find(ismember(DOE_sample_points20, added_sample_Points,'rows'));

snapshots_updated = [snapshots_0(indices1,:); snapshots_20(indices2,:)];

%%

figure;
scatter( previous_sample_points(:,1),  previous_sample_points(:,2), 'filled');

hold on;
%scatter( DOE_sample_points20(:,1),  DOE_sample_points20(:,2), 'filled', 'g');
%scatter( DOE_sample_points20(1:4,1),  DOE_sample_points20(1:4,2), 'filled', 'g');
scatter(  added_sample_Points(:,1),  added_sample_Points(:,2), 'filled', 'g');
xlim([0.02,0.3]);
ylim([0.02, 0.25]);
scatter(solution_points(2:end,1), solution_points(2:end,2),'c');
xlabel('CAxx coating bdown factor');
ylabel('CBxx coating bdown facor');
legend({'previous samples', 'added Samples', 'solution values'});
grid on;
%%

surrogates_20 = response_surface(DOE_sample_points_updated, snapshots_updated);
%}
%%
%root_folder_C = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_C\year_20';
calib_dir = fullfile(root_folder,'Calibration_data');
%meas_dir1 = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_nonlinear\Parameter_BARE_BBS\Measurement_results3';

files_name = 'BU_TimeStepped_01_20';
%meas_dict = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(meas_dir, files_name, py.list(calibration_data_type),  py.list(IDs), py.list(IDs_types));

calib_data_IDs = {IPs_IDs1, IDs_current_density};
calib_data_type = response_data_type(1:2);

%meas_data = convert_pydict2data(meas_dict,0);

calib_data_file_err_inc = strcat('data_with_error_',strjoin(response_data_type, '_'), '.xlsx');

%all_position_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(calib_dir, files_name, py.list(data_type),  py.list(IDs), py.list(IDs_types));


if ~isfile(fullfile(calib_dir, calib_data_file_err_inc))
    all_position_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(calib_dir, files_name, py.list(calib_data_type),  py.list({py.list(IPs_IDs), py.list(IDs_current_density)}), py.list(IDs_types));
    all_position_data = convert_pydict2data(all_position_dict,0);
    introduce_error_and_write_file( {IPs_IDs, IDs_current_density.'},all_position_data, calib_dir, calib_data_file_err_inc,1);
end
%model_out = output_from_surrogates([2.0, 3.0], surrogates, [17,6]);

calib_data_inc_error = data_from_tables(fullfile(calib_dir, calib_data_file_err_inc), calib_data_IDs,3);

%calib_data_inc_error = data_from_tables(fullfile(meas_dir, meas_data_file_err_inc), {MPs_IDs1, IDs_current_density},3);
%%
%plot_and_save(meas_dict, meas_data, 'adfa', meas_dir)
figure;

ax = gca;

[plot_data, min_out_pos1] = plot_objective_with_surrogates(ax, DOE_range2, surrogates_20, calib_data_inc_error, 'nmsq', calib_data_type, [length(IDs{1}), length(IDs{2})],[1.0,0.5], [0.0025,0.0025]);

sol_output_from_surrogate = output_from_surrogates(min_out_pos1, surrogates_20,[length(IDs{1}), length(IDs{2}),length(IDs{3})]); 
xlabel('CAxx coating bdown factor');
ylabel('CBxx coating bdown facor');
%min_out_pos = [0.1999  0.1390];

%%

%min_out_pos = [0.1999  0.1390];
%min_out_pos = [0.1950    0.1440];
%min_out_pos = [9.5600 7.5700]
testing_par_value = [0.2300    0.1600];

solution_folder = '';
for i = 1:length(parameters)
    solution_folder =   strcat(solution_folder, parameters{i},'_', num2str(testing_par_value(i), '%.4f'));
    if i~=length(parameters)
        solution_folder = strcat(solution_folder, '_');
    end
end
solution_colection_dir = fullfile(root_folder,'Solution_results');

solution_dir = fullfile(solution_colection_dir, solution_folder);

if ~isfolder(solution_dir)
    solution_dict = py.BEASY_IN_OUT2.get_response_data_for_IDs_and_input_parameters(py.list(source_parameters), py.list(parameters), testing_par_value, simulation_seed_folder, solution_colection_dir,  py.list(data_type), py.list(IDs),  py.list(IDs_types));
    solution_data = convert_pydict2data(solution_dict,1);
else

    solution_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(solution_dir, files_name, py.list(data_type),  py.list(IDs), py.list(IDs_types));
    solution_data = convert_pydict2data(solution_dict,0);
end

%plotting_response_data(meas_data_inc_error, solution_data)


%%

figure;

ax = gca;

difference_in_bar_chart(ax,calib_data_inc_error{1}(1:3:end,:), sol_output_from_surrogate{1}(1:3:end,:),{'simulation data from calibrated model','calibration data', 'difference'});

%set(ax,'XAxisLocation','bottom');


xlabel('Internal Points IDs')
%ylabel('Z electric field (micro-V/m)');
ylim([-1000 -950]);
%}

%%

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