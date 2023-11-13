import numpy as np
import os
import pandas as pd
import shutil
import re


class Polarisation_Curve_P_value:
    def __init__(self, name, p_value):
        self.name = name
        self.p_value = p_value

class Polarisation_Curve:
    def __init__(self, name, current_unit, voltage_unit, current_list, voltage_list):
        self.name = name
        self.current_unit = current_unit
        self.voltage_unit = voltage_unit
        self.current_values = current_list
        self.voltage_values = voltage_list

def update_mat_file_with_p_value(mat_file,material_code, p_value):
    
    with open(mat_file) as f:
        s = f.read()
        string_list = [st for st in s.splitlines()]
        f.close()
            
    replacing_start = False
        
    corres_mat_voltage_line_index = -1
    
    for line_count, line in enumerate(s.splitlines()):

        if material_code in line:
            replacing_start = True
        
        current_line_index = -1
        
        if replacing_start: 
            #the voltage line is not splitted by space
            if len(line.split()) == 1:
                corres_mat_voltage_line_index = line_count
                #print(corres_mat_voltage_line_index)
                break
            
    if corres_mat_voltage_line_index != -1:
        current_index_in_file = s.splitlines()[corres_mat_voltage_line_index-1].split()[0]
        #continue to change value unless the current line index changes 
        for idx in  range(corres_mat_voltage_line_index-1, 0, -1):
            if current_index_in_file != string_list[idx].split()[0]:
                break
            
            line_list = s.splitlines()[idx].split()
            
            temp_line = s.splitlines()[idx]
            
            replacing_terms = [value for idx1, value in enumerate(line_list) if idx1%5 == 0 and idx1 !=0]
         
            replace_with = [format(float(value)*p_value, '.4E') for value in replacing_terms]
            #print(replace_with)
            #print(replace_with)
            for str1, str2 in zip(replacing_terms, replace_with):
                temp_line = temp_line.replace(str1,str2)
                #print(temp_line)
            
            #string_list[idx] = ' '.join([str(a) for a in line_list])
            string_list[idx] = temp_line
        
    with open(mat_file, 'w') as fw:
        [[fw.write(new_line), fw.write('\n')] for new_line in string_list]
        fw.close()


def update_mat_file_with_p_value1(mat_file,source_material_code, dest_material_code, p_value):
    
    with open(mat_file) as f:
        s = f.read()
        string_list = [st for st in s.splitlines()]
        f.close()
            
    replacing_start = False
    collecting_start = False
    collection_end = False
    
    replacing_lines = []
        
    corres_mat_voltage_line_index = -1
    
    split_lines = s.splitlines()
    replacing_line_count = -1
    for line_count, line in enumerate(split_lines):

        if len(line.split())!=0 and source_material_code in line.split()[0]:
            collecting_start = True
            #collecting_begin_line_idx= line_count
            data_index_in_file = s.splitlines()[line_count+2].split()[0]
            continue
        
        if collecting_start and not collection_end: 
            if data_index_in_file < string_list[line_count].split()[0]:
                collection_end = True
                continue
            
            elif data_index_in_file == string_list[line_count].split()[0]:
                
                line_list = line.split()
            
                temp_line = split_lines[line_count]
            
                replacing_terms = [value for idx1, value in enumerate(line_list) if idx1%5 == 0 and idx1 !=0]
         
                replace_with = [format(float(value)*p_value, '.4E') for value in replacing_terms]

                for str1, str2 in zip(replacing_terms, replace_with):
                    temp_line = temp_line.replace(str1,str2)
                    
                replacing_lines.append(temp_line)
                
                continue
            
            #print(replacing_lines)
            
        if collection_end and dest_material_code in line.split()[0]:
            replacing_start = True
            
            replacng_begin_line_idx= line_count
            string_list[line_count-1] = 'Same as ' + source_material_code + ' but with BF = ' +str(p_value) + '.'
            #string_list[replaci]
            continue
        
        if replacing_start:
            
            if data_index_in_file < string_list[line_count].split()[0]:
                break
            
            elif data_index_in_file == string_list[line_count].split()[0]:
                
                replacing_line_count = replacing_line_count +1
                
                string_list[line_count] = replacing_lines[replacing_line_count]
                
                #print(replacing_line_count)
                
                continue
        
                
    if not replacing_start:
        for line_count, line in enumerate(split_lines):
            if dest_material_code in line.split()[0]:
                replacing_start = True
            
            if replacing_start and data_index_in_file < string_list[line_count].split()[0]:
                break

            elif replacing_start and data_index_in_file == string_list[line_count].split()[0]:
                replacing_line_count = replacing_line_count +1
                
                string_list[line_count] = replacing_lines[replacing_line_count]
            
    with open(mat_file, 'w') as fw:
        [[fw.write(new_line), fw.write('\n')] for new_line in string_list]
        fw.close()



