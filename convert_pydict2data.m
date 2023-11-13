function output_data = convert_pydict2data(py_dict_data, extra_cell_provided)

output_data = cell(size(py_dict_data,2)-extra_cell_provided,1);

for i = 1:size(py_dict_data,2)-extra_cell_provided
    keys_list = convert_py_list_to_mat_arr(py.model_validation1.get_list_of_keys(py_dict_data{i+extra_cell_provided}));
    mat_arr = zeros(length(keys_list),2);
    mat_arr(:,1) = uint64(keys_list);
    values_list = convert_py_list_to_mat_arr(py.model_validation1.get_list_of_values(py_dict_data{i+extra_cell_provided}));
    mat_arr(:,2) = values_list;
    output_data{i} = mat_arr;
end
end