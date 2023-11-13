function Fits_sol = response_surface(sample_points, training_dataset_2d, order)

total_position_ids = size(training_dataset_2d,2);
parameters_count = size(sample_points,2);

Fits_sol = cell(1, total_position_ids);

if isequal(parameters_count, 1)
    if isequal(order, 1)
        ft = fittype( 'poly1');
    elseif isequal(order, 2)
        ft = fittype( 'poly2');
    end
    for j = 1:total_position_ids
        sub_training_data = training_dataset_2d(:,j);
        Fits_sol{j} = fit( sample_points(:,1), sub_training_data , ft);
    end
  
elseif isequal(parameters_count, 2)
    if isequal(order, 1)
        ft = fittype( 'poly11');
        for j = 1:total_position_ids
            sub_training_data = training_dataset_2d(:,j);
            Fits_sol{j} = fit(sample_points, sub_training_data, ft );
        end
    elseif isequal(order, 2)
        ft = fittype( 'poly22');
        for j = 1:total_position_ids
            sub_training_data = training_dataset_2d(:,j);
            [xData, yData, zData] = prepareSurfaceData(sample_points(:,1), sample_points(:,2), sub_training_data);
            Fits_sol{j} = fit([xData, yData], zData, ft );
        end
    elseif isequal(order,3)
        ft = fittype( 'poly23');
        for j = 1:total_position_ids
            sub_training_data = training_dataset_2d(:,j);
            [xData, yData, zData] = prepareSurfaceData(sample_points(:,1), sample_points(:,2), sub_training_data);
            Fits_sol{j} = fit([xData, yData], zData, ft );
        end
    end
    
elseif isequal(parameters_count, 3)
    if isequal(order,2)
        for j = 1:total_position_ids
            sub_training_data = training_dataset_2d(:,j);
            %[xData, yData, zData] = prepareSurfaceData(sample_points(:,1), sample_points(:,2), sub_training_data);
            %Fits_sol{j} = polyfitweighted2(sample_points(:,1), sample_points(:,2), sub_training_data, 3, 0.5);
            Fits_sol{j} = polyfitn(sample_points, sub_training_data, 2);
       
        end
    end
    
end


end