def update_dat_file_with_zone_and_conductivity(dat_file,zone_name, conductivity):

    with open(dat_file) as f:
        s = f.read()
            
    replacing_start = False
        
    string_list = [st for st in s.splitlines()]
    
    
    for line_count, line in enumerate(s.splitlines()):

        if line.startswith('CONDUCTIVITY'):

            # check if the zone ID is corresponding from the previous line

            if s.splitlines()[line_count-1].split()[-1] ==  re.sub('[a-zA-Z]', '', zone_name):
           
            
                temp_line = s.splitlines()[line_count]
            
                replacing_term = s.splitlines()[line_count].split()[-1]
           
                replace_with = format(float(conductivity), '.7E')
                
            
                #string_list[idx] = ' '.join([str(a) for a in line_list])
                string_list[line_count] = temp_line.replace(replacing_term, replace_with)
        
    with open(dat_file, 'w') as fw:
        [[fw.write(new_line), fw.write('\n')] for new_line in string_list]


def get_polarisation_curve_from_mat_file(curve_name_list, mat_file):
    
    with open(mat_file) as f:
        s = f.read()
            
    current_curve_name = ''
        
    string_list = [st for st in s.splitlines()]
    
    result = [Polarisation_Curve(curve_name, 'Amp/m2', 'mV', [], []) for curve_name in curve_name_list]
    
    corres_mat_voltage_line_index = -1
    current_line_idx = -1 
    current_curve_idx = -1

    curves_data_added = []
    for line_count, line in enumerate(s.splitlines()):
        if current_curve_name == '':
            for curve_idx in range(len(curve_name_list)):
                curve = curve_name_list[curve_idx]
                if curve in line and not curve in curves_data_added:
                    current_curve_name = curve
                    current_curve_idx = curve_idx
                    current_curve = Polarisation_Curve(current_curve_name, 'Amp/m2', 'mV', [], [])
        
        if current_curve_name == '':
            continue
        #print(line_count)
        #print(current_curve_name)
        
        #current data is stored in line with length 1 + multiple of 5 
        if (len(line.split())-1)%5 == 0 and len(line.split()) != 1:
            
            #first string hold line index
            
            current_line_idx = int(line.split()[0].replace('-',''))
            line_list = s.splitlines()[line_count].split()
            
            for idx1, value in enumerate(line_list):
                if idx1%5 == 0 and idx1 !=0:
                    #print(current_curve.__dict__)
                    current_curve.current_values.append(float(value))
        
        #volatage data are saved in a single line without given space
        elif len(line.split()) ==1 and len(line) > 4:
            #print(line.replace(' ','').split('-'))
            current_curve.voltage_values.extend([float(value)*-1 for value in line.split('-')[2:]])
        
        elif line == '' or len(line.split()) == 2:

            result[current_curve_idx] = current_curve
            curves_data_added.append(current_curve_name)
            current_curve_name = ''
            #result.append(current_curve)
            
    return result


def xyz_coordinates_for_element_IDS(IDs, gdf_file):
    
    result = {'IDs':[], 'x_pos':[], 'y_pos':[],'z_pos':[]}
    
    with open(gdf_file) as f1:
        s = f1.read()
        all_lines = s.splitlines()
        
        first_ID_line_count = -1
 
        
        for line_idx, line in enumerate(all_lines):
            if all(word in line for word in ['NORMAL_CURRENT', 'AREA']):
                first_ID_line_count = line_idx+1
            
            if not  first_ID_line_count == -1:
                break
            
            
        if first_ID_line_count == -1:
            raise Exception("no clue word is founf")
        
        for ID in IDs:
            temp_line = all_lines[int(ID)+first_ID_line_count-1]
            
            if not str(ID) == str(temp_line.split()[0]):
                for idx in range(first_ID_line_count, len(all_lines)):
                    temp_line = all_lines[idx]
                    if str(ID) == str(temp_line.split()[0]):
                        break
                
            for idx, key, split in zip(range(0,4), result, temp_line.split()):
                if idx == 0:
                    #print(split)
                    result[key].append(split)
                else:
                    result[key].append(float(split))
        return result


