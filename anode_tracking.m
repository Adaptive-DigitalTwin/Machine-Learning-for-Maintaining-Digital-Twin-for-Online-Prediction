

data_type = {'anode related'};
%calibration_data_type = {'voltage'};
%calibration_data_type = {'voltage', 'current density', 'Z_ELECTRIC_FIELD'};

metric = 'nmsq';

anode_related_IDs = 1:25:266;

IDs = {py.list(anode_related_IDs)};

IDs_mat_arr = {anode_related_IDs};


IDs_types = {'MASS_LOSS_RATE'};

%root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B';
root_folder = 'D:\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B';

%%

time_period = [0, 5, 10, 15];
anode_related_snapshots = zeros(length(time_period), length(IDs{1}));

for i = 1:length(time_period)

    year_t = time_period(i);

    response_folder = fullfile(root_folder,strcat('year_', string(year_t)), 'Calibration_data');
    
    %response_folder = fullfile(collection_dir, strcat(parameters{1},'_', num2str(p_value_trend(i,1), '%.4f'),'_',parameters{2},'_', num2str(p_value_trend(i,2),'%.4f')));
    
    simulation_files = dir(response_folder);
    files_name = simulation_files(end-2).name;
    files_name = strsplit(files_name, '.');
    files_name = files_name{1};
    

    response_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(response_folder, files_name, py.list(data_type),  py.list(IDs), py.list(IDs_types));

    response_data = convert_pydict2data(response_dict,0);

    data_count = 0;
    for j = 1:length(response_data)
        
        anode_related_snapshots(i, data_count+1:data_count + length(response_data{j})) = response_data{j}(:,2);
        
        data_count = data_count+length(response_data{j});
        
    end
    %}
end
%%

%anode_consumption_predictor = response_surface(time_period.', anode_rate_snapshots);

%temp_data = output_from_surrogates(5, anode_consumption_predictor, [length(anode_related_IDs)]);

anode_lost1 = cumulative_anode_consumption(anode_related_snapshots, time_period, [0,19], anode_related_IDs, true);
anode_lost2 = cumulative_anode_consumption(anode_related_snapshots, time_period, [0,19], anode_related_IDs, false);

anode_lost9 = cumulative_anode_consumption(anode_related_snapshots, time_period, [9,9], anode_related_IDs, true);

%[temp_data{1} anode_rate_snapshots(2,:).']
%%

root_folder1 = 'D:\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B';

initial_anode_year_0 = get_initial_anode_mass(0, root_folder1, anode_related_IDs);


%initial_anode_year_20 = get_initial_anode_mass(20, root_folder1, anode_related_IDs);

%[anode_lost2 initial_anode_year_0(:,2)-initial_anode_year_20(:,2)]

%%

figure;

bar(anode_related_snapshots.')

legend(strcat('Year','__', cellstr(strsplit((num2str([0,5,10,15]))))));

xlabel('anode IDs')
ylabel('mass (kg) loss per year')

%%

yearly_anode_status = zeros(length(anode_related_IDs), 25);

pre_yearly_anode_loss = zeros(length(anode_related_IDs), 25);

initial_anode_year_0 = get_initial_anode_mass(0, root_folder, anode_related_IDs);

for i = 1:25
    
    pre_yearly_anode_loss(:,i) = cumulative_anode_consumption(anode_related_snapshots, time_period, [i-1, i-1], anode_related_IDs, false);
    
    yearly_anode_status(:,i) = initial_anode_year_0(:,2) - sum(pre_yearly_anode_loss(:,1:i),2); 

end


figure;
hold on;
for i = 1:length(anode_related_IDs(1:2:end))
    plot(1:25, yearly_anode_status(i,:), 'LineWidth', 2)
end
legend(strcat('IDs','__', cellstr(strsplit((num2str(anode_related_IDs(1:2:end)))))));

ylim([0,350])

xlabel('time (Years');
ylabel('Anode mass (kg) present');
    %%
function initial_anode_data = get_initial_anode_mass(year_t, root_folder, IDs)

    response_folder = fullfile(root_folder,strcat('year_', string(year_t)), 'Calibration_data');
    
    simulation_files = dir(response_folder);
    files_name = simulation_files(end-2).name;
    files_name = strsplit(files_name, '.');
    files_name = files_name{1};
    
    anode_file = fullfile(response_folder,strcat(files_name, '.cp_anode_decay'));
    
    initial_anode_data = py.BEASY_IN_OUT2.extract_anode_information_from_file(anode_file, py.list(IDs), py.list({'MASS_NOW'}));
    
    initial_anode_data = convert_pydict2data(initial_anode_data,0);
    
    initial_anode_data = initial_anode_data{1};
    
end


function anode_data = get_anode_data(response_folder,  IDs, data_type)

    simulation_files = dir(response_folder);
    files_name = simulation_files(end-2).name;
    files_name = strsplit(files_name, '.');
    files_name = files_name{1};
    
    anode_file = fullfile(response_folder,strcat(files_name, '.cp_anode_decay'));
    
    anode_data = py.BEASY_IN_OUT2.extract_anode_information_from_file(anode_file, py.list(IDs), py.list({data_type}));
    
    anode_data = convert_pydict2data(anode_data,0);
    
    anode_data = anode_data{1};
    
end