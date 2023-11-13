meas_dir = "D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE_Zone1\Measurement_results3";

meas_data_Internal_Points = csvread(fullfile(meas_dir, 'Internal_Points.csv'),1,1);

IPs_IDs = meas_data_Internal_Points(:,1);

%IPs_IDs1 = IPs_IDs(1:2:end);
%IPs_IDs1 = IPs_IDs(1:3:end);
IPs_IDs1 = IPs_IDs(1:4:end);

%MP_IDs_normal_current_density = [1225, 4270, 925, 7870, 3709];

IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802];

IDs = {py.list(IPs_IDs1), py.list(IDs_current_density)};
%IDs = {py.list(IPs_IDs1)};

IDs_mat_arr = {IPs_IDs1, IDs_current_density};
%IDs_mat_arr = {IPs_IDs1};

IDs_types = {'Internal Points', 'Mesh Points'};
%IDs_types = {'Internal Points'};

calib_data_type = {'voltage', 'normal current density'};
%calib_data_type = {'voltage'};

%%

source_parameters = {'BARE'};

parameters= {'BARE'};

%%
root_folder = 'D:\EXPERIMENT\DOE_nd_data_generation\Multilinear_pol_curves\Parameter_BARE';

simulation_seed_folder = fullfile(root_folder, 'Initial_files');
%simulation_seed_folder  = "C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\Model_updated_linear\Parameter_BARE_Zone1\Initial_files1";

collection_dir = fullfile(root_folder, 'Simulation_results');
%%
sample_points = [1.0, 1.2197, 1.3750, 1.4848, 1.7500,2.0152, 2.2803].';

parameters_np_array1 = convert_arr_to_python_2d_list(sample_points);

snapshots_py = py.BEASY_IN_OUT1.snapshots_for_given_parameters_and_IDs(py.list(parameters), parameters_np_array1, py.list(IDs), py.list(calib_data_type), simulation_seed_folder, collection_dir, py.list(IDs_types));

snapshots = double(snapshots_py);

%%

figure;

scatter(sample_points, snapshots(:,end), 'filled');

hold on;

plot(sample_points, snapshots(:,end), 'LineWidth' , 1.5);

xlabel('Material 1 related p-value');

ylabel('Normal Current Density (mA/m^2)');

%ylabel('Potential difference Ag/Agcl/Sea-water (mV)');


