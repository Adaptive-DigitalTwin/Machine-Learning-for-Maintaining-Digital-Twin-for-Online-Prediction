function ax1 = response_in_bar_chart(ax, IDs_data, response_data, legend_cell)

x_data = IDs_data(:,1)';

y_data = zeros(length(response_data), length(x_data));

for i = 1:length(response_data)
    y_data(i,:) = response_data{i}(:,end)';
end

ax1 = bar(ax, 1:length(x_data), y_data);

legend(legend_cell,'Location','west');

set(ax,'XAxisLocation','top');
ax.XTick = 1:length(x_data); 
ax.XTickLabels = strsplit(num2str(x_data));
ylabel(ax, 'Potential difference Ag/Agcl/Sea-water (mV)');
xlabel(ax, 'Data Positional IDs');

end