function response_data = data_from_tables(excel_file, Ids, data_column_idx)

[~, sheets] = xlsfinfo(excel_file);

response_data = cell(length(Ids),1);

for i = 1: length(Ids)
    data_temp = xlsread(excel_file,i);
    response_data{i} = data_temp(ismember(data_temp(:,1), Ids{i}),[1,data_column_idx]);
end

