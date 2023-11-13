function arr1 = convert_py_list_to_mat_arr(py_list)

arr1 = zeros(size(py_list,2),1);

for k = 1:length(py_list)
    arr1(k) = py.float(py_list{k});
end


end