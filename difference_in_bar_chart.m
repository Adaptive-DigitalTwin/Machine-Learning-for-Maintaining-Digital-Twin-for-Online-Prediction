function ax1 = difference_in_bar_chart(ax, data1, data2, legend_cell)

x_data = data1(:,1)';
y1 = data1(:,end)';
y2 = data2(:,end)';


if isequal(length(legend_cell), 2)
    ax1 = bar(ax, 1:length(x_data), [y1 ; y2]);
else
    ax1 = bar(ax, 1:length(x_data), [y1 ; y2; y2-y1]);
end
legend(legend_cell,'Location','west');

set(ax,'XAxisLocation','top');
ax.XTick = 1:length(x_data); 
ax.XTickLabels = strsplit(num2str(x_data));
ylabel(ax, 'Potential difference Ag/Agcl/Sea-water (mV)');
xlabel(ax, 'Data Positional IDs');
end