def xyz_coordinates_for_IDS(IDs, dat_file, IDs_type):
    
    result = {'IDs':[], 'x_pos':[], 'y_pos':[],'z_pos':[]}
    
    if IDs_type == 'Mesh Points':
        clue_word = 'MESH POINT COORDINATES'
    elif IDs_type == 'Internal Points':
        clue_word = 'INTERNAL POINTS'
    
    with open(dat_file) as f1:
        s = f1.read()
        all_lines = s.splitlines()
        
        first_ID_line_count = -1
        
        for line_idx, line in enumerate(all_lines):
            if clue_word in line:
                first_ID_line_count = line_idx+1
                break
            
        if first_ID_line_count == -1:
            raise Exception("no clue word is found")
        
        for ID in IDs:         
            for temp_line in all_lines[first_ID_line_count:len(all_lines)]:
                if str(ID) == str(temp_line.split()[0]):
                    for idx, key, split in zip(range(0,4), result, temp_line.split()):
                        if idx == 0:   
                            #print(split)
                            result[key].append(int(split))
                        else:
                            result[key].append(float(split))
                    
                    break
                    
        return result

def create_simulation_set_with_changed_polarisation_curve(existing_root_folder, new_directory, file_name_to_edit, polarisation_curve_list):
    #creating copy folder
    if not os.path.isdir(new_directory):
        shutil.copytree(existing_root_folder, new_directory) 
    
    #make the change in the needed file
        for polarisation_curve in polarisation_curve_list:
            #print(os.path.join(new_directory,file_name_to_edit))
            #change_linear_input_parameter_eqn_in_given_mat_cp_file(parameter, os.path.join(new_directory,file_name_to_edit))
            update_mat_file_with_p_value(os.path.join(new_directory,file_name_to_edit), polarisation_curve.name, polarisation_curve.p_value)


def run_file_in_directory(directory, file_name):
    os.chdir(directory)
    os.system(os.path.join(directory,file_name))


def extract_information_from_file(files_name_with_path, exporting_location, identifying_string):
    
    dat_file = files_name_with_path+'.dat'
    
    dict1 = {'ID':[ ], 'x_pos':[ ], 'y_pos':[ ], 'z_pos':[ ]}
    
    with open(dat_file) as f1:
        s = f1.read()
        term_identied = False

        for line in s.splitlines():
            if identifying_string in line:
                term_identied = True
                continue
            
            if not term_identied:
                continue

            list_from_line = line.split()
            
            if not list_from_line[0].isdigit():
                break
            for idx, value in enumerate(list_from_line):
                if idx == 0:
                    dict1['ID'].append(value)
                    #print(value)
                
                elif idx == 1:
                    dict1['x_pos'].append(value)
                elif idx == 2:
                    dict1['y_pos'].append(value)
                else:
                    dict1['z_pos'].append(value)
                    
                #adding parameters value in the dictionary
                
    starting_ID = dict1['ID'][0]
    ending_ID = dict1['ID'][-1]
    #[print(key, len(value)) for key, value in dict1.items()]         
    df = pd.DataFrame(dict1)
    
    result_from_result_file = []
    
    #print('starting ID is ', starting_ID)
    res_file = files_name_with_path+'.post.res'
    with open(res_file) as f2:
        s1 = f2.read()
        starting_id_found = False
        
        idx_for_ID = 0 
        for line in s1.splitlines():
            list_from_line = line.split()
            
            if not starting_id_found and list_from_line[0] != starting_ID:
                continue
            
            elif list_from_line[0] == starting_ID and len(list_from_line) == 2:
                #print(line)
                starting_id_found = True
            
            if not starting_id_found:
                continue
            
            if dict1['ID'][idx_for_ID] == list_from_line[0]:
                result_from_result_file.append(list_from_line[-1])
                idx_for_ID+=1
                
            if list_from_line[0] == ending_ID:
                break
    
    df['Output_value'] = result_from_result_file
    

    df.to_csv(exporting_location+'\Internal_Points.csv')


    
