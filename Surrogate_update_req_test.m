response_data_type = {'voltage', 'normal current density'};

metric = 'nmsq';

IP_dir = "D:\DOE_nd_data_generation\TIme_step\year_5\Measurement_data";

meas_data_Internal_Points = csvread(fullfile(IP_dir, 'Internal_Points.csv'),1,1);

IPs_IDs = meas_data_Internal_Points(:,1);

IPs_IDs1 = IPs_IDs(1:2:end);

IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802, 30002, 23822,21212, 8437];


IDs = {py.list(IPs_IDs1), py.list(IDs_current_density),py.list(IPs_IDs1), py.list(anode_related_IDs)};
IDs_matarr = {IPs_IDs1, IDs_current_density,IPs_IDs1, anode_related_IDs};

%IDs_types = {'Internal Points','Mesh Points', 'Internal Points','CONSUMPTION_FACTOR','ANODE_CURRENT'};
%IDs_types = {'Internal Points','Mesh Points', 'Internal Points','ANODE_CURRENT'};
IDs_types = {'Internal Points','Mesh Points', 'Internal Points', 'MASS_LOSS_RATE'};
%
%IDs_types = {'Internal Points','Internal Points', 'MASS_LOSS_RATE'};
%py.list(1:2)
%%
source_parameters = {'BARE','BARE'};

parameters= {'CA00','CB00'};

%DOE_range1 = [4.0, 10.0; 3, 8.0]; 
DOE_range1 = [0.005, 0.2; 0.005,  0.15];

%DOE experiment for 2 varaibles using Central Composite Design
Central_composite_points = ccdesign(2, 'type', 'inscribed', 'center' , 1);

DOE_sample_points1 = reverse_normalization(Central_composite_points, DOE_range1);
%DOE_sample_points2 = DOE_sample_points1(1:1.4:end,:);
%DOE_sample_points2 = reverse_normalization(Central_composite_points, DOE_range2);
%DOE_sample_points3 = reverse_normalization(Central_composite_points, DOE_range3);

%DOE_sample_points = [DOE_sample_points ;reverse_normalization(Central_composite_points, DOE_range2)];
root_folder = 'D:\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_0';
simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%simulation_seed_folder  = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_linear\Parameter_BARE_Zone1\Initial_files1";

collection_dir = fullfile(root_folder, 'Simulation_results');


%%

parameters_np_array1 = convert_arr_to_python_2d_list(DOE_sample_points1);

%testing_par_value = DOE_sample_points1(1,:);

%test_dict = py.BEASY_IN_OUT2.get_response_data_for_IDs_and_input_parameters(py.list(source_parameters), py.list(parameters), testing_par_value, simulation_seed_folder, collection_dir,  py.list(response_data_type), py.list(IDs),  py.list(IDs_types));
%test_data = convert_pydict2data(test_dict,1);
snapshots_py = py.BEASY_IN_OUT2.snapshots_for_given_parameters_and_IDs(py.list(source_parameters), py.list(parameters), parameters_np_array1, py.list(IDs), py.list(response_data_type), simulation_seed_folder, collection_dir, py.list(IDs_types));

snapshots_0 = double(snapshots_py);
%%
%merging_snapshots

%%
surrogates_0 = response_surface(DOE_sample_points1, snapshots_0,2);
%}

%%
testing_par_values = [0.02, 0.02; 0.0800, 0.0600; 0.1716, 0.1188];

years = [0, 5, 10];

k=2;

parameters= {'CA05','CB05'};

testing_par_value = testing_par_values(k, :);

test_output_from_surrogate = output_from_surrogates(testing_par_value, surrogates_0,cellfun('length',IDs_matarr)); 

test_folder = '';
for i = 1:length(parameters)
    test_folder =   strcat(test_folder, parameters{i},'_', num2str(testing_par_value(i), '%.4f'));
    if i~=length(parameters)
        test_folder = strcat(test_folder, '_');
    end
end

root_folder = strcat('D:\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B\year_', string(years(k)));

collection_dir = fullfile(root_folder, 'Simulation_results');

test_dir = fullfile(collection_dir, test_folder);
files_name = strcat("BU_TimeStepped_01_", string(years(k)));

test_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(test_dir, files_name, py.list(response_data_type),  py.list(IDs), py.list(IDs_types));
test_data = convert_pydict2data(test_dict,0);

normalised_mean_sq_diff(test_output_from_surrogate, test_data, response_data_type, [0.6 0.3, 0, 0])

%%

figure;

ax = gca;

data_count = 1;
if isequal(data_count,1)
    difference_in_bar_chart(ax,test_data{1}(1:3:end,:), test_output_from_surrogate{1}(1:3:end,:),{'simulation output data','Data predicted with Surrogate'});
elseif isequal(data_count,2)
    difference_in_bar_chart(ax,test_data{2}(1:2:end,:), test_output_from_surrogate{2}(1:2:end,:),{'simulation output data','Data predicted with Surrogate'});
    ylabel(ax, 'Normal current density (mA/m^2)');
end
    
%difference_in_bar_chart(ax,test_data{1}, test_output_from_surrogate{1},{'simulation output data','poly-fit model output data', 'difference'});

%set(ax,'XAxisLocation','bottom');

%ylim([ - 1090 -1040])
%ylim([ - 1050 -1000])
%xlabel('Internal Points IDs');
%xlabel('anode IDs');
%ylabel('consumption rate (kg/yr)')


%%

figure;
%scatter( previous_sample_points(:,1),  previous_sample_points(:,2), 'filled');

scatter( DOE_sample_points1(:,1),  DOE_sample_points1(:,2), 'filled');
hold on;
%scatter( DOE_sample_points20(:,1),  DOE_sample_points20(:,2), 'filled', 'g');
%scatter( DOE_sample_points20(1:4,1),  DOE_sample_points20(1:4,2), 'filled', 'g');
%scatter(  added_sample_Points(:,1),  added_sample_Points(:,2), 'filled', 'g');
scatter( testing_par_values(:,1), testing_par_values(:,2), 'filled', 'g');

%scatter(solution_points(:,1), solution_points(:,2), 'filled','c');
xlabel('CAxx coating bdown factor');
ylabel('CBxx coating bdown facor');
grid on;