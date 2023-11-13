%p_value_trend = [3.900 3.0300; 6.9500 5.0200; 10.1800 6.5800; 12.2800, 8.6800];
%p_value_trend = [3.900 3.0300; 6.9500 5.0200; 10.1800 6.5800; 13.0500, 8.9000];
%calib_breakdown_factor = [57.576, 2.3030E+02, 4.0303E+02,5.7576E+02,7.4849E+02,9.2122E+02; 
    %57.576, 1.7273E+02,2.8788E+02, 4.0303E+02,5.1818E+02,6.3334E+02]/2.8800E+03;

calib_breakdown_factor =    [ 0.0200    0.0800    0.1399    0.1999    0.2599    0.3199;
    0.0200    0.0600    0.1000    0.1399    0.1799    0.2199];

%time_period = [ 5, 10, 15];

data_type = {'voltage', 'anode related'};
%data_type = {'voltage', 'normal current density'};
%calibration_data_type = {'voltage'};
%calibration_data_type = {'voltage', 'current density', 'Z_ELECTRIC_FIELD'};

metric = 'nmsq';

%root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step';
root_folder = 'D:\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_A';

IP_dir = "D:\DOE_nd_data_generation\TIme_step\year_5\Measurement_data";

meas_data_Internal_Points = csvread(fullfile(IP_dir, 'Internal_Points.csv'),1,1);

MPs_IDs = meas_data_Internal_Points(:,1);

MPs_IDs1 = MPs_IDs(1:4:end);

%IDs_current_density = [14390, 7400, 4060, 16000, 19860, 23802, 30002, 23822,21212, 8437];
%MPs_IDs1 = MPs_IDs;

anode_related_IDs = 1:25:266;

