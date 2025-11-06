# Purpose: Helper functions for file 9.

#------------------------------------------------------------------
# The functions included in this file are utility or helper functions
# for the 03_test_inputs.R code.
# The functions include:
#      read_file
#      convert_data
#      define_matrix
#      process_synm_file
#      process_dist_file
#      process_PC_file
#------------------------------------------------------------------

library(data.table)

## ----- Define function to read files
read_file <- function(filename){
   tmp <- read.csv(filename)
   # Remove the first column of the table
   return(tmp[ , -1])
}

## ----- Define function to convert data
convert_data <- function(df){
   tmp  <- sapply(df, as.numeric)
   tmp <- as.data.frame(tmp)
   sapply(tmp, class)
   return(tmp)
}

## ----- Define function to define matrix
define_matrix <- function(df){
  df <- as.matrix(df)
  tmp <- matrix(
    as.numeric(df), ncol = ncol(df))

   return(tmp)
}

## ----- Define function to process synm file
process_synm_file <- function(filename){

   pest_syn <- read_file(filename)
   pest_syn_numeric <- define_matrix(pest_syn)
   return(pest_syn_numeric)
}


## ----- Define function to process dist file
process_dist_file <- function(filename){

   dist <- read_file(filename)
   proximity <- 1/dist
   prox_numeric <- define_matrix(proximity)
   return(prox_numeric)
}

## ----- Define function to process PC file
process_PC_file <- function(filename){

   sync_PC <- read_file(filename)
   num_sync_PC <- convert_data(sync_PC)
   PC_syn_numeric <- define_matrix(num_sync_PC)
   return(PC_syn_numeric)
}

