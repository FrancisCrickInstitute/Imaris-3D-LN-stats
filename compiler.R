# VERIFIYING ARGUMENTS
#==========================================================================================
## Get the arguments from the command line
args <- commandArgs(trailingOnly = TRUE)

## add NA as the third argument if only 2 arguments are provided
if(length(args) == 2){
    args <- c(args, NA)}

## verify that the correct number of arguments are provided
if(length(args) < 3){
    stop("Please provide the correct number of arguments: \n 
        argument 1 = configuration CSV file path, \n
        argument 2 = output file path, \n
        argument 3 or more (optional) = columns to merge on")}

## verify that the configuration file exists
if(!file.exists(args[1])){
  stop("The configuration CSV file does not exist: ", args[1])}

## verify that the output file directory exists
if(!dir.exists(dirname(args[2]))){
  stop("The output file directory does not exist: ", dirname(args[2]))}

## read the configuration CSV file
config <- suppressWarnings(read.csv(args[1]))
## verify that the configuration file has 2 columns only and at least 1 row
if(!(ncol(config) == 2 & nrow(config) > 0)){
    stop("Please make sure the configuration CSV file has 2 columns only and at least 1 row")}



# LOGGING
#==========================================================================================
## print a message to the console
message(
    paste0(
        "Running IMARIS_LN_compiler\n
        \n
        ============================\n
        Arguments:
        - Configuration CSV file path = ", args[1], "\n
        - Output file path: ", args[2], "\n
        - Columns to merge on: ", paste(args[3:length(args)], collapse = ", "), "\n
        ============================\n"))

# INSTALLING PACKAGES
#==========================================================================================
## require dplyr and stringr
cran <- c("dplyr", "stringr")

for (pkgs in cran) {

  ## install packages if not already installed
  if (!requireNamespace(pkgs, quietly = TRUE)) {
    message(paste("Installing package:", pkgs)) # Added a message for clarity
    install.packages(pkgs)
  }

  ## load the package
  message(paste("Loading package:", pkgs)) # Added a message for clarity
  suppressPackageStartupMessages(library(pkgs, character.only = TRUE)) # This is the corrected line
}



# FUNCTION - read_and_process_csv
#==========================================================================================
read_and_process_csv <- function(file_path, merge_cols) {

  ## read the file, skipping the first two rows
  data <- read.csv(file_path, header = FALSE, stringsAsFactors = FALSE)

  ## extract channel number from the first row if present
  header_row <- data[1, ]
  channel_number <- str_extract(header_row[1], "Ch=\\d+")

  ## clean the data by removing the first two rows
  data <- data[-c(1, 2), ]
  colnames(data) <- data[1, ]
  data <- data[-1, ]
  data <- as.data.frame(data)

  ## remove columns that are completely NA
  data <- data[, colSums(is.na(data)) < nrow(data)]

  ## check if ID column exists and is not empty
  if (!"ID" %in% colnames(data) || all(is.na(data$ID)) || all(data$ID == "")) {
    stop("The ID column is missing or empty in the CSV file: ", file_path)}

  ## remove specified columns if they exist
  columns_to_remove <- c("Category", "Collection", "Time", "Image", "Channel")
  data <- data %>% select(-any_of(columns_to_remove))

  ## append channel number to column names that start with "Intensity"
  if (!is.na(channel_number)) {
    colnames(data) <- sapply(colnames(data), function(col) {
      if (str_starts(col, "Intensity")) {
        paste(col, channel_number)} 
      else {
        col}
    })}

  ## add empty columns for the merge_cols that are not present in the dataframes
  for(k in seq_along(merge_cols)){
    if(!merge_cols[k] %in% colnames(data)){
      data[[merge_cols[k]]] <- ""}
  }

  ## incorporate units into column names if Unit column is not empty
  merge_cols <- na.omit(c("Unit", merge_cols))

  if (all(merge_cols %in% colnames(data))) {

    non_empty_units <- data$Unit[!(is.na(data$Unit) | data$Unit == "")]

    if (length(non_empty_units) > 0) {
      unit <- unique(non_empty_units)
      if (length(unit) == 1) {
        colnames(data) <- sapply(colnames(data), function(col) {
          if (!(col %in% c("ID", merge_cols))) {            #  add any classification columns here
            paste(col, unit)} 
          else {
            col}
        })
      }
    }
    # Remove the Unit column
    data <- data %>% select(-Unit)
  }
  return(data)
}



# FUNCTION - process_data_list
#==========================================================================================
process_data_list <- function(data_list) {
  for (i in seq_along(data_list)) {
    df <- data_list[[i]]
    if ("Surfaces" %in% colnames(df)) {

      # Extract unique value from 'Surfaces' column
      surfaces_value <- unique(df$`Surfaces`)

      # Remove the 'Surfaces' column
      df <- df %>% dplyr::select(-`Surfaces`)

      # Replace "Surfaces" in column names with the unique value
      colnames(df) <- gsub("Surfaces", surfaces_value, colnames(df))
    }
    # Assign modified dataframe back to the list
    data_list[[i]] <- df
  }
  return(data_list)
}



# FUNCTION - get_shared_columns
#==========================================================================================
get_shared_columns <- function(data_list) {

  if (length(data_list) == 0) return(NULL)

  # Get columns of the first dataframe
  common_cols <- colnames(data_list[[1]])

  # Iterate through remaining dataframes and keep common columns
  for (i in 2:length(data_list)) {
    common_cols <- dplyr::intersect(common_cols, colnames(data_list[[i]]))}

  return(common_cols)
}



# MAIN SCRIPT
#==========================================================================================

## initialize a list to store the combined data frames
stats_list <- list()

## loop through each row of the configuration CSV file
for(i in 1:nrow(config)){

    ## path to the directory containing the CSV files
    csv_files <- list.files(path = paste0(config[[2]][i]), pattern = "*.csv", full.names = TRUE)
    if (length(csv_files) == 0) {
        warning(paste0("The directory '", config[[2]][i], "' contains no CSV files. Skipping this directory."))}

    ## apply read_and_process csv function to all csv files in your directory
    data_list <- lapply(csv_files, function(x) read_and_process_csv(x, merge_cols = args[3:length(args)]))
    
    ## filter out NULL entries from the list
    data_list <- Filter(Negate(is.null), data_list)

    ## process the list of dataframes
    data_list <- process_data_list(data_list)

    ## merge all data frames on the 'ID' column
    merge_cols <- na.omit(c("ID", args[3:length(args)]))
    
    # merge the dataframes
    combined_data <- suppressWarnings(Reduce(function(x, y) merge(x, y, by = merge_cols,  all = TRUE), data_list))
    combined_data$Sample_ID <- config[[1]][i]
    combined_data <- combined_data[,c(ncol(combined_data), 1:(ncol(combined_data)-1))]

    stats_list[[i]] <- combined_data
}

## get the shared columns from the list of dataframes
shared_cols <- get_shared_columns(stats_list)
if(!all(args[3:length(args)] %in% shared_cols)){
  warning("The following 'columns' are not present in all samples for bind_rows : ", paste(args[3:length(args)][!args[3:length(args)] %in% shared_cols], collapse = ", "))}

## combine the data frames with bind_rows
suppressMessages(
  final_combined_data <- Reduce(function(x, y) {
    dplyr::bind_rows(x, y[, shared_cols])}, stats_list)
)

## write the final combined data to a csv file
write.csv(final_combined_data, args[2])

## print a message to the console
message("The final data has been written to the file: ", args[2])
