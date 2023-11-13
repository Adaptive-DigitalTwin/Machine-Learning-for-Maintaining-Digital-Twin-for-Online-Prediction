
response_data_type = {'voltage', 'normal current density', 'Z_ELECTRIC_FIELD','anode related'};
%response_data_type = {'voltage', 'Z_CURRENT_DENSITY', 'anode related'};
%calibration_data_type = {'voltage'};
%calibration_data_type = {'voltage', 'current density', 'Z_ELECTRIC_FIELD'};

metric = 'nmsq';

IP_dir = "D:\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_5\Measurement_data";

meas_data_Internal_Points = csvread(fullfile(IP_dir, 'Internal_Points.csv'),1,1);

IPs_IDs = meas_data_Internal_Points(:,1);

IPs_IDs1 = IPs_IDs(1:2:end);

IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802, 30002, 23822,21212, 8437];
%IDs_current_density =[27791       27813       27839       27859];
%IDs_current_density = IPs_IDs1;
anode_related_IDs = 1:25:266;

IDs = {py.list(IPs_IDs1), py.list(IDs_current_density),py.list(IPs_IDs1), py.list(anode_related_IDs)};
IDs_mat_arr = {IPs_IDs1, IDs_current_density.', IPs_IDs1,anode_related_IDs.'};

%IDs_types = {'Internal Points','Mesh Points', 'Internal Points','CONSUMPTION_FACTOR','ANODE_CURRENT'};
%IDs_types = {'Internal Points','Mesh Points', 'Internal Points','ANODE_CURRENT'};
IDs_types = {'Internal Points','Mesh Points', 'Internal Points', 'MASS_LOSS_RATE'};
%
%IDs_types = {'Internal Points','Internal Points', 'MASS_LOSS_RATE'};
%py.list(1:2)

parameters_base = {'CA', 'CB'};

%%

years = [0, 5,10,15];

all_anode_IDs = 1:266;

root_folder1 = 'D:\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B';

average_cons_factor = average_anode_CONSUMPTION_FACTOR(root_folder1, years, all_anode_IDs);

%%
anode_IDs = 1:25:266;

res_folder = 'D:\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_10\Calibration_data';

anode_cons_rate = get_anode_data(res_folder, anode_IDs, 'CONSUMPTION_FACTOR');
%%
%DOE experiment for 2 varaibles using Central Composite Design
Central_composite_points = ccdesign(2, 'type', 'inscribed', 'center' , 1);

DOE_range1 = [0.005, 0.2; 0.005,  0.15];
DOE_range10 = [0.15, 0.35; 0.100,  0.25];
DOE_range15 = [0.15, 0.275; 0.1100,  0.19];

DOE_sample_points= cell(1, length(years)); snapshots_years = DOE_sample_points;

DOE_sample_points{1} = reverse_normalization(Central_composite_points, DOE_range1);
DOE_sample_points{2} = reverse_normalization(Central_composite_points, DOE_range1);
DOE_sample_points{3} = reverse_normalization(Central_composite_points, DOE_range10);
DOE_sample_points{4} = reverse_normalization(Central_composite_points, DOE_range15);
%%
for i = 1:length(years)
    
    source_parameters = {'BARE', 'BARE'};
    
    if years(i) <10
        parameters = strcat(parameters_base, '0', cellstr(string(years(i))));
    else
        parameters = strcat(parameters_base, cellstr(string(years(i))));
    end
    
    parameters_np_array1 = convert_arr_to_python_2d_list(DOE_sample_points{i});
    
    simulation_seed_folder = fullfile(root_folder1,strcat('year_',string(years(i))), 'Initial_files');

    collection_dir = fullfile(root_folder1,strcat('year_',string(years(i))), 'Simulation_results');

    snapshots_py = py.BEASY_IN_OUT2.snapshots_for_given_parameters_and_IDs(py.list(source_parameters), py.list(parameters), parameters_np_array1, py.list(IDs), py.list(response_data_type), simulation_seed_folder, collection_dir, py.list(IDs_types));

    snapshots{i} = double(snapshots_py);
end


%%

DOE_sample_points1_3d = [DOE_sample_points{1}, average_cons_factor(1)*ones(size(DOE_sample_points{1},1),1)];
DOE_sample_points5_3d = [DOE_sample_points{2}, average_cons_factor(2)*ones(size(DOE_sample_points{2},1),1)];
DOE_sample_points10_3d = [DOE_sample_points{3}, average_cons_factor(3)*ones(size(DOE_sample_points{3},1),1)];
DOE_sample_points15_3d = [DOE_sample_points{4}, average_cons_factor(4)*ones(size(DOE_sample_points{4},1),1)];

