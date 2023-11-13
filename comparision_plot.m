function comparision_plot(ax,ids, simulation_output, surrogate_output, title_for_plot) 
    i=1;
    mat1 = [[1:length(ids{i})].', simulation_output{i}(:,2), surrogate_output{i}(:,2)];
    %mat1 = sort(mat1,1);
    
    plot(ax, uint64(mat1(:,1)), mat1(:,2));
    hold(ax, 'On');
    plot(ax, uint64(mat1(:,1)), mat1(:,3));
    
    xlabel(ax, 'IDs')

    ylabel(ax,'surface potential ');
  
    legend(ax, 'Solution Output', 'calibration data');
    
    title(ax, title_for_plot);


end
