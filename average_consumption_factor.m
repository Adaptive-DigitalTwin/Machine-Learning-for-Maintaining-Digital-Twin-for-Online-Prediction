years = [0, 5,10,15];

all_anode_IDs = 1:266;

root_folder1 = 'D:\DOE_nd_data_generation\TIme_step\readyToTimeStepUsingV10_B';


average_CONSUMPTION_FACTOR = zeros(1, length(years));

for i = 1:length(years)
    
    year_t = years(i);
    
    response_folder = fullfile(root_folder1,strcat('year_', string(year_t)), 'Calibration_data');
    
    simulation_files = dir(response_folder);
    files_name = simulation_files(end-3).name;
    files_name = strsplit(files_name, '.');
    files_name = files_name{1};
    
    anode_file = fullfile(response_folder,strcat(files_name, '.cp_anode_decay'));
    
    initial_anode_data = py.BEASY_IN_OUT2.get_output_data_for_IDs_from_simulation_folder(response_folder, files_name, py.list({'anode related'}),  py.list({py.list(all_anode_IDs)}), py.list({'CONSUMPTION_FACTOR'}));
     %initial_anode_data = py.BEASY_IN_OUT2.extract_anode_information_from_file(anode_file, py.list(all_anode_IDs), py.list({'MASS_NOW'}));
    
    
    initial_anode_data = convert_pydict2data(initial_anode_data,0);
    
    initial_anode_data = initial_anode_data{1};
    
    average_CONSUMPTION_FACTOR(i) = mean(initial_anode_data(:,2));
    
end
