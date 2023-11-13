
root_folder_1 = 'D:\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B';

anode_1_closest_MP_25 = [27775       27791       27803       27813       27839       27847       27859       27864];

anode_1_closest_MP_15 = [27791       27813       27839       27859];

anode_4_closest_MP_15 = [29110       29123       29145       29163];

anode_5_closest_MP_15 = [30012       30034       30127       30155];

time_period = [0, 5, 10, 15, 20];

%response_data_type = {'voltage', 'normal current density', 'anode related'};
response_data_type = {'normal current density', 'anode related','anode related'};
IDs_types = {'Mesh Points', 'MASS_LOSS_RATE','ANODE_CURRENT'};

%response_data_type = {'normal current density', 'anode related'};

%IDs_types = {'Mesh Points', 'Mesh Points', 'MASS_LOSS_RATE'};

IDs = { py.list(anode_5_closest_MP_15), py.list([4,5]), py.list([4,5])};

snapshots1 = zeros(length(time_period), length(IDs{1})+length(IDs{2})+length(IDs{3}));

%{
anodic_current1_1 = [414.437,1020, 1368.89, 1632.3, 1819.03];

anodic_current_75_4a = [1971.01];
mass_consumption_rate_4a = [20.719];

anodic_current_75_4b = [2369];
oxidizing_current_density = [158.26, 400.886,601.01,813.413,1090.25];

oxidizing_current_density_75_4_a = [1095.12];
oxidizing_current_density_75_4_b = [1296.37];
%}
%%
for i = 1:length(time_period)

    year_t = time_period(i);

    response_folder = fullfile(root_folder_1,strcat('year_', string(year_t)), 'Calibration_data');
    
    %response_folder = fullfile(collection_dir, strcat(parameters{1},'_', num2str(p_value_trend(i,1), '%.4f'),'_',parameters{2},'_', num2str(p_value_trend(i,2),'%.4f')));
    
    %simulation_files = dir(response_folder);
    %files_name = simulation_files(end-3).name;
    %files_name = strsplit(files_name, '.');
    %files_name = files_name{1};
    files_name = strcat('BU_TimeStepped_01_', string(year_t));

    response_dict = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(response_folder, files_name, py.list(response_data_type),  py.list(IDs), py.list(IDs_types));

    response_data = convert_pydict2data(response_dict,0);

    data_count = 0;
    for j = 1:length(response_data)
        
        snapshots1(i, data_count+1:data_count + length(response_data{j})) = response_data{j}(:,2);
        
        data_count = data_count+length(response_data{j});
        
    end
    %}
end
%%

ft = fittype( 'poly2' );

%snapshots1(1:end,2) = oxidizing_current_density.';
%snapshots1(1:end,1) = anodic_current.';
%smooth_data = smoothdata(snapshots1(1:end,1));

Fit_2nd_order = fit(snapshots1(1:end-1,end),snapshots1(1:end-1,end-2), ft );
%Fit_2nd_order = fit(snapshots1(1:end-1,2), snapshots1(1:end-1,end-1), ft );

testing_data = [snapshots1(end,end),snapshots1(end,end-2)];

fit_predicted_sol = Fit_2nd_order(testing_data(1));

testing_data2 = [2369.2 24.905];

fit_predicted_sol2 = Fit_2nd_order(testing_data2(1));

testing_data3_3854 = [2231 23.458];

%surrogate_resp2anode = response_surface(snapshots3(1:end-2,1), snapshots(1:end-2,end-1));
%%
snapshots3 = zeros(6, size(snapshots1,2));
index = 1;
for i = 1:8
    if isequal(i,2)
        snapshots3(i,:) = snapshots(1, :);
    elseif isequal(i,4)
        snapshots3(i,:) = snapshots(end, :);
    else
        snapshots3(i,:) = snapshots1(index, :);
        index= index+1;
    end
end

surrogate_resp2anode = response_surface(snapshots3(1:end-2,1), snapshots3(1:end-2,end-1));

ouput_from_pred = output_from_surrogates( snapshots3(end-1,1),surrogate_resp2anode, [1,0]);


%%
figure;

plot(snapshots1(1:end-1,end),snapshots1(1:end-1,end-2),'LineWidth', 4);

hold on;
plot([snapshots1(end-1,2),testing_data(1)] , [snapshots1(end-1,end-1), fit_predicted_sol], 'LineWidth', 4, 'LineStyle', '--');


scatter(testing_data(1) , fit_predicted_sol, 20,'filled' , 'r');
scatter(testing_data(1), testing_data(2),'filled','b')

xlabel('oxidising current density at a Mesh Point');

ylabel('anode consumption rate');

legend({'Data from simulation', 'Prediction with data-fitting model'});


%%

solution_values = [0.02 0.02; 0.085 0.06; 0.145 0.105];

ft = fittype( 'poly2' );

Fit_2nd_order = cell(1,2);
time_stepes = [0,5,10];
%time_stepes= 1:length(solution_values);

Fit_2nd_order{1,1} = fit( time_stepes.', solution_values(:,1), ft );
Fit_2nd_order{1,2} = fit( time_stepes.', solution_values(:,2), ft );

               
testing_data= [2*time_stepes(end)-time_stepes(end-1), 0.20, 0.13 ];

predicted_p_value = [Fit_2nd_order{1}(testing_data(1)), Fit_2nd_order{2}(testing_data(1))];
%%

p_values_0_14 = zeros(15,2);

anode1_2_consumtions_rate = zeros(15,2);

anode_left_year_wise = zeros(15,2);
years = 0:14;
for i = 1:15
    year = years(i);
    p_val = [Fit_2nd_order{1}(year), Fit_2nd_order{2}(year)];
    
    surrogate_output = output_from_surrogates(p_val, surrogates_0, [length(IDs{1}), length(IDs{2}),length(IDs{3})]);
    
    anode1_2_consumtions_rate(i,:) = surrogate_output{3};
    
    total_anode_consumed = [sum(anode1_2_consumtions_rate(:,1)), sum(anode1_2_consumtions_rate(:,2))];
    
    anode_left_year_wise(i,:) = [356 356]-total_anode_consumed;
end
    

%%

%%
figure;

plot(years(1:10), anode1_2_consumtions_rate(1:10,1),'LineWidth', 2);

hold on;

ylabel('anode consumption rate');
xlabel('Years');

plot(years(1:10), anode1_2_consumtions_rate(1:10,2),'LineWidth', 2);

plot(years(10:end), anode1_2_consumtions_rate(10:end,1),'LineWidth', 2, 'color' ,'b', 'LineStyle', '--');

plot(years(10:end), anode1_2_consumtions_rate(10:end,2),'LineWidth', 2, 'color' ,'r', 'LineStyle', '--');


legend({'anode 1 realted','anode 2 related'});

%%

%anode_left_year_wise = zeros(15,2);

figure;

plot(years(1:10), anode_left_year_wise(1:10,1),'LineWidth', 2);

hold on;

ylabel('anode mass left');
xlabel('Years');

plot(years(1:10), anode_left_year_wise(1:10,2),'LineWidth', 2);

plot(years(10:end), anode_left_year_wise(10:end,1),'LineWidth', 2, 'color' ,'b', 'LineStyle', '--');

plot(years(10:end), anode_left_year_wise(10:end,2),'LineWidth', 2, 'color' ,'r', 'LineStyle', '--');


legend({'anode 1 realted','anode 2 related'});


