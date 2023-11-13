

%response_data_type = {'voltage', 'normal current density', 'anode related'};
%response_data_type = {'voltage', 'normal current density', 'Z_ELECTRIC_FIELD','anode related'};
%response_data_type = {'voltage', 'Z_CURRENT_DENSITY', 'anode related'};
%calibration_data_type = {'voltage'};
%calibration_data_type = {'voltage', 'current density', 'Z_ELECTRIC_FIELD'};

metric = 'nmsq';

IP_dir = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_5\Measurement_data";

meas_data_Internal_Points = csvread(fullfile(IP_dir, 'Internal_Points.csv'),1,1);

IPs_IDs = meas_data_Internal_Points(:,1);

IPs_IDs1 = IPs_IDs(1:2:end);

IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802, 30002, 23822,21212, 8437];
%IDs_current_density =[27791       27813       27839       27859];
%IDs_current_density = IPs_IDs1;
anode_related_IDs = 1:25:266;

%IDs = {py.list(IPs_IDs1), py.list(IDs_current_density), py.list(anode_related_IDs)};
IDs = {py.list(IPs_IDs1), py.list(IDs_current_density),py.list(IPs_IDs1), py.list(anode_related_IDs)};
IDs_matarr = {IPs_IDs1, IDs_current_density,IPs_IDs1, anode_related_IDs};
%IDs_types = {'Internal Points','Mesh Points', 'Internal Points','MASS_LOSS_RATE'};
IDs_types = {'Internal Points','Mesh Points', 'Internal Points','ANODE_CURRENT'};


%py.list(1:2)
%%
source_parameters = {'BARE','BARE'};

parameters= {'CA15','CB15'};

%DOE_range1 = [4.0, 10.0; 3, 8.0]; 

%DOE_range1 = [0.17, 0.3; 0.12,  0.20];
DOE_range15 = [0.15, 0.275; 0.1100,  0.19];

%DOE experiment for 2 varaibles using Central Composite Design
Central_composite_points = ccdesign(2, 'type', 'inscribed', 'center' , 1);

DOE_sample_points15 = reverse_normalization(Central_composite_points, DOE_range15);
%DOE_sample_points2 = DOE_sample_points1(1:1.4:end,:);
%DOE_sample_points2 = reverse_normalization(Central_composite_points, DOE_range2);
%DOE_sample_points3 = reverse_normalization(Central_composite_points, DOE_range3);

%DOE_sample_points = [DOE_sample_points ;reverse_normalization(Central_composite_points, DOE_range2)];
root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_15';
simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%simulation_seed_folder  = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_linear\Parameter_BARE_Zone1\Initial_files1";

collection_dir = fullfile(root_folder, 'Simulation_results');


%%

parameters_np_array1 = convert_arr_to_python_2d_list(DOE_sample_points15);

%testing_par_value = DOE_sample_points1(1,:);

%test_dict = py.BEASY_IN_OUT2.get_response_data_for_IDs_and_input_parameters(py.list(source_parameters), py.list(parameters), testing_par_value, simulation_seed_folder, collection_dir,  py.list(response_data_type), py.list(IDs),  py.list(IDs_types));
%test_data = convert_pydict2data(test_dict,1);
snapshots_py = py.BEASY_IN_OUT2.snapshots_for_given_parameters_and_IDs(py.list(source_parameters), py.list(parameters), parameters_np_array1, py.list(IDs), py.list(response_data_type), simulation_seed_folder, collection_dir, py.list(IDs_types));

snapshots_15 = double(snapshots_py);

%%
%merging_snapshots
previous_sample_points = [DOE_sample_points1(4:2:end,:) ;DOE_sample_points1(end,:)];
%previous_sample_points = DOE_sample_points1(4:2:end,:);
%DOE_sample_points_updated = [DOE_sample_points1; DOE_sample_points20(5:end,:)];
added_sample_Points = [DOE_sample_points15(2:4,:); DOE_sample_points15(end,:)];

DOE_sample_points_updated = [previous_sample_points; added_sample_Points];
%DOE_sample_points_updated = [DOE_sample_points1; DOE_sample_points20(1:4,:)];

indices1 = find(ismember(DOE_sample_points1, previous_sample_points,'rows'));
indices2 = find(ismember(DOE_sample_points15, added_sample_Points,'rows'));

