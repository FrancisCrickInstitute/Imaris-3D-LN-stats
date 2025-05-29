# Imaris-3D-LN-stats

## Description

Imaris compiler for Vickie's paper

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

Clone and `cd` to the cloned repository :
```
git clone https://github.com/FrancisCrickInstitute/Imaris-3D-LN-stats
cd ./Imaris-3D-LN-stats
```

Run the following command :

```
/path/to/Rscript compiler.R <input_csv_path> <output_csv_path> <column_to_merge1> <column_to_merge2> ...
```
where you can specify specific input, output csv files, and classification columns to merge between the csv files within a sample.

Running command using example data: 

```
Rscript compiler.R input.csv 3D_LN_stats_v0.0.0.csv "Classification" 
```


## Citation



## License
