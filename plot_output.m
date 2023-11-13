
meas_table = readtable(fullfile(meas_dir, 'Internal_Points.csv'));

output_table = readtable(fullfile(meas_dir, 'Internal_Points.csv'));
%output_table, meas_table] = get_tables_from_sol_dir(parameters, par_val, 'Multi-linear');

%plot_with_id1(meas_table, output_table)
comparative_plot(meas_table, output_table)

function ax = plot_with_id1(tableA, tableB)
    
    ax = gca;
    data1 = tableA{:,[2,6]};
    
    plot(data1(:,1), data1(:,2), 'DisplayName', 'Measurement data');
    xlabel('Position ID');
    ylabel('Potential value (mV)');
    
    
    hold on
    
    data2 = tableB{:,[2,6]};
    
    plot(data2(:,1), data2(:,2),'DisplayName', 'Model Output');
    
    hold off
    legend
 
end

function [simu_output_table, meas_table] = get_tables_from_sol_dir(Parameters, par_vals, polar_curve_type)

if isequal(polar_curve_type,'linear')
    dir1 = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Linear_polar_curves';
else
    dir1 = 'C:\Users\msapkota\EXPERIMENT\Optimisation_problem\Multi_linear_polar_curves';
end

Parameter_dir = 'Parameter';
%Parameter_and_value_dir = 'Parameter';
for k = 1:length(Parameters)
    Parameter_dir = strcat(Parameter_dir, '_' ,string(Parameters{k}));
    %Parameter_and_value_dir = strcat(Parameter_and_value_dir, '_' ,string(Parameters{k}),'_', string(par_vals{k}));
end

meas_dir = fullfile(dir1, Parameter_dir, 'Measurement_data');

seeding_folder = fullfile(dir1, Parameter_dir, 'Initial_files');

simulation_result_dir = fullfile(dir1, Parameter_dir, 'Simulation_results');

model_output = py.BEASY_IN_OUT_2.get_output_data_for_given_parameters(py.list(Parameters), py.list(par_vals), seeding_folder, simulation_result_dir); 

meas_table = readtable(fullfile(meas_dir, 'Internal_Points.csv'));

simu_output_table = readtable(fullfile(string(model_output{1}), 'Internal_Points.csv'));

end

function ax = comparative_plot(meas_table ,model_table)

%conveting table  into matrix and selecting needed column onlly for ID,
%x,y,z,and value
meas_data = meas_table{:,:}(:,[2,3,4,5,6]);

model_output = model_table{:,:}(:,[2,3,4,5,6]);
                            % load dat
figure(1);
ax =  subplot( 1, 1, 1 );
%difference_data = model_output(:,[5])- meas_data(:,[5]);
difference_data = model_output(:,[5]);


scatter3(ax,meas_data(:,[2]),meas_data(:,[3]),meas_data(:,[4]),40,difference_data,'filled');    % draw the scatter plot

%ax.XDir = 'reverse';
ax.ZDir = 'reverse';
view(221,21);
xlabel(ax,'x pos');
ylabel(ax,'y pos');
zlabel(ax,'z pos');

cb = colorbar;    
% create and label the colorbar
%caxis([-20 20]);
%cb.Label.String = 'difference in p.d. (mV) (model output - measured)';
cb.Label.String = 'surface potential (mV)';
%title('difference in model output and measured value at surface of object');

%cb.Label.String = 'p.d.(mV)';
%title('model output p.d. at surface of object');

end