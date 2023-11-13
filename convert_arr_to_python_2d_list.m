function python_2d_list = convert_arr_to_python_2d_list(array_in)

temp_cell = cell(1,size(array_in,1));

if isequal(size(array_in,2),1)
    for i = 1:size(array_in,1)
        temp_cell{i} = py.list({array_in(i,:)});
    end
else
    for i = 1:size(array_in,1)
        temp_cell{i} = py.list(array_in(i,:));
    end
end

python_2d_list = py.list(py.list(temp_cell));

end