function arr1 = convert_py_dict_lists_to_array(dict_with_lists)

keys = py.model_validation1.get_list_of_keys(dict_with_lists);

multiple_lists  = py.model_validation1.get_list_of_values(dict_with_lists);

arr1 = zeros(length(multiple_lists{1}), length(keys));

for i = 1:length(keys)
    arr1(:,i) = convert_py_list_to_arr1(multiple_lists{i});
end

end

function arr = convert_py_list_to_arr1(py_list)
    arr = zeros(1,length(py_list));
    for i = 1:length(py_list)
        arr(1,i) = py.float(py_list{i});
    end
end
