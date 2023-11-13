function anode_consumed = cumulative_anode_consumption(rates, rate_time_years, prediction_range, IDs, interpolation)

    anode_consumed = zeros(length(IDs), 1);

    anode_consumption_predictor = response_surface(rate_time_years.', rates);

    if interpolation
        %disp('sadfdsa')
        for i = prediction_range(1):prediction_range(end)
    
            year_in_data = rate_time_years == i;
    
            if any(year_in_data)
        
                anode_consumed = anode_consumed + rates(find(year_in_data==1),:).';
        
            else
                anode_consumption_pred = output_from_surrogates(i, anode_consumption_predictor, [length(IDs)]);
                anode_consumed = anode_consumed+ anode_consumption_pred{1};
            end
        end

    else
        
        for i = prediction_range(1):prediction_range(end)
    
            if i < rate_time_years(end)
        
                [~ ,year_indx_considered] = min(abs(rate_time_years-i));
        
                if i < rate_time_years(year_indx_considered)
                    %disp(i);
            
                    year_indx_considered = year_indx_considered-1;
                end
        
                anode_consumed = anode_consumed + rates(year_indx_considered,:).';
        
            else
                anode_consumption_pred = output_from_surrogates(i, anode_consumption_predictor, [length(IDs)]);
                anode_consumed = anode_consumed+ anode_consumption_pred{1};
            end
        end
        
    end
%}

%}
%{
for i = prediction_range(1):prediction_range(end)
    
    if i < rate_time_years(end)
        
        [~ ,year_indx_considered] = min(abs(rate_time_years-i));
        
        if i > rate_time_years(year_indx_considered)
            
            year_indx_considered = year_indx_considered+1;
        end
        
        anode_consumed = anode_consumed + rates(year_indx_considered,:).';
        
    else
        anode_consumption_pred = output_from_surrogates(i, anode_consumption_predictor, [length(IDs)]);
        anode_consumed = anode_consumed+ anode_consumption_pred{1};
    end
end
%}
end

