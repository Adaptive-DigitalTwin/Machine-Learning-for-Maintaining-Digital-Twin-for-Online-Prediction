function scatter_map_plot(ax, coordinate_data, value_data,  map_label) 

scatter3(ax, coordinate_data(:,[2]),coordinate_data(:,[3]),coordinate_data(:,[4]),40,value_data,'filled')    % draw the scatter plot

ax.ZDir = 'reverse';
view(221,21)
xlabel(ax, 'x pos')
ylabel(ax, 'y pos')
zlabel(ax, 'z pos')

cb = colorbar;    
% create and label the colorbar
%caxis([-20 20]);
cb.Label.String = map_label;

end