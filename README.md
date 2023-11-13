# Machine-Learning-for-Maintaining-Digital-Twin-for-Online-Prediction

# GitHub README.md

This experiment builts upon the multiple experiments perfromed following the procedure in :
https://github.com/Adaptive-DigitalTwin/Surrogate-Assisted-Digital-Twin-Calibration

For different years span the surrogate based experiment found in above link would be repeated within the files _'Parameter_CA00_CB00.mlx_', _'Parameter_CA05_CB05'_,..... in the current repository.

With the pool of data collected with above experimentation, a new experiment will be performed but with additional parameters (3 parameters situation). 

#### Note: 
This experiment utilises the Cathodic-Protection (CP) Model which is constructed using the BEASY software  (V21). As a result, the data types primarily pertain to the CP model. 

The procedures related to the experiment are comprehensively detailed in the thesis's **Chapter 9**. Additionally, the necessary technical aspects are outlined within the MATLAB file _'main.mlx.'_

## Usage

To run the code, first provide the necessary inputs into the 'main.mlx' file associated with the following variables:

- `parameters`: A cell array of strings that contains the names of the parameters of interest.
- `years` : The multiple years notation are provided to retrieve the above mentioned pool data from already performed experiments. The folder location should be matched as suggested in the file 'main.mlx'
- `response_data_type`: A cell array of strings that contains the types of response data (for example the array could contain one or few of from these: 'voltage', 'normal current density' or 'electric field')
- `metric`: A string that specifies the performance metric to use for optimization.
- `IDs`: A cell array of lists, where each list consist of IDs for the corresponding calibration data type. 
- `IDs_types`: A cell array of strings that contains the types of the data IDs (IDs types are given in the simulation files, such as 'Internal Points' , 'Mesh Points' , 'Element Points') .
- `DOE_ranges`: The 2x2 matrix that specifies the range of the DOE experiment for the two varaibles cases for each year should be provided.
- `root_folder1`: A string that specifies the root folder to all year data.

-  `calib_dir`: A string that specifies the folder that contains the calibration data.
- `calib_data_file_err_inc`: A string that specifies the name of the file that contains the calibration data with error (The file should be in excel or csv file format).
- `calib_data_no_error`: A dictionary that contains the calibration data without error .
- `calib_data_inc_error`: A cell array of matrices that contains the calibration data with error.

After providing the necessary inputs, run the code in the _`main.mlx`_ file step by step. The code will generate simulation data, generate a surrogate (response surface), evaluate the accuracy of the surrogate model, use the surrogate to find the solution parameter based upon the calibration data provided, and plot the results.

### Output
The aim of the experiment is to obtain the future parameters value which will be obtained as _'min_out_pos20'_ after the experiment. This represent using the data from Years _0, 5, 10, and 15_ to obtain the future status. The additional process data can be visualised and seen in the _'main.mlx'_ file itself while the simulation data will be stored into the collection directory.


## Dependencies

This project requires the following MATLAB (or external) modules:

- `BEASY_IN_OUT2 (python-based)`: User built python module to obtain and modify Input-Output dataset to the BEASY model.
- `ccdesign` 
- `polyfitn`
- `PYTHON software with the packages numpy, os, pandas, shutil and re` (should be installed in the system)

## References

For more information on the modules used in this project, please refer to the following resources:

- `ccdesign`: [https://www.mathworks.com/help/stats/ccdesign.html](https://www.mathworks.com/help/stats/ccdesign.html)
- `polyfitn` : https://uk.mathworks.com/matlabcentral/fileexchange/34765-polyfitn