snapshots_updated = [snapshots_0(indices1,:); snapshots_15(indices2,:)];

%%
figure;
scatter( previous_sample_points(:,1),  previous_sample_points(:,2), 'filled');

%scatter( DOE_sample_points1(:,1),  DOE_sample_points1(:,2), 'filled');
hold on;
%scatter( DOE_sample_points20(:,1),  DOE_sample_points20(:,2), 'filled', 'g');
%scatter( DOE_sample_points20(1:4,1),  DOE_sample_points20(1:4,2), 'filled', 'g');
scatter(  added_sample_Points(:,1),  added_sample_Points(:,2), 'filled', 'g');

testing_par_value = [0.2300    0.1600];
%scatter( testing_par_value(1), testing_par_value(2), 'filled', 'c');

scatter(  min_out_pos20(1),  min_out_pos20(2), 'filled', 'c');

%scatter(solution_points(:,1), solution_points(:,2), 'filled','c');
xlabel('CAxx coating bdown factor');
ylabel('CBxx coating bdown facor');
legend({'Year 0 sampling points', 'Year 15 sampling points', 'testing sample points'});
grid on
%%
%surrogates_15 = response_surface(DOE_sample_points15, snapshots_15);
surrogates_15 = response_surface(DOE_sample_points_updated, snapshots_updated,2);
%surrogates_15_new = response_surface(DOE_sample_points15, snapshots_15);

%surrogates_02 = response_surface(DOE_sample_points2, snapshots);
%}

%%
%
parameters= {'CA15','CB15'};
root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_15';
files_name = 'BU_TimeStepped_01_15';

calib_dir = fullfile(root_folder,'Calibration_data');
simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%calib_dir1 = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_nonlinear\Parameter_BARE_BBS\Measurement_results3';

%calib_data_IDs = {IPs_IDs1, IDs_current_density};
%calib_data_type = response_data_type(1:2);
calib_data_IDs = IDs;
calib_data_type = response_data_type;


calib_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(calib_dir, files_name, py.list(calib_data_type),  py.list(calib_data_IDs), py.list(IDs_types));

calib_data_15 = convert_pydict2data(calib_dict,0);

