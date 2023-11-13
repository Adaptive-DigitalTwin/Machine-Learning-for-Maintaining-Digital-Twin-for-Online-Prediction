function data_inc_error = introduce_error_and_write_file(IDs_data, data_no_error, location, file_name, error_percent)

file_name = fullfile(location, file_name);

data_inc_error = data_no_error;

for k = 1:length(data_no_error)
    
    % considering maximum of 3% errors 
    sub_data = data_inc_error{k};
    error_considered =  error_percent/100*sub_data(:,end).'.*(rand(1, size(sub_data,1))-0.5);
    sub_data(:,end) = sub_data(:,end) + error_considered';
    
    %data_inc_err{k}(:,2) = data_no_error{k}(:,2) + [error_range(1) + rand(1,size(data_no_error{k}(:,2),1))*(error_range(2)-error_range(1))].';
    %data_inc_err{k} = sub_data;
    data = [IDs_data{k}, data_no_error{k}(:,end), sub_data(:,end)];
    variables_name = {'Ids', 'response_data', 'response_data_with_error'};
    %A = {{'Ids', 'response_data', 'response_data_with_error'}; data};
    T = array2table(data, 'VariableNames', variables_name);  
    writetable(T, file_name, 'Sheet', k);
    
end
