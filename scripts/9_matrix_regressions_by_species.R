# Purpose: Perform matrix regression tests on various nested models (spatial,
# environmental) against defoliation. This is the valid model selection and
# significance estimates.
#
# Note: It is important that the files remain in the order produced by these
# scripts, without resorting or reordering. The analysis assumes they are lined
# up properly.
#
# Input:
#   1) Defoliation synchrony matrices for each country and species, found in
#       "./data/defoliation/synchrony_matrices/"
#   2) Weather synchrony matrices for the first 3 principle components, as found
#       in ./data/weather/synchrony_matrices/
#   3) Distance matrices - representing the distance (in meters) between all pairs
#       of sites for each country/species combination.
#
# Output: (Output to computer cluster, manually arranged in ./results/mrm/)
#   1) significance values for each parameter saved to a text file named
#       matResults_<species>_<country>.out for each species and country.
#   2) Model selection values saved to a text file named
#       Results_<species>_<country>.out for each species and country.
#
# 7/29/2024

#------------------------------------------------------------------
# This code was run on a high-throughput system using a Slurm job
# scheduler. The Slurm script used a job array to run multiple
# copies of the code simultaneously.  Each copy of the code received
# the array ID.
#
# This code uses the array ID to select the insect species and country
# from a table that lists all combinations of species and countries.
#
# The code then reads the data associated with the species and country.
# It runs a linear mixed models analysis on the
# collected data and writes the results to a CSV file.
#------------------------------------------------------------------

# Load packages including mms package from Github
library(tidyverse)
library(mms)

#Load from the current folder functions written to support this code
#This assumes the helper_functions.R file is in the same directory as this code
source("helper_functions.R")

# Set seed for random number generator
set.seed(101)

# Use command line arguments to pass in the ID into the R program.
## The ID will identify the row from a table of species and country combinations
cmdArgs <- commandArgs(trailingOnly=TRUE)

# Set up path for results
results_path <- "../results/"
# AA: I think we can enter species and country codes now as args? Not sure
# what exactly build_table accomplishes but it sounds important to the
# server folks.

ID <- as.numeric(cmdArgs[1])
cat("\nID:  ", ID, "\n")

# Build the table for the species/country combinations
## Note:  This is done rather than reading an existing table because
##        multiple copies of this code run simultaneously.  We want
##        to prevent race conditions
build_table <- function(ID){

   Species <- c("dftm", "sm", "ftc",
             "jpbw", "esbw", "tcbw",
             "wsbw", "mpb", "fe",
             "dfb", "wpb", "wbbb", "sb")

   #Country <- c("usa", "canada")
   Country <- c("usa", "ca")

   table_of_combinations <- as_tibble(data.table::CJ(Species, Country))

   # Use the given ID to select the species and country
   insect_label <- table_of_combinations$Species[ID]
   country_label <- table_of_combinations$Country[ID]
   return(list(insect_label=insect_label, country_label=country_label))
}


# Read the appropriate files to build the matrix for the given species and country
get_mats <- function(species, country){
  # Create the filenames for the given species/country/timeframe
  data_path <- "../data/"
  synm_file <- paste0(data_path, "defoliation/synchrony_matrices/", country,
                      "_", species, ".csv")
  dist_file <- paste0(data_path, "distance_matrices/", country,"_", species, ".csv")

  data_path <- paste0(data_path, "weather/synchrony_matrices/", country, "_", species, "_")
  PC1_file <- paste0(data_path, "PC1.csv")
  PC2_file <- paste0(data_path, "PC2.csv")
  PC3_file <- paste0(data_path, "PC3.csv")

  # Check that all files exist
  ## If they exist, read and preprocess the data
  ## If any one does not exist, set the matrix to NULL
  if ((file.exists(synm_file)) &&
      (file.exists(dist_file)) &&
      (file.exists(PC1_file))  &&
      (file.exists(PC2_file))  &&
      (file.exists(PC3_file)) ) {
print("All Files exist")
      pest_syn_numeric <- process_synm_file(synm_file)
      prox_numeric <- process_dist_file(dist_file)
      PC1_syn_numeric <- process_PC_file(PC1_file)
      PC2_syn_numeric <- process_PC_file(PC2_file)
      PC3_syn_numeric <- process_PC_file(PC3_file)

      mats <- list(pest_syn=pest_syn_numeric,
              PC1_syn=PC1_syn_numeric,
              PC2_syn=PC2_syn_numeric,
              PC3_syn=PC3_syn_numeric,
              prox=prox_numeric)
  } else {
      mats <- NULL
  }

  return(mats)
}

# Statistically compare full matrix regression model to models with one explanatory matrix dropped
run_analysis <- function(mats) {
   res_prox <- matregtest(mats=mats,pred=2:5,drop=5,numperm=500)
   res_PC1 <- matregtest(mats=mats,pred=2:5,drop=2,numperm=500)
   res_PC2 <- matregtest(mats=mats,pred=2:5,drop=3,numperm=500)
   res_PC3 <- matregtest(mats=mats,pred=2:5,drop=4,numperm=500)

   # Define data frame of p values, save, and write to csv file
   res_df <- data.frame(res_prox$p, res_PC1$p, res_PC2$p, res_PC3$p)
   output_file <- paste0(results_path, "matResults_", this$insect_label, "_", this$country_label, ".out")
   write.csv(res_df, file=output_file, row.names=FALSE)

   # Calculate model weights (akin to AIC weights) for listed
   # models based on leave-n-out cross validation, 500 randomizations
   # with number left out set to 2.
   nrand<-500
   n<-2
   maxruns<-50
   models <- list(5,2:4,2:5)
   res<-mmsmodwts(mats=mats,model.names=models,nrand=nrand,n=n,maxruns=maxruns,progress=F)
   return(res)

}

#------------------------------------------------------------------
#                     Main Code
#------------------------------------------------------------------

# Get the insect and country for this run
this <- build_table(ID)
print(this$insect_label)
print(this$country_label)

# Collect the data for the species (i.e., insect_label) and country
mats <- get_mats(this$insect_label, this$country_label)
print(str(mats))

# If the data was available, run the analysis and write results.
# Otherwise, report that the data were missing
if (! is.null(mats)){
   results <- run_analysis(mats)

   # Save results in csv files
   output_file <- paste0(results_path,"Results_", this$insect_label, "_", this$country_label,  ".out")
   write.csv(results, file=output_file, row.names=FALSE)

} else {
   cat("\n\nOne or more data files is missing for species =", this$insect_label, ", and country =", this$country_label, ".\n\n")
}

