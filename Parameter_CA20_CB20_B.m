

%%
source_parameters = {'BARE','BARE'};

parameters= {'CA20','CB20'};


x0 = [1.5, 2.5];
%x0 = [2.0, 3.33];
%tru_sol_x0 = [2.0, 3.33333, 7.0, 7.0, 0.66667];

%data_type = {'voltage', 'anode related'};
data_type = {'voltage', 'Z_ELECTRIC_FIELD'};
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

%MP_IDs_normal_current_density = [1225, 4270, 925, 7870, 3709];

%IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802];

%IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802, 30002, 23822,21212, 8437];

%anode_related_IDs = 1:5:100;
%anode_related_IDs = 1:50:266;

%IDs = {py.list(MPs_IDs1), py.list(anode_related_IDs)};

%IDs = meas_data_Internal_Points(:,1);

%IDs_mat_arr = {MPs_IDs1, anode_related_IDs};
IDs_mat_arr = {IPs_IDs1, IPs_IDs2};

%%
%DOE_range1 = [8, 12; 5.5, 8.5]; 

DOE_range1 = [0.2, 0.3; 0.15,  0.22];
%DOE_range1 = [0.3, 0.4; 0.22,  0.32];calib_data_IDs

%DOE_range2 = [1.4, 2.5; 2.6, 3.8];
%DOE_range3 = [1.8, 2.8; 2.2, 3.7];

DOE_range2 = zeros(size(DOE_range1));
for i = 1:size(DOE_range2,1)
    quan = quantile(DOE_range1(i,:),4);
    DOE_range2(i,:) = quan(2:3);
end
%}
%DOE experiment for 2 varaibles using Central Composite Design
Central_composite_points = ccdesign(2, 'type', 'inscribed', 'center' , 4);
Central_composite_points = Central_composite_points(1:end-2,:);

DOE_sample_points1 = reverse_normalization(Central_composite_points, DOE_range1);
%DOE_sample_points2 = reverse_normalization(Central_composite_points, DOE_range2);
%DOE_sample_points3 = reverse_normalization(Central_composite_points, DOE_range3);

%DOE_sample_points = [DOE_sample_points ;reverse_normalization(Central_composite_points, DOE_range2)];
root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_20';
simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%simulation_seed_folder  = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_linear\Parameter_BARE_Zone1\Initial_files1";

collection_dir = fullfile(root_folder, 'Simulation_results');

%IDs_types = {'Internal Points', 'MASS_LOSS_RATE'};
%IDs_types = {'Internal Points', 'Mesh Points'};
IDs_types = {'Internal Points', 'Internal Points'};
%%
parameters_np_array1 = convert_arr_to_python_2d_list(DOE_sample_points1);

snapshots_py = py.BEASY_IN_OUT2.snapshots_for_given_parameters_and_IDs(py.list(source_parameters),  py.list(parameters), parameters_np_array1, py.list(IDs), py.list(data_type), simulation_seed_folder, collection_dir, py.list(IDs_types));

snapshots = double(snapshots_py);

surrogates = response_surface(DOE_sample_points1, snapshots);
%}
%%
%for calibration data

%root_folder_C = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_C\year_20';

%meas_dict = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(meas_dir, files_name, py.list(calibration_data_type),  py.list(IDs), py.list(IDs_types));

root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_20';
files_name = 'BU_TimeStepped_01_20';

calib_dir = fullfile(root_folder,'Calibration_data');

%calib_dir1 = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_nonlinear\Parameter_BARE_BBS\Measurement_results3';

%calib_data_IDs = {IPs_IDs1, IDs_current_density};
%calib_data_type = response_data_type(1:2);
calib_data_IDs = IDs;
calib_data_type = response_data_type;

calib_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(calib_dir, files_name, py.list(calib_data_type),  py.list(calib_data_IDs), py.list(IDs_types));