def add_extracted_values_excel_file_in_the_folder(folder_directory, name_for_files, clue_word, overwrite):

    if any(file.split('.')[-1] == 'res' for file in os.listdir(folder_directory)):
    #if any(file.split('.')[-1] == 'res' for file in os.listdir(folder_directory)) and not any (file.split('.')[-1] == 'csv' for file in os.listdir(folder_directory)):
        files_name_with_path = '{}\{}'.format(folder_directory,name_for_files)
        
        if not files_name_with_path in os.listdir(folder_directory) or overwrite:        
            extract_information_from_file(files_name_with_path, folder_directory, clue_word)
            
    return
            

    
def extract_data_related_dict(file_dir, file_name, information_related_word, ending_word_clue, dict_keys):
    
    res_file = os.path.join(file_dir, file_name)   
    
    result_dict = {}
    
    with open(res_file) as f2:
        s1 = f2.read()
        starting_id_found = False
        
        line_count = 0

        for line in s1.splitlines():
            line_count +=1
            
            temp_list_from_line = line.split()
            
            if not (starting_id_found or information_related_word in line):
                continue
            
            elif information_related_word in line:
                #print(line)
                starting_id_found = True
            
            elif ending_word_clue in line:
                starting_id_found = False
            
            if not starting_id_found:
                continue
            
            if temp_list_from_line[0] in dict_keys and len(temp_list_from_line) ==2:
                #print('matched')
                result_dict[temp_list_from_line[0]] = float(temp_list_from_line[1])
            
    return result_dict


def extract_response_data_for_mesh_IDs(res_gdf_file, unsorted_IDs, key_string, data_type, include_coord):

    if include_coord:
        col_count = 5
    else:
        col_count = 2
    
    result_from_file = np.zeros((len(unsorted_IDs),col_count))
    
    previous_idx = np.argsort(unsorted_IDs)
    
    sorted_IDs = np.sort(unsorted_IDs)
    
    if data_type == 'voltage':
        data_column = 4
    elif data_type == 'normal current density':
        data_column = 9
             
    term_identied = False
    extraction_intiated = False
    
    IDs_idx = 0
    
    data_blocks_line = [-1,-1]
    
    with open(res_gdf_file) as f2:
        s = f2.read()
        
        for line_idx, line in enumerate(s.splitlines()):
            if not term_identied:
                if key_string in line:
                    term_identied = True
                    data_blocks_line[0] = line_idx+3
                    data_block_column_size = len(s.splitlines()[line_idx+2].split())
                    #print(data_block_column_size)
                continue
            else:
                if not len(line.split()) == data_block_column_size and line_idx > data_blocks_line[0]+len(sorted_IDs):
                    data_blocks_line[1] = line_idx-1
                    break

        if not all(data == -1 for data in data_blocks_line):
            #print(data_blocks_line)
            for ID_idx, ID in enumerate(sorted_IDs):
                for line in s.splitlines()[data_blocks_line[0]:data_blocks_line[1]]:
                    list_from_line = line.split()
                    if int(list_from_line[0]) == int(ID) :
                        
                        list_from_line1 = [int(list_from_line[0])]
                        if include_coord:
                            
                            list_from_line1.extend([float(b) for b in list_from_line[1:4]])
                        
                        
                        list_from_line1.append(float(list_from_line[data_column]))
                        
                        result_from_file[previous_idx[ID_idx]] = list_from_line1
                        #print(list_from_line)
                        break

                             
    #print(result_from_file)
    df = pd.DataFrame(result_from_file, columns = ['IDs', 'x_cor', 'y_cor', 'z_cor', data_type])
    #df.sort_values(by = ['IDs'], key=make_sorter(unsorted_IDs))
    #df.sort_values(by = ['z_cor'])
    
    return df


def directional_current_density_from_gdf_file(directory, ID_list, keywords):
    
    result_dict = {}
    
    with open(directory) as f2:
        s1 = f2.read()
        
        
        first_key_word_found = False
        
        second_key_word_found = False
        
        line_count = 0
        
        data_line_tab_counts = 0
        
        data_col_indx = 0

        for line in s1.splitlines():
            line_count +=1
            
            temp_list_from_line = line.split()

            
            if keywords[0] in line:
                first_key_word_found = True
                
            if not first_key_word_found:
                continue
                
            else:
                if keywords[1] in line:
                    second_key_word_found = True
                    data_line_tab_counts = len(temp_list_from_line)
                    #print(data_line_tab_counts)
                    
                    for idx, str1 in enumerate(temp_list_from_line):
                        if keywords[1] in str1:
                            data_col_indx = idx
                            break
                    continue
                
                if not second_key_word_found:
                    continue
            
            #print(temp_list_from_line)
            if not len(temp_list_from_line) == data_line_tab_counts:
                break
            
            if float(temp_list_from_line[0]) in ID_list:
                #print('matched')
                result_dict[temp_list_from_line[0]] = float(temp_list_from_line[data_col_indx])
            
    return result_dict



