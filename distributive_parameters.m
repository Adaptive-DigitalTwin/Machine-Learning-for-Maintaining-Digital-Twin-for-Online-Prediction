
polar_dir = 'C:\Users\msapkota\EXPERIMENT\DOE_nd_data_generation\TIme_step\year_10\Polarisation_data';


files_name = 'BU_TimeStepped_01_10';

mat_file = fullfile(polar_dir, strcat(files_name,'.mat_cp'));

%materials_invoved = {'CA00', 'CB00','CB05', 'CA05','CB10','CA10', '9BARE'};
reference_materials_invoved = {'CA00'};

pol_curves = py.BEASY_IN_OUT1.get_polarisation_curve_from_mat_file(py.list(reference_materials_invoved), mat_file);
figure;

p_value_distribution_ranges = DOE_range1(1,:);
%p_value_distribution_ranges = predicted_p_value_25;

p = cell(length(pol_curves)*2,1);
plot_lines = zeros(length(pol_curves)*2,1);

curve_index = 0;
patch_colors = {'c', 'b'};
for i =1:length(pol_curves)
    
    pol_curve = pol_curves{i};
    
    potential_value = convert_py_list_to_mat_arr(pol_curve.voltage_values);
    for j = 1:2
        curve_index = curve_index+1;
        if isequal(j,2)
            previous_current_value = current_value;
        end
        current_value = p_value_distribution_ranges(i,j)* convert_py_list_to_mat_arr(pol_curve.current_values);
        p{curve_index} = plot(current_value, smooth(potential_value), 'LineWidth' , 1.5);
        plot_lines(curve_index) = p{curve_index}(1);
        hold on;
    end
    
    %fill([previous_current_value fliplr(current_value)], [potential_value fliplr(potential_value)], 'r')
    if isequal(i,1)
        patch([p{curve_index}.XData, fliplr(p{curve_index-1}.XData)], [p{curve_index}.YData, fliplr(p{curve_index-1}.YData)], patch_colors{i}) 
    %if ~isequal(curve_index, 2*length(pol_curves))
        alpha(0.1);
        hold on;
    end
    %}
   %end
end
%legend([p{1}(1);p{2}(1)], 'Material A2 relatd polarisation curve', 'Material A1 related polarisation curve');
legend(plot_lines, [strcat('CA20 ',{' lower limit', ' upper limit'})]);
xlabel(strcat('Current density (', string(pol_curve.current_unit),')'));
ylabel(strcat('Potential (', string(pol_curve.voltage_unit), ')'));

%legend([plot_lines; plot_lines2], [strcat('CA20 ',{' lower limit', ' upper limit'}, 'provided'), 'Solution reached']);
