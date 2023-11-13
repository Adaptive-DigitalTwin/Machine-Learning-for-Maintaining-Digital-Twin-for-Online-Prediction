function model_out = output_from_surrogates(x, surrogates,  data_counts)

model_out = cell(size(data_counts,2),1);
if length(x)<=2 
    for i = 1:size(data_counts,2)
        response_data = zeros(data_counts(1,i),1);
        if isequal(i,1)
            for j=1:data_counts(1,i)
                response_data(j,1) =  surrogates{j}(x);
            end
        else
            for j=1:data_counts(1,i)
                response_data(j,1) =  surrogates{j+sum(data_counts(1:i-1))}(x);
            end
        end
    
        model_out{i} = response_data;
    
    end
else
    for i = 1:size(data_counts,2)
        response_data = zeros(data_counts(1,i),1);
        if isequal(i,1)
            for j=1:data_counts(1,i)
                response_data(j,1) =  polyvaln(surrogates{j},x);
            end
        else
            for j=1:data_counts(1,i)
                response_data(j,1) =  polyvaln(surrogates{j+sum(data_counts(1:i-1))},x);
            end
        end
        model_out{i} = response_data;
    end
end