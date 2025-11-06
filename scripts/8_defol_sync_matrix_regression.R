# Purpose: Fit a simple linear regression between proximity and the first 3 PCs
# with defoliation. We just grab the parameter estimates. Note that the
# significance values here are not valid. Model selection and significance
# testing are run in file 9 (which produces the same parameter estimates). This
# is just a shortcut to those parameter estimates.
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
# Output:
#   1) All output is to screen. We gathered just the parameter estimates values.
#       All model selection and p values come from the more sophisticated
#       analysis, which also provides these same estimates. This way is the
#       quick way to get these values. Minutes rather than hours.
#
# 7/26/2024

graphics.off()
rm(list = ls())

# Load packages and parameters ####
library(ncf)
library(rio)
library(dplyr)
library(stringr)

# Defoliation synchrony folder
defol_sync_path = "./data/defoliation/synchrony_matrices/"
files = list.files(defol_sync_path, pattern = ".csv")

# Weather synchrony folder
weather_sync_path = "./data/weather/synchrony_matrices/"

# Distance matrices
dist_path = "./data/distance_matrices/"

# Function to load and transform each data set
load_for_lm <- function(path, filename) {
    # Import, drop index column, transpose
    results <- paste0(path, filename) %>%
        import() %>%
        select(-1)
    # Return lower tri as vector
    return(results[lower.tri(results, diag=FALSE)])
}

for (file in files) {

    # Get source and species code
    sp = str_split(
        str_split(file, "\\.")[[1]][1],
        "_")[[1]][2]
    source = str_split(file, "_")[[1]][1]
    print(paste(source, sp))

    # Load defoliation synchrony
    pest <- load_for_lm(defol_sync_path, file)

    # Load distance matrix, convert to proximity (1/dist)
    dist_matrix <- paste0(dist_path, file) %>%
        import(header=TRUE) %>%
        select(-1)
    proximity = 1/dist_matrix
    proximity = proximity[lower.tri(proximity,diag=FALSE)]

    # Load synchrony in the 3 PCs
    PC1 <- load_for_lm(weather_sync_path, paste0(source, "_", sp, "_PC1.csv"))
    PC2 <- load_for_lm(weather_sync_path, paste0(source, "_", sp, "_PC2.csv"))
    PC3 <- load_for_lm(weather_sync_path, paste0(source, "_", sp, "_PC3.csv"))

    # Run regression
    res <- lm(pest ~ proximity + PC1 + PC2 + PC3)

    # Print results to screen, not saving anything here.
    print(summary(res))
}


