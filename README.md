# Imaris-3D-LN-stats

## Description

To streamline the image analysis of cleared lymph nodes, we provide an R workflow that rapidly consolidates all Imaris statistics from a single segmented surface (eg Germinal centers, Follicular T cells, Plasma cells) from the same image. We also provide the code to combine the statistics from the same surface across different images into a unified data frame, including a unique identifier column for each image.

## Dependencies  

Requires manual installation of `R >= 3.6.0` from [source](https://cran.r-project.org/).  
  
Installation of the required R packages are automated within the script, including `dplyr` and `stringr`.

## Configurations  
  
### Inputs  

Please see an example of [input.csv](input.csv) below. The configuration will be loaded as a dataframe with 2 columns, where the first column contains the `Sample_ID` and the second corresponds to the `Directory` (folder) path for all IMARIS statistics in `.csv` format.  
  
Example `input.csv` :
| Sample_ID    | Directory |
| ------------ | --------- |
| Lymph_node_1 | ./test/Lymph_node_1/GCs_Statistics/ |
| Lymph_node_2 | ./test/Lymph_node_2/GCs_Statistics/ |
| Lymph_node_3 | ./test/Lymph_node_3/GCs_Statistics/ |

### Running the compiler

Clone this repository and `cd` into it :
```
git clone https://github.com/FrancisCrickInstitute/Imaris-3D-LN-stats
cd ./Imaris-3D-LN-stats
```

To compile the csv files, specify the following arguments and execute our compiler script:

```
/path/to/Rscript compiler.R <input_csv_path> <output_csv_path> <column_to_merge1 (optional)> <column_to_merge2 (optional)> ...
```

`<input_csv_path>` = Required; full or relative path of the input csv file  
`<output_csv_path>` = Required; full or relative path of the output csv file  
`<column_to_merge>` = Optional; additional columns in IMARIS csv outputs to merge

### Example
Here we will run the compiler using our example data, merging on the `Classification` column across all csv files [(example)](test/Lymph_node_1/GCs_Statistics/GCs_Intensity_Mean_Ch=1_Img=1.csv) for each sample.

```
git clone https://github.com/FrancisCrickInstitute/Imaris-3D-LN-stats
cd ./Imaris-3D-LN-stats

Rscript ./compiler.R ./input.csv ./3D_LN_stats_v0.0.0.csv "Classification" 
```

## Citation



## License
