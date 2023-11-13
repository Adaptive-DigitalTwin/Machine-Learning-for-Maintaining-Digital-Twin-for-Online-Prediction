function f = normalised_mean_sq_diff(model_output, validating_data, data_involved, weightage_constant)

    if length(data_involved) > 1
        f = 0;
        for i = 1:length(data_involved)
            sub_meas_data = validating_data{i}(:,end);
            [indices_with_zero, ~] = find(sub_meas_data ==0); 
            sub_meas_data(indices_with_zero) = [];
            sub_out_data = model_output{i}(:,end);
            sub_out_data(indices_with_zero) = [];
            %f = f + weightage_constant(i)* sqrt( mean((model_output{i}-meas_data{i}).^2./meas_data{i}.^2 ));
            f = f + weightage_constant(i)* sqrt( mean((sub_out_data-sub_meas_data).^2./sub_meas_data.^2 ));
        end
        
        f = f/length(data_involved);
        
    elseif strcmp(data_involved{1}, 'voltage')
        sub_meas_data = validating_data{1};
        f = sqrt( mean((model_output{1}-sub_meas_data(:,2)).^2./sub_meas_data(:,2).^2 ));
    elseif strcmp(data_involved{1}, 'current density')
        f = sqrt( mean((model_output{2}-meas_data{2}).^2./meas_data{2}.^2));
    end
   
end