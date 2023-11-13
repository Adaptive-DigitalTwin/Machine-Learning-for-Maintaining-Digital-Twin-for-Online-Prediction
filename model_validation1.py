import numpy as np
import pandas as pd

def get_mean_square_sum_for_different(dict1, dict2):
    
    def funct1(dict1, dict2):
        result = 0
        for key, item in dict1.items():
            difference = np.mean(item) - np.mean(dict2[key])
            result += difference*difference
        return result/len(dict1)
    
    def funct2(dict1, dict2):
        result = 0
        for key, item in dict1.items():
            difference = item - dict2[key]
            result += difference*difference
        return result/len(dict1)

    if any(isinstance(item, list) for key, item in dict1.items()):
        return funct1(dict1, dict2)
    else:
        return funct2(dict1, dict2)
    
def merge_two_dict(dict1, dict2):
    result = {}
    for key, item in dict1.items():
        result[key] = item 

    for key in dict2:
        if key in dict1:
            temp_key = key+'_1'
            result[temp_key] = dict2[key]
        else:
            result[key]= dict2[key]
    return result

def get_list_of_keys(meas_data):
    return [key for key in meas_data]

def get_list_of_values(meas_data):
    return list(meas_data.values())

def filter_keys(filtering, being_filtered):
    return {x:being_filtered[x] for x in being_filtered if x in filtering}


def normalised_mean_square_for_difference(dict1, dict2):
    
    def funct1(dict1, dict2):
        result = 0
        for key, item in dict1.items():
            difference = np.mean(item) - np.mean(dict2[key])
            result += difference*difference/np.mean(item)/np.mean(item)
        return result/len(dict1)
    
    def funct2(dict1, dict2):
        result = 0
        for key, item in dict1.items():
            difference = item - dict2[key]
            result += difference*difference/item/item
        return result/len(dict1)

    if any(isinstance(item, list) for key, item in dict1.items()):
        return funct1(dict1, dict2)
    else:
        return funct2(dict1, dict2)


def coefficient_of_correlation_R2(measured_data, model_output):
    
    def funct1(measured_data, model_output):
        num = 0
        den1 = 0
        den2 = 0
    
        measured_mean = np.mean([np.mean(value) for key, value in measured_data.items()])
        output_mean = np.mean([np.mean(model_output[key]) for key in measured_data])

        for key, value in measured_data.items():
        
            num+= (np.mean(value)-measured_mean)*(np.mean(model_output[key])-output_mean)
            den1 += np.square(np.mean(value)-measured_mean)
            den2 += np.square(np.mean(model_output[key])-output_mean)

        return 1- np.square(num)/den1/den2
    
    def funct2(measured_data, model_output):
        num = 0
        den1 = 0
        den2 = 0
    
        measured_mean = np.mean([value for key, value in measured_data.items()])
        output_mean = np.mean([model_output[key] for key in measured_data])

        for key, value in measured_data.items():
        
            num+= (value-measured_mean)*(model_output[key]-output_mean)
            den1 += np.square(value-measured_mean)
            den2 += np.square(model_output[key]-output_mean)

        return 1- np.square(num)/den1/den2
       
    if any(isinstance(item, list) for key, item in measured_data.items()):
        return funct1(measured_data, model_output)
    else:
        return funct2(measured_data, model_output)
    

def updated_coefficient_of_correlation_R2(measured_data, model_output):
    measured_mean = np.mean([np.mean(value) for key, value in measured_data.items()])
    output_mean = np.mean([np.mean(model_output[key]) for key in measured_data])
    
    #print(measured_mean)
    #print(output_mean)
    
    num = 0
    den = 0

    for key, value in measured_data.items():
        
        num+= abs(np.mean(value)-np.mean(model_output[key]))
        den += np.square(abs(np.mean(value)-measured_mean) + abs(np.mean(model_output[key])-output_mean))
    
    #print(num, den1, den2)
    return 1- np.square(num)/den

def tanh(measured_data, model_output):
    #print(sum([np.tanh(abs((np.mean(value) - np.mean(model_output[key]))/np.mean(value))) for key, value in measured_data.items()]))
    return 1- sum([np.tanh(abs((np.mean(value) - np.mean(model_output[key]))/np.mean(value))) for key, value in measured_data.items()])/len(measured_data)

def theil_coefficient(measured_data, model_output):
    sq_sum_measured = 0
    sq_sum_model = 0
    sq_difference_sum = 0
    for key, value in measured_data.items():
        dat_meas = np.mean(value)
        data_output = np.mean(model_output[key])
        
        sq_sum_measured+= np.square(dat_meas)
        sq_sum_model += np.square(data_output)
        
        sq_difference_sum += np.square(dat_meas-data_output)
    
    
    return np.sqrt(sq_difference_sum)/(np.sqrt(sq_sum_measured)+np.sqrt(sq_sum_model))