DOE_sample_points_collected = [DOE_sample_points1_3d(1:2:end,:); DOE_sample_points5_3d(2:2:end,:); DOE_sample_points10_3d(1:2:end,:); DOE_sample_points15_3d(2:2:end,:)];

DOE_sample_points_collected_cells = {DOE_sample_points1_3d(1:2:end,:), DOE_sample_points5_3d(2:2:end,:), DOE_sample_points10_3d(1:2:end,:), DOE_sample_points15_3d(2:2:end,:)};

snapshots_collected = [snapshots{1}(1:2:end,:); snapshots{2}(2:2:end,:); snapshots{3}(1:2:end,:); snapshots{4}(2:2:end,:)];

%%
figure;

%scatter3( DOE_sample_points3(:,1),  DOE_sample_points3(:,2),DOE_sample_points3(:,3) ,'filled', 'b');
%scatter3( DOE_sample_points_collected(:,1),  DOE_sample_points_collected(:,2),DOE_sample_points_collected(:,3) ,'filled', 'b');

sampl_idx = 1;
scatter3( DOE_sample_points_collected_cells{sampl_idx}(:,1),  DOE_sample_points_collected_cells{sampl_idx}(:,2),DOE_sample_points_collected_cells{sampl_idx}(:,3) ,'filled', 'b');
hold on;
sampl_idx = 2;
scatter3( DOE_sample_points_collected_cells{sampl_idx}(:,1),  DOE_sample_points_collected_cells{sampl_idx}(:,2),DOE_sample_points_collected_cells{sampl_idx}(:,3) ,'filled', 'g');

sampl_idx = 3;
scatter3( DOE_sample_points_collected_cells{sampl_idx}(:,1),  DOE_sample_points_collected_cells{sampl_idx}(:,2),DOE_sample_points_collected_cells{sampl_idx}(:,3)  ,'filled', 'o');

sampl_idx = 4;
scatter3( DOE_sample_points_collected_cells{sampl_idx}(:,1),  DOE_sample_points_collected_cells{sampl_idx}(:,2),DOE_sample_points_collected_cells{sampl_idx}(:,3)  ,'filled', 'c');


xlabel('CAxx coating bdown factor', 'Rotation', 30);
ylabel('CBxx coating bdown facor', 'Rotation', -30);
zlabel('average anode consumption factor');

%%
figure;

scatter( DOE_sample_points1(1:2:end,1),  DOE_sample_points1(:,2), 'filled');
hold on;
scatter( DOE_sample_points5(:,1),  DOE_sample_points5(:,2), 'filled', 'g');
%scatter( DOE_sample_points20(1:4,1),  DOE_sample_points20(1:4,2), 'filled', 'g');

scatter( DOE_sample_points10(:,1),  DOE_sample_points10(:,2), 'filled', 'c');

scatter( DOE_sample_points15(:,1),  DOE_sample_points15(:,2), 'filled', 'r');


%scatter(solution_points(:,1), solution_points(:,2), 'filled','c');
xlabel('CAxx coating bdown factor');
ylabel('CBxx coating bdown facor');
%legend({'Year 0 sampling points', 'Year 15 sampling points', 'testing sample points'});
grid on



%%

surrogates_3d = response_surface(DOE_sample_points_collected, snapshots_collected,2);
%%

calib_dir = fullfile(root_folder1,'year_20','Calibration_data');
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

%%
%if we know one of the value we can fix it
figure;

ax = gca;

DOE_range20 = [0.23 0.3; 0.17 0.25; 0.5,0.7];

[plot_data,min_value, min_out_pos20] = plot_objective_with_surrogates(ax, DOE_range20, surrogates_3d, calib_data_inc_error, 'nmsq', calib_data_type, cellfun('length',IDs_mat_arr),[1,0.5,0,0], [0.0025,0.0025, 0.0025]);

sol_output_from_surrogate = output_from_surrogates(min_out_pos20, surrogates_3d,cellfun('length',IDs_mat_arr)); 

xlabel('CAxx coating bdown factor');
ylabel('CBxx coating bdown facor');
zlabel('average anode consumption factor');

%%
%min_out_pos20 = [0.2575    0.2000    0.6925]
testing_par_value = min_out_pos20;

sol_output_from_surrogate = output_from_surrogates(testing_par_value, surrogates_3d,cellfun('length',IDs_mat_arr)); 