calib_data_20 = convert_pydict2data(calib_dict,0);
%{
calib_data_file_err_inc = 'data_with_error.xlsx';

if ~isfile(fullfile(calib_dir, calib_data_file_err_inc))
    all_position_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(calib_dir, files_name, py.list(calib_data_type),  py.list(calib_data_IDs), py.list(IDs_types));
    all_position_data = convert_pydict2data(all_position_dict,0);
    introduce_error_and_write_file( {IPs_IDs1, IDs_current_density.'},all_position_data, calib_dir, calib_data_file_err_inc,1);
end
%model_out = output_from_surrogates([2.0, 3.0], surrogates, [17,6]);

calib_data_inc_error_20 = data_from_tables(fullfile(calib_dir, calib_data_file_err_inc), calib_data_IDs,3);
%}
%%
%plot_and_save(meas_dict, meas_data, 'adfa', meas_dir)
figure;

ax = gca;

DOE_range20 = [0.23 0.3; 0.17 0.25];

[plot_data,min_value, min_out_pos20b] = plot_objective_with_surrogates(ax, DOE_range20, surrogates_15, calib_data_20, 'nmsq', calib_data_type, cellfun('length',IDs_matarr),[1,0.5,0,0], [0.005,0.005]);

sol_output_from_surrogate = output_from_surrogates(min_out_pos20b, surrogates_15,cellfun('length',IDs_matarr)); 

xlabel('CAxx coating bdown factor');
ylabel('CBxx coating bdown facor');


%%

%min_out_pos = [0.1999  0.1390];
%min_out_pos = [0.1950    0.1440];
%min_out_pos = [9.5600 7.5700]
%testing_par_value = [0.2300    0.1600];

testing_par_value = min_out_pos20b;

sol_output_from_surrogate = output_from_surrogates(testing_par_value, surrogates_15,cellfun('length',IDs_matarr)); 


root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_20';
files_name = 'BU_TimeStepped_01_20';

parameters= {'CA20','CB20'};

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


%min_out_pos = [0.1999  0.1390];
%min_out_pos = [0.1950    0.1440];
%min_out_pos = [9.5600 7.5700]
%testing_par_value = [0.2300    0.1600];


test_output_from_surrogate = output_from_surrogates([testing_par_value, min_out_pos20(3)], surrogates_3d,cellfun('length',IDs_matarr)); 

%testing_par_value = min_out_pos20;
root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_20';
files_name = 'BU_TimeStepped_01_20';

parameters= {'CA20','CB20'};

simulation_seed_folder = fullfile(root_folder, 'Initial_files');
test_colection_dir = fullfile(root_folder,'Test_results');

test_folder = '';
for i = 1:length(parameters)
    test_folder =   strcat(test_folder, parameters{i},'_', num2str(testing_par_value(i), '%.4f'));
    if i~=length(parameters)
        test_folder = strcat(test_folder, '_');
    end
end


test_dir = fullfile(test_colection_dir, test_folder);

if ~isfolder(test_dir)
    test_dict = py.BEASY_IN_OUT2.get_response_data_for_IDs_and_input_parameters(py.list(source_parameters), py.list(parameters), testing_par_value, simulation_seed_folder, test_colection_dir,  py.list(response_data_type), py.list(IDs),  py.list(IDs_types));
    test_data20 = convert_pydict2data(test_dict,1);
else

    test_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(test_dir, files_name, py.list(response_data_type),  py.list(IDs), py.list(IDs_types));
    test_data20 = convert_pydict2data(test_dict,0);
end

%%
figure;

ax = gca;

difference_in_bar_chart(ax,calib_data_inc_error{2}, sol_output_from_surrogate{2},{'simulation output data','surrogate output data', 'difference'});


%set(ax,'XAxisLocation','bottom');

xlabel('Mesh Points IDs');
%xlabel('anode IDs');
%ylabel('consumption rate (kg/yr)')
ylabel('normal directional current density');
%ylim([-1100 -950]);
%}
%%
figure;
ax = gca;
%difference_in_bar_chart(ax,simulation_data{1}(1:4:end,:), out_frm_nnet{1}(1:4:end,:),{'simuation predicted data','nnet model predicted data', 'difference'});

%legend_cell = strcat('Data from Simulation on year', strsplit(num2str(time_period)));
legend_cell = {'output from surrogate', 'Simulation output @ year 15', 'simulation output @ year 20'};
data_ID = 1;
response_in_bar_chart(ax, solution_data{data_ID}(1:3:end,:) , {sol_output_from_surrogate{data_ID}(1:3:end,:), solution_data{data_ID}(1:3:end,:),test_data20{data_ID}(1:3:end,:)}, legend_cell);

%response_in_bar_chart(ax, solution_data{data_ID} , {sol_output_from_surrogate{data_ID}, solution_data{data_ID},test_data20{data_ID}}, legend_cell);


%set(ax,'XAxisLocation','bottom');

%xlabel('Internal Points IDs');
%xlabel('Mesh Points IDs');
%xlabel('anode IDs');
%ylabel('anode consumption rate (kg/yr)')
%ylabel('Z electric field (micro-V/m)');
%ylabel('Normal current density (mAmp/Sq.m)');
%ylim([-1000 -950]);
%ylim([14 22]);
%ylabel('anode Current');
%ylim([1200 2000]);

%%
figure;
ax = gca;

legend_cell = {'calibration data', 'output from calibrated surrogate', 'simulation output of calibrated model'};
%legend_cell = { 'output from calibrated surrogate', 'simulation output of calibrated model'};

data_ID = 4;
%response_in_bar_chart(ax, solution_data{data_ID}(1:3:end,:) , {calib_data_20{data_ID}(1:3:end,:), sol_output_from_surrogate{data_ID}(1:3:end,:),solution_data{data_ID}(1:3:end,:)}, legend_cell);
response_in_bar_chart(ax, solution_data{data_ID} , {calib_data_20{data_ID}, sol_output_from_surrogate{data_ID}, solution_data{data_ID}}, legend_cell);
%response_in_bar_chart(ax, solution_data{data_ID} , {sol_output_from_surrogate{data_ID}, solution_data{data_ID}}, legend_cell);



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