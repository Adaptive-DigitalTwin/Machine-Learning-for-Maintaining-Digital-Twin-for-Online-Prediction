%{
solution_dir = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_10\previous__updated_model\Simulation_results\BA01_0.7450_______BA08_0.5300';

polar_dir = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_10\Polarisation_data';

files_name = 'BU_014_NoLinear';

meas_files_name = 'BU_TimeStepped_01_10';

meas_dir = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_10\measurement_data';


%}
figure
%%

materials_invoved = {'CA00','CB05', 'CA05','CB10','CA10'};

root_folder = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B';
%materials_invoved = {'BA01','BA08'};

%meas_materials_tag = {'CA00', 'CB00','CA05', 'CB05','CA10','CB10', 'CA25', 'CB25'};
%meas_materials_tag = {'CB05', 'CA25','CA00','CA05','CB25'};

files_name = 'BU_TimeStepped_01_20';



%meas_pol_curves = py.BEASY_IN_OUT1.get_polarisation_curve_from_mat_file(py.list(parameters), meas_mat_file);

curve_dir = fullfile(root_folder, strcat(string(20)));

simulation_files = dir(curve_dir);
files_name = simulation_files(end-2).name;
files_name = strsplit(files_name, '.');
files_name = files_name{1};

mat_file = fullfile(curve_dir, strcat(files_name,'.mat_cp'));

polarisation_curves = py.BEASY_IN_OUT1.get_polarisation_curve_from_mat_file(py.list(materials_invoved), mat_file);
%%
%{
p = cell(length(meas_pol_curves),1);
plot_lines = zeros(length(meas_pol_curves),1);

for i =1:length(meas_pol_curves)
    pol_curve = meas_pol_curves{i};
    disp(pol_curve.name);
    current_value = convert_py_list_to_mat_arr(pol_curve.current_values);
    potential_value = convert_py_list_to_mat_arr(pol_curve.voltage_values);
    p{i} = plot(current_value, smooth(potential_value));
    plot_lines(i) = p{i}(1);
    if ~isequal(i, length(meas_pol_curves))
        hold on;
   end
end
%legend([p{1}(1);p{2}(1)], 'Material A2 relatd polarisation curve', 'Material A1 related polarisation curve');
%legend(flip(plot_lines), meas_materials_tag);
%legend(plot_lines, meas_materials_tag);

%}
%%
figure;
hold on;
p2 = cell(length(polarisation_curves),1);
plot_lines2 = zeros(length(polarisation_curves),1);
for i =1:length(polarisation_curves)
    pol_curve = polarisation_curves{i};
    current_value = convert_py_list_to_mat_arr(pol_curve.current_values);
    potential_value = convert_py_list_to_mat_arr(pol_curve.voltage_values);
    if isequal(rem(i,2) ,1)
        p2{i} = plot(current_value, smooth(potential_value),'LineWidth' , 1.5, 'LineStyle','--');
    else
        p2{i} = plot(current_value, smooth(potential_value),'LineWidth' , 1.5);
    end
    plot_lines2(i) = p2{i}(1);
    if ~isequal(i, length(polarisation_curves))
        hold on;
   end
end

%legend([plot_lines; plot_lines2],[strcat('True ',parameters), strcat('Solution ', parameters)]);
legend(plot_lines2, strcat('curve for Material__ ', materials_invoved));
xlabel(strcat('Current density (', string(pol_curve.current_unit),')'));
ylabel(strcat('Potential (', string(pol_curve.voltage_unit), ')'));
ylim([-1150 -700])
%}