testing_par_value = min_out_pos20(1:2);
root_folder = 'D:\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_20';
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
figure;
ax = gca;
%difference_in_bar_chart(ax,simulation_data{1}(1:4:end,:), out_frm_nnet{1}(1:4:end,:),{'simuation predicted data','nnet model predicted data', 'difference'});

%legend_cell = strcat('Data from Simulation on year', strsplit(num2str(time_period)));
legend_cell = {'calibration data', 'solution output from surrogate', 'simulation output from solution model'};
data_ID = 1;
%response_in_bar_chart(ax, solution_data{data_ID}(1:3:end,:) , {test_output_from_surrogate{data_ID}(1:3:end,:),test_data20{data_ID}(1:3:end,:)}, legend_cell);
%response_in_bar_chart(ax, solution_data{data_ID}(1:3:end,:) , {sol_output_from_surrogate{data_ID}(1:3:end,:),solution_data{data_ID}(1:3:end,:)}, legend_cell);

%response_in_bar_chart(ax, solution_data{data_ID}(1:3:end,:) , {sol_output_from_surrogate{data_ID}(1:3:end,:),solution_data{data_ID}(1:3:end,:)}, legend_cell);

response_in_bar_chart(ax, solution_data{data_ID}(1:2:end,:) , {calib_data_inc_error{data_ID}(1:2:end,:), sol_output_from_surrogate{data_ID}(1:2:end,:),solution_data{data_ID}(1:2:end,:)}, legend_cell);
%response_in_bar_chart(ax, solution_data{data_ID} , {calib_data_inc_error{data_ID}, sol_output_from_surrogate{data_ID},solution_data{data_ID}}, legend_cell);


%response_in_bar_chart(ax, solution_data{data_ID} , {sol_output_from_surrogate{data_ID},solution_data{data_ID}}, legend_cell);

%response_in_bar_chart(ax, solution_data{data_ID} , {sol_output_from_surrogate{data_ID},solution_data{data_ID}}, legend_cell);

%set(ax,'XAxisLocation','bottom');

%xlabel('Internal Points IDs');
%xlabel('Mesh Points IDs');
%xlabel('Data Positional IDs', 'Rotation', 30);
%ylabel('consumption rate (kg/yr)')
%ylabel('Z electric field (micro-V/m)');
%ylabel('Normal current density (mAmp/Sq.m)');
%ylim([-1000 -950]);
%ylim([15 22]);
%ylabel('anode Current');
%ylim([1200 2000]);

%%


function average_CONSUMPTION_FACTOR  = average_anode_CONSUMPTION_FACTOR(root_folder_address, years_time, anode_IDs)


average_CONSUMPTION_FACTOR = zeros(1, length(years_time));

for i = 1:length(years_time)
    
    year_t = years_time(i);
    
    response_folder = fullfile(root_folder_address, strcat('year_', string(year_t)), 'Calibration_data');
    
    simulation_files = dir(response_folder);
    files_name = simulation_files(end-2).name;
    files_name = strsplit(files_name, '.');
    files_name = files_name{1};
    
    %anode_file = fullfile(response_folder,strcat(files_name, '.cp_anode_decay'));
    
    initial_anode_data = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(response_folder, files_name, py.list({'anode related'}),  py.list({py.list(anode_IDs)}), py.list({'CONSUMPTION_FACTOR'}));
     
    initial_anode_data = convert_pydict2data(initial_anode_data,0);
    
    initial_anode_data = initial_anode_data{1};
    
    average_CONSUMPTION_FACTOR(i) = mean(initial_anode_data(:,2));
    
end

end



function anode_data = get_anode_data(response_folder,  anode_IDs, data_type)

    simulation_files = dir(response_folder);
    files_name = simulation_files(end-2).name;
    files_name = strsplit(files_name, '.');
    files_name = files_name{1};
    
    anode_file = fullfile(response_folder,strcat(files_name, '.cp_anode_decay'));
    
    anode_data = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(response_folder, files_name, py.list({'anode related'}),  py.list({py.list(anode_IDs)}), py.list({data_type}));
     
    
    anode_data = convert_pydict2data(anode_data,0);
    
    anode_data = anode_data{1};
    
end

function de_normaised_data = reverse_normalization(normalised_data, value_ranges)

de_normaised_data = zeros(size(normalised_data));

for i = 1:size(normalised_data, 2)
    
    de_normaised_data(:,i) = value_ranges(i,1)+ diff(value_ranges(i,:))/2 * (normalised_data(:,i)-(-1));
    
end
end