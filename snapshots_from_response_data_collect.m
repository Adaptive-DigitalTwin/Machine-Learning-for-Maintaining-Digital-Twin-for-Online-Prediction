function [parameters_arr, snapshots_arr] = snapshots_from_response_data_collect(parameters, data_collected)

total_samples_points = length(data_collected{1});

response_data_type_counts = length(data_collected{1,2}{1,1});

data_counts = zeros(1, response_data_type_counts);
for i = 1:response_data_type_counts
    data_counts(i) = length(data_collected{1,2}{1,1}{i});
end

snapshots_arr = zeros(total_samples_points, sum(data_counts));

parameters_arr = zeros(total_samples_points, length(parameters));

for i = 1:total_samples_points
    
    cum_data_count = 0;
    
    response_data = data_collected{1,2}{1,i};
    
    for j = 1:length(response_data)
        
        snapshots_arr(i, cum_data_count+1:cum_data_count + data_counts(j)) = response_data{j}(:,2);
        
        cum_data_count = cum_data_count+data_counts(j);
        
    end
    
    parameters_arr(i,:) = data_collected{1,1}{1,i};

end