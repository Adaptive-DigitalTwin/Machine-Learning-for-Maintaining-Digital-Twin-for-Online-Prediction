
calib_breakdown_factor = [0.0200,0.0200; 0.0800, 0.0600;  0.1399,0.1000; 0.1999,0.1399; 0.2599,0.1799; 0.3199 ,0.2199];
                       


%p_value_trend = [0.0200    0.0200;    0.0780    0.0606;    0.1389    0.1004;    0.2035    0.1315;    0.2609    0.1779];
p_value_trend = [0.0200    0.0200;    0.0780    0.0606;    0.1389    0.1004;    0.2035    0.1315];
solution_values = [0.02 0.02; 0.085 0.06; 0.145 0.105];



%%


ft = fittype( 'poly2' );

Fit_2nd_order = cell(1,2);
time_stepes = [0,5,10];
%time_stepes= 1:length(solution_values);

Fit_2nd_order{1,1} = fit( time_stepes.', solution_values(:,1), ft );
Fit_2nd_order{1,2} = fit( time_stepes.', solution_values(:,2), ft );


testing_data= [2*time_stepes(end)-time_stepes(end-1), 0.20, 0.13 ];

predicted_p_value = [Fit_2nd_order{1}(testing_data(1)), Fit_2nd_order{2}(testing_data(1))];

%%
figure;

plot(time_stepes, solution_values(:,1),'LineWidth', 4);

hold on;

plot([time_stepes(end),testing_data(1)] , [solution_values(end,1), predicted_p_value(1)], 'LineWidth', 4, 'LineStyle', '--', 'Color','b');

plot(time_stepes, solution_values(:,2),'LineWidth', 4);


plot([time_stepes(end),testing_data(1)] , [solution_values(end,2), predicted_p_value(2)], 'LineWidth', 4, 'LineStyle', '--', 'Color','r');


scatter(testing_data(1) , p_value_trend(end,1), 20,'filled' , 'g');

%scatter(testing_data(1) , p_value_trend(end,2), 20,'filled' , 'o');

%scatter(testing_data(1), testing_data(2),'filled','b')

xlabel('Years');

ylabel('Breakdown factor (p-value)');

xlim([0 20])
ylim([0 0.22])
legend({'Parameter after calibration and interpolation',  'Parameter with extrapolation'});

%%

    %%
%{
    p_value_trend = [1,1; 3.900 3.0300; 6.9500 5.0200; 10.1800 6.5800; 13.0500, 8.9000];

p_value_trend = p_value_trend/2880*57.576;

%mass_consumption_1A_rates = [2.9044, 7.1633, 
mass_consumption_B1_rates   = [4.3566, 10.727, 14.390, 17.159, 19.122];

figure;

%plot(1:length(p_value_trend), p_value_trend(:,1), 'r');
scatter(p_value_trend(:,2), mass_consumption_B1_rates, 'g', 'filled');

hold on;

scatter(p_value_trend(:,1), mass_consumption_B1_rates, 'r', 'filled');
hold on;
%plot(1:length(p_value_trend), mass_consumption_B1_rates, 'b');
%hold on;
xlabel('Coating breakdown (P-value)');

ylabel('anode consumption rate (kg/yr)');

legend({'CAxx material', 'CBxx matrial'});

%%

p_value_trend = [1,1; 3.900 3.0300; 6.9500 5.0200; 10.1800 6.5800; 13.0500, 8.9000];

p_value_trend = p_value_trend/2880*57.576;

%mass_consumption_1A_rates = [2.9044, 7.1633, 
mass_consumption_B1_rates   = [4.3566, 10.727, 14.390, 17.159, 19.122];

figure;

%scatter(p_value_trend(:,1), mass_consumption_B1_rates, 'b');
plot(p_value_trend(:,1), mass_consumption_B1_rates, 'b');

hold on;

plot(p_value_trend(:,2), mass_consumption_B1_rates, 'r' );

 %}