%{
calib_data_file_err_inc = 'data_with_error.xlsx';

if ~isfile(fullfile(calib_dir, calib_data_file_err_inc))
    all_position_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(calib_dir, files_name, py.list(calib_data_type),  py.list(calib_data_IDs), py.list(IDs_types));
    all_position_data = convert_pydict2data(all_position_dict,0);
    introduce_error_and_write_file( {IPs_IDs1, IDs_current_density.'},all_position_data, calib_dir, calib_data_file_err_inc,1);
end
%model_out = output_from_surrogates([2.0, 3.0], surrogates, [17,6]);

%calib_data_inc_error = data_from_tables(fullfile(calib_dir, calib_data_file_err_inc), calib_data_IDs,3);
%}
%%


figure;

ax = gca;

DOE_range20 = [0.23 0.3; 0.17 0.25];

%[plot_data, min_out_pos1] = plot_objective_with_surrogates(ax, DOE_range15, surrogates_15, calib_data_inc_error, 'nmsq', calib_data_type, cellfun('length',IDs_matarr),[1,0.5,0.5,0.5], [0.005,0.005]);
[plot_data,~, min_out_pos1] = plot_objective_with_surrogates(ax, DOE_range15, surrogates_15, calib_data_15, 'nmsq', calib_data_type, cellfun('length',IDs_matarr),[1,0.5,0,0], [0.005,0.005]);

output_from_surrogate = output_from_surrogates(min_out_pos1, surrogates_15,cellfun('length',IDs_matarr)); 

xlabel('CAxx coating bdown factor');
ylabel('CBxx coating bdown facor');
%zlim([0 0.001]);

%%
testing_par_value = min_out_pos1;
%testing_par_value = [0.24 0.17];
sol_output_from_surrogate = output_from_surrogates(testing_par_value, surrogates_15,cellfun('length',IDs_matarr)); 

parameters= {'CA15','CB15'};
root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_15';
files_name = 'BU_TimeStepped_01_15';

simulation_seed_folder = fullfile(root_folder, 'Initial_files');

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
    solution_dict = py.BEASY_IN_OUT2.get_response_data_for_IDs_and_input_parameters(py.list(source_parameters), py.list(parameters), testing_par_value, simulation_seed_folder, solution_colection_dir,  py.list(response_data_type), py.list(IDs),  py.list(IDs_types));
    solution_data = convert_pydict2data(solution_dict,1);
else

    solution_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(solution_dir, files_name, py.list(response_data_type),  py.list(IDs), py.list(IDs_types));
    solution_data = convert_pydict2data(solution_dict,0);
end

%%
%}


figure;

ax = gca;

%difference_in_bar_chart(ax,solution_data{1}(1:3:end,:), calib_data_15{1}(1:3:end,:),{'simulation data from calibrated model','calibration data', 'difference'});
%difference_in_bar_chart(ax,solution_data{1}(1:3:end,:), output_from_surrogate{1}(1:3:end,:),{'simulation data from calibrated model','calibration data', 'difference'});
%difference_in_bar_chart(ax,solution_data{3}(1:25:end,:), output_from_surrogate{3}(1:25:end,:),{'simulation output data','surrogate output data', 'difference'});
%difference_in_bar_chart(ax,solution_data{1}, sol_output_from_surrogate{1},{'simulation output data','surrogate output data', 'difference'});
%difference_in_bar_chart(ax,solution_data{1}(1:3:end,:), sol_output_from_surrogate{1}(1:3:end,:),{'simulation output data','surrogate output data', 'difference'});
%difference_in_bar_chart(ax,solution_data{1}(1:3:end,:), sol_output_from_surrogate{1}(1:3:end,:),{'simulation output data','surrogate output data', 'difference'});


%difference_in_bar_chart(ax,solution_data{data_ID}, calib_data_15{data_ID},{'simulation data from calibrated model','calibration data', 'difference'});
legend_cell = {'calibration data', 'output from calibrated surrogate', 'simulation output of calibrated model'};
%legend_cell = { 'output from calibrated surrogate', 'simulation output of calibrated model'};

data_ID = 4;
%response_in_bar_chart(ax, solution_data{data_ID}(1:3:end,:) , {calib_data_15{data_ID}(1:3:end,:), sol_output_from_surrogate{data_ID}(1:3:end,:),solution_data{data_ID}(1:3:end,:)}, legend_cell);
response_in_bar_chart(ax, solution_data{data_ID} , {calib_data_15{data_ID}, sol_output_from_surrogate{data_ID}, solution_data{data_ID}}, legend_cell);
%response_in_bar_chart(ax, solution_data{data_ID} , { sol_output_from_surrogate{data_ID}, solution_data{data_ID}}, legend_cell);


%ylabel('anode Current');
%ylim([1200 2000]);

%set(ax,'XAxisLocation','bottom');

%xlabel('Internal Points IDs');
%xlabel('Mesh Points IDs');
%xlabel('anode IDs');
%ylabel('anode consumption rate (kg/yr)')
%ylabel('Z electric field (micro-V/m)');
%ylabel('Normal current density');
%ylim([-1010 -950]);
%ylim([14 22]);
%}
%%
%solution_points = [0.02 0.02; 0.085 0.06; 0.145 0.105];
figure;
%scatter( previous_sample_points(:,1),  previous_sample_points(:,2), 'filled');

scatter( DOE_sample_points15(:,1),  DOE_sample_points15(:,2), 'filled');
hold on;
%scatter( DOE_sample_points20(:,1),  DOE_sample_points20(:,2), 'filled', 'g');
%scatter( DOE_sample_points20(1:4,1),  DOE_sample_points20(1:4,2), 'filled', 'g');
%scatter(  added_sample_Points(:,1),  added_sample_Points(:,2), 'filled', 'g');
testing_par_value = [0.24 0.17];
scatter( testing_par_value(1), testing_par_value(2), 'filled', 'g');

%scatter(solution_points(:,1), solution_points(:,2), 'filled','c');
xlabel('CAxx coating bdown factor');
ylabel('CBxx coating bdown facor');

%%
figure;

ax = gca;

response_plot_3d(ax, calib_data_inc_error, calib_data_inc_error, 1, 'voltage','Internal Points', files_name, calib_dir)
    
hold on;

%response_plot_3d(ax, calib_data_inc_error, calib_data_inc_error, 2, 'current density','Mesh Points', files_name, calib_dir, 'g')


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