function np_arr = convert_arr_to_numpy_array(array_in)

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

np_arr = py.numpy.array(py.list(temp_cell));

end