def directional_electric_field_from_gdf_file(directory, ID_list, keywords):
    
    result_dict = {}
    
    with open(directory) as f2:
        s1 = f2.read()
        
        
        first_key_word_found = False
        
        second_key_word_found = False
        
        line_count = 0
        
        data_line_tab_counts = 0
        
        data_col_indx = 0

        for line in s1.splitlines():
            line_count +=1
            
            temp_list_from_line = line.split()

            
            if keywords[0] in line:
                first_key_word_found = True
                
            if not first_key_word_found:
                continue
                
            else:
                if not second_key_word_found:
                    if keywords[1] in line:
                        second_key_word_found = True
                        data_line_tab_counts = len(temp_list_from_line)
                        #print(data_line_tab_counts)
                    
                        for idx, str1 in enumerate(temp_list_from_line):
                            if keywords[1] in str1:
                                data_col_indx = idx
                                break
                        continue
                elif not len(temp_list_from_line) == data_line_tab_counts:
                    first_key_word_found = False
                    second_key_word_found = False
                
                if not second_key_word_found:
                    continue

            #print(temp_list_from_line[0])
            if float(temp_list_from_line[0]) in ID_list:
                #print('matched')
                result_dict[temp_list_from_line[0]] = float(temp_list_from_line[data_col_indx])
            
    return result_dict


def remove_other_files_from_directory(directory, extension_list):
    for f in os.listdir(directory):
        #print(f)
        if not any([f.endswith(extension) for extension in extension_list]):
            os.remove(os.path.join(directory, f))

def convert_csv_file_to_dictionary_with_ID_key(csv_file, value_related_string):
    result = {}
    df = pd.read_csv(csv_file)
    for idx in range(len(df)):
        key = df.loc[idx,'ID']
        value = [df.loc[idx, value] for value in df.columns if value.startswith(value_related_string)]
        if len(value) == 1:
            result[key]= value[0]
        else:
            result[key] = value
    return result


def change_simulation_input_set(new_directory, polarisation_curve_list, zones_name, conductivity_list):

    mat_file_address = [os.path.join(new_directory,file) for file in os.listdir(new_directory) if file.endswith('.mat_cp')][0]
   
    for polarisation_curve in polarisation_curve_list:
        update_mat_file_with_p_value(mat_file_address, polarisation_curve.name, polarisation_curve.p_value)

    dat_file_address = mat_file_address.replace('.mat_cp','.dat')

    if not conductivity_list == None:

        for con_count, zone in enumerate(zones_name):
            
            update_dat_file_with_zone_and_conductivity(dat_file_address, zone, conductivity_list[con_count])
        
        

def filter_keys(filtering, being_filtered):
    return {x:being_filtered[x] for x in being_filtered if x in filtering}


def snapshots_for_given_parameters_and_IDs(parameters, param_values, response_data_IDs, response_data_type, seed_directory, collection_dir, IDs_types):
    snapshots = np.zeros((len(param_values),sum(len(a) for a in response_data_IDs)))
    for snap_count, par_values in enumerate(param_values):
        model_output = get_response_data_for_IDs_and_input_parameters(parameters, par_values, seed_directory, collection_dir, 
                                                                      response_data_type, response_data_IDs, IDs_types)
        
        #snapshot = np.zeros(snapshots.size[1])
        data_count = 0;
        for i in range(len(response_data_type)):
            snapshots[snap_count][data_count:data_count+len(response_data_IDs[i])] = list(model_output[i+1].values())
            data_count+= len(response_data_IDs[i])
            
        #snapshots[snap_count] = snapshot    
        
    return snapshots