%IDs = {py.list(MPs_IDs1), py.list(IDs_current_density)};
%IDs = {py.list(num2cell(MPs_IDs1.')), py.list(num2cell(anode_related_IDs))};
IDs = {py.list(MPs_IDs1.'), py.list(anode_related_IDs)};

IDs_mat_arr = {MPs_IDs1, anode_related_IDs.'};
%IDs_mat_arr = {MPs_IDs1, IDs_current_density.'};

IDs_types = {'Internal Points', 'MASS_LOSS_RATE'};

%%

%time_period = [0, 5, 10];
time_period = [0, 5, 10, 15,20];
snapshots1 = zeros(length(time_period), length(IDs{1})+length(IDs{2}));

for i = 1:length(time_period)

    year_t = time_period(i);


    %}
    response_folder = fullfile(root_folder,strcat('year_', string(year_t)), 'Calibration_data');
    
    %response_folder = fullfile(collection_dir, strcat(parameters{1},'_', num2str(p_value_trend(i,1), '%.4f'),'_',parameters{2},'_', num2str(p_value_trend(i,2),'%.4f')));
    
    simulation_files = dir(response_folder);
    files_name = simulation_files(end-3).name;
    files_name = strsplit(files_name, '.');
    files_name = files_name{1};
    

    response_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(response_folder, files_name, py.list(data_type),  py.list(IDs), py.list(IDs_types));

    response_data = convert_pydict2data(response_dict,0);
    %}
    %{
    response_data_file_err_inc = strcat('data_with_error_',strjoin(data_type, '_'), '.xlsx');

    if ~isfile(fullfile(response_folder, response_data_file_err_inc))
        response_dict_no_error = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(response_folder, files_name, py.list(data_type),  py.list(IDs), py.list(IDs_types));
        response_data_no_error = convert_pydict2data(response_dict_no_error,0);
        response_data = introduce_error_and_write_file(response_data_no_error, response_folder, response_data_file_err_inc, 3);
    else
        response_data = data_from_tables(fullfile(response_folder, response_data_file_err_inc), {IDs_surface_potential, IDs_current_density},3);
    end
    %}
    data_count = 0;
    for j = 1:length(response_data)
        
        snapshots1(i, data_count+1:data_count + length(response_data{j})) = response_data{j}(:,2);
        
        data_count = data_count+length(response_data{j});
        
    end
    %}
end
%%
figure;
scatter( calib_breakdown_factor(1,1:5).',snapshots1(:,14), 'filled', 'g');

hold on;

scatter( calib_breakdown_factor(2,1:5).',snapshots1(:,14), 'filled', 'b');

legend( {'CAxx related data','CBxx related data'});

xlabel('Coating b-down factor (p-value)');
ylabel('anode consumption rate (kg/yr)');

box

%%
%surrogates_time = response_surface(time_period.', snapshots1);
%surrogates_time2 = response_surface(time_period.', snapshots1);
%surrogates_time4 = response_surface(time_period.', snapshots1);
surrogates_time25 = response_surface(time_period.', snapshots1);


%%
%net = fitnet([10,8,5]);
net4 = fitnet([10,8,5], 'trainbr' );

%[net, tr]= train(net, time_period, snapshots1.');
[net4, tr]= train(net4, time_period, snapshots1.');

%%
%year_t = 15;
%out_frm_surr = output_from_surrogates(year_t, surrogates_time, [length(IDs_mat_arr{1}),length(IDs_mat_arr{2})]);
%out_frm_time_surr = output_from_surrogates(year_t, surrogates_time3, [length(IDs_mat_arr{1}),length(IDs_mat_arr{2})]);
out_frm_time_surr20 = output_from_surrogates(20, surrogates_time20, [length(IDs_mat_arr{1}),length(IDs_mat_arr{2})]);
out_frm_time_surr15 = output_from_surrogates(15, surrogates_time15, [length(IDs_mat_arr{1}),length(IDs_mat_arr{2})]);
out_frm_time_surr25 = output_from_surrogates(25, surrogates_time25, [length(IDs_mat_arr{1}),length(IDs_mat_arr{2})]);
%out_frm_nnet4 = output_from_nnet(year_t, net4, [length(IDs_mat_arr{1}),length(IDs_mat_arr{2})]);

%solution_dir = fullfile(root_folder,strcat('year_', string(year_t)), 'Solution_results');

%introduce_error_and_write_file(IDs_mat_arr , out_frm_time_surr, solution_dir, strcat('predicted_from_time_surrogate',strjoin(data_type, '_'), '.xlsx'), 0);
%out_frm_nnet = output_from_nnet(year_t, net2, [length(IDs_mat_arr{1}),length(IDs_mat_arr{2})]);
%out_frm_nnet2 = output_from_surrogates(year_t, net2, [length(IDs_mat_arr{1}),0]);
%%
year_t = 25;
simulation_folder = fullfile(root_folder,strcat('year_', string(year_t)), 'Calibration_data');
    
simulation_files = dir(simulation_folder);
files_name = simulation_files(end-2).name;
files_name = strsplit(files_name, '.');
files_name = files_name{1};
   
simulation_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(simulation_folder, files_name, py.list(data_type),  py.list(IDs), py.list(IDs_types));

simulation_data_25 = convert_pydict2data(simulation_dict,0);
%{
simulation_data_file_err_inc = 'data_with_error.xlsx';

 if ~isfile(fullfile(simulation_folder, simulation_data_file_err_inc))
        simulation_dict_no_error = py.BEASY_IN_OUT1.get_output_data_for_IDs_from_simulation_folder(simulation_folder, files_name, py.list(data_type),  py.list(IDs), py.list(IDs_types));
        simulation_data_no_error = convert_pydict2data(simulation_dict_no_error,0);
        simulation_data = introduce_error_and_write_file(response_data_no_error, simulation_folder, simulation_data_file_err_inc, 3);
 else
        simulation_data = data_from_tables(fullfile(simulation_folder, simulation_data_file_err_inc), {IDs_surface_potential, IDs_current_density},3);
 end
%}
%%
figure;
ax = gca;
%difference_in_bar_chart(ax,simulation_data{1}(1:4:end,:), out_frm_nnet{1}(1:4:end,:),{'simuation predicted data','nnet model predicted data', 'difference'});
difference_in_bar_chart(ax,simulation_data{1}(1:4:end,:), out_frm_time_surr{1}(1:4:end,:),{'simuation predicted data','surrogate model predicted data', 'difference'});
%response_differences_3d_plot(ax,simulation_data, out_frm_nnet,simulation_data, 1, 'voltage', 'Mesh Points', files_name, simulation_folder);
%response_differences_3d_plot(ax,simulation_data, out_frm_surr3, simulation_data, 1, 'voltage', 'Mesh Points', files_name, simulation_folder);
%meas_data, model_output, data_idx, data_type,Ids_type, files_name, files_dir)
%%
figure;
ax = gca;
difference_in_bar_chart(ax,simulation_data_25{2}, out_frm_time_surr25{2},{'simuation predicted data','data-fit model predicted data', 'difference'});
%difference_in_bar_chart(ax,simulation_data{1}, out_frm_nnet4{1},{'simuation predicted data','surrogate model predicted data', 'difference'});

%response_differences_3d_plot(ax,simulation_data, out_frm_nnet, 1, 'voltage', 'Mesh Points', files_name, simulation_folder);
%ylim([-990 -955]);
%%{
set(ax,'XAxisLocation','bottom');

ylabel('mass loss per year')
xlabel('anode IDs')
%}
%%
figure;
ax = gca;
%difference_in_bar_chart(ax,simulation_data{1}(1:4:end,:), out_frm_nnet{1}(1:4:end,:),{'simuation predicted data','nnet model predicted data', 'difference'});
%difference_in_bar_chart(ax,simulation_data{1}(1:4:end,:), out_frm_surr3{1}(1:4:end,:),{'simuation predicted data','surrogate model predicted data', 'difference'});
%response_plot_3d(ax,simulation_data, simulation_data, 1, 'voltage', 'Mesh Points', files_name, simulation_folder);
response_plot_3d(ax,simulation_data, out_frm_surr3, 1, 'voltage', 'Mesh Points', files_name, simulation_folder);
%
xlim([-30 30])
ylim([-30 30])
caxis([-1050 -550]);
%%
snapshots2 = snapshots1(:,1:end-10).';
figure;
ax = gca;
%difference_in_bar_chart(ax,simulation_data{1}(1:4:end,:), out_frm_nnet{1}(1:4:end,:),{'simuation predicted data','nnet model predicted data', 'difference'});

%legend_cell = strcat('Data from Simulation on year', strsplit(num2str(time_period)));
legend_cell = strcat('Calibration data on year', strsplit(num2str(time_period)));
response_in_bar_chart(ax, simulation_data{1}(1:4:end,:) , {snapshots2(1:4:end,1), snapshots2(1:4:end,2),snapshots2(1:4:end,3),snapshots2(1:4:end,4)}, legend_cell);
