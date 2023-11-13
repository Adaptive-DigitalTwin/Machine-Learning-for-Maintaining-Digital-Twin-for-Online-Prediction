function fobj = obj_from_surrogate(xinv,indexes, x_all, bounds, surrogates, data_involved, data_counts, validating_data, weightage_constant)
%
%weightage_constant = [1, 1];

%x = [2.2, 3.1];
x_temp = x_all;
x_temp(indexes) = xinv;

for i = 1:size(x_temp,2)
    if x_all(i) < bounds(i,1)
        x_temp(i) = bounds(i,1);
    elseif x_all(i) > bounds(i,2)
        x_temp(i) = bounds(i,2);
    end
end
    

%data_counts = calibration_data_count;
model_output = output_from_surrogates(x_temp, surrogates,  data_counts);

%data_involved = calibration_data_type;
fobj = normalised_mean_sq_diff(model_output, validating_data, data_involved, weightage_constant);

end


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