def get_output_data_for_IDs_from_simulation_folder(new_folder_dir, files_name, data_types, IDs, IDs_type):
    
    if not any(file.split('.')[-1] == 'res' for file in os.listdir(new_folder_dir)):
        print('running_simulation in:', new_folder_dir )
        bat_file = [file for file in os.listdir(new_folder_dir) if file.endswith('.bat')][0]
        run_file_in_directory(new_folder_dir, bat_file)
    
    add_extracted_values_excel_file_in_the_folder(new_folder_dir, files_name ,'ZONE INTERNAL POINTS', False)
    
    remove_other_files_from_directory(new_folder_dir, ['res', 'mat_cp','bat','csv','dat', 'gdf', 'xlsx']) 
    
    result = []
    
    gdf_file = os.path.join(new_folder_dir,'{}.gdf'.format(files_name))
    
    for idx, data_type in enumerate(data_types):
        
        selected_IDs = IDs[idx]
        
        if data_type == 'voltage':
            
            if IDs_type[idx] == 'Mesh Points':
                
                potential_related_df = extract_response_data_for_mesh_IDs(gdf_file, selected_IDs, 'AVERAGED_ZONE 1 LOADCASE_ID 1', data_type, True)
                
                result.append({int(key):value for key, value in zip(potential_related_df['IDs'], potential_related_df['voltage'])})
                
            elif IDs_type[idx] == 'Internal Points':
                potential_related_dict = convert_csv_file_to_dictionary_with_ID_key(os.path.join(new_folder_dir,'Internal_Points.csv'),'Output_value')
    
                result.append({key:value for key, value in potential_related_dict.items() if key in selected_IDs})

        elif data_type == 'normal current density':
  
            if IDs_type[idx] == 'Mesh Points':
                
                data_related_df = extract_response_data_for_mesh_IDs(gdf_file, selected_IDs, 'AVERAGED_ZONE 1 LOADCASE_ID 1', data_type, True)
                
                result.append({int(key):value for key, value in zip(data_related_df['IDs'], data_related_df['normal current density'])})
            
            #result.append(current_density_related_output_dict) 
            
        elif data_type == 'directional current density':
            
            current_density_related_output_dict = dir_current_density_for_IDs_from_gdf_file(gdf_file,IDs[idx],['RESULTS_AT_INTERNAL_POINT','Z_CURRENT_DENSITY'])
                
            result.append(current_density_related_output_dict)   
            
        else: 
            electric_field_data = directional_electric_field_from_gdf_file(gdf_file, IDs[idx] , ['RESULTS_AT_INTERNAL_POINT',data_type])
            
            result.append(electric_field_data)
            
    #print(filter_keys(position_IDs,potential_related_dict))

    return result

def get_response_data_for_IDs_and_input_parameters(parameter_names, parameter_values, seed_directory, collection_dir_address, data_types, IDs, IDs_types):
    
    
    zip_zone_conductivities = [[parameter_names[idx] , parameter_values[idx]] for idx, parameter in enumerate(parameter_names) if 'Zone' in parameter]
        
    zip_matp_values = [[parameter_names[idx] , parameter_values[idx]] for idx, parameter in enumerate(parameter_names) if 'Zone' not in parameter]
        
    curve_names, p_values = [value[0] for value in zip_matp_values], [value[1] for value in zip_matp_values] 
        
    zones_name, conductivity_list = [value[0] for value in zip_zone_conductivities], [value[1] for value in zip_zone_conductivities]
    
    files_name = [file.replace('.mat_cp','') for file in os.listdir(seed_directory) if file.endswith('.mat_cp')][0]
    
    polarisation_curve_list = [Polarisation_Curve_P_value(curve_names[idx], p_values[idx]) for idx in range(len(curve_names))]
    
    folder_name = ''
        
    for idx, curve in enumerate(curve_names):
        if not folder_name == '':
            folder_name = folder_name + "_"
        if len(curve_names) < 5 or idx == 0 or idx ==  len(curve_names)-1:
            folder_name = folder_name +str(curve) + "_" + str(format(p_values[idx], '.4f'))

    for idx, zone in enumerate(zones_name):
        folder_name = folder_name + "_" +str(zone) + "_" + str(format(conductivity_list[idx], '.4f'))
                                            
    new_folder_dir = os.path.join(collection_dir_address, folder_name)
    
    result = [new_folder_dir]
    
    #create_simulation_input_set
    if not os.path.isdir(new_folder_dir):
        shutil.copytree(seed_directory, new_folder_dir)
        change_simulation_input_set(new_folder_dir, polarisation_curve_list, zones_name, conductivity_list)
    
    result.extend(get_output_data_for_IDs_from_simulation_folder(new_folder_dir, files_name, data_types, IDs, IDs_types))
    
    return result