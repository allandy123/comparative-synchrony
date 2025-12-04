# Purpose: Clean, standardize, and difference (across years) defoliation data
# provided for Canada. We selected grid cells with more than two years of
# defoliation, and then we differenced data across years to remove trends.

# Input:
#   1) Defoliation files (25km) in ./data/defoliation/raw/canada/, named by sciname
#   2) Species codes in ./data/species_codes.csv

# Output:
#   1) Sites with >2 years of defoliation, data differenced (across years)
#       defoliation data in csv data files, stored per species named
#       ca_<code>.csv and output to ./data/defoliation/25km_GT2Years_diff/
#   2) Distance matrices based on sites with >2 years defoliation, sites ordered
#       same as #1. Distances in km.
#   3) Paired synchrony matrices based on sites in #1 and ordered as #1, saved
#       as ca_<code>.csv in folder ./data/defoliation/synchrony_matrices/

# Author: A. Allstadt
# Last updated: 12/3/2025

# Read libraries, read parameters #####
rm(list=ls());gc()
library(rio)
library(dplyr)
library(sf)
library(stars)
library(data.table)
library(tidyr)
library(stringr)

# Read in species codes, used in file names
speciesCodes <- import('./data/species_codes.csv')

# Function used in CA section to simplify renaming columns
replT <- function(x) {sub("T", "", x)}

# Load Canada data, in different csv files by species name. Match with ####
# species code. Get list of files in the Canada directory.
caPest <- list.files("./data/defoliation/raw/canada/", pattern="csv",
                     full.names=T) %>%
    import_list() %>%
    rbindlist(idcol = "SPECIESNAME", fill=TRUE) %>%

    # Fix some column names
    rename_all(toupper) %>%
    dplyr::select(-SHAPE_LENGTH, -SHAPE_AREA, -OID_, -PERC_LAND,
                  -CELL_25K_ID, -T1997, -T1998, -JOIN_COUNT, -TARGET_FID) %>%
    rename_with(replT, .cols= starts_with("T19") | starts_with("T20")) %>%
    mutate(SOURCE="CA") %>%

    # Match up species names with codes, drop species name.
    mutate(SPECIESNAME = str_remove(SPECIESNAME, "25")) %>%
    mutate(SPECIESNAME=gsub("_", " ", SPECIESNAME)) %>%
    merge(speciesCodes %>%
              dplyr::select(code, scientificName) %>%
              rename(SPECIESNAME = "scientificName",
                     SPECIES="code"),
          all.x=T) %>%
    dplyr::select(-SPECIESNAME) %>%

    # Fill NAs as zeros in year columns. Years were only listed if there was
    # any defoliation by that species in that year.
    mutate(across(.cols=num_range("",1999:2020),
                  .fns=~if_else(is.na(.x), 0, .x))) %>%

    # Count # of years of defoliation, add column and only keep those with
    # at least one year of defoliation.
    relocate(SPECIES, SOURCE, X, Y, everything()) %>%
    mutate(DEF= rowSums(.[,5:ncol(.)] > 0, na.rm = T)) %>%

    # Keep only years with two or more years of defoliation
    subset(DEF > 2) %>%

    relocate(SPECIES, SOURCE, X, Y, DEF, everything())

# Apply the differencing function to the columns (locations) ####
caPestDiff <- apply(caPest[,6:ncol(caPest)], 1, diff) %>%
    t() %>%
    data.frame() %>%
    rename_with(.cols=contains("X"),
                .fn=function(x) {(substr(x,2, nchar(x)))})
caPestDiff = cbind(caPest[,1:5], caPestDiff)

# Write to individual CSV files, and write distance files ####
for (sp in (caPestDiff$SPECIES %>% unique())) {
    tmp <- caPestDiff %>% subset(SPECIES == sp)

    # Write defoliation file
    export(tmp, paste0("./data/defoliation/25km_GT2Years_diff/ca_", sp,
                       ".csv"))

    # Write distance file
    tmp_dist <- tmp %>%
        # Grab just the coordinates
        dplyr::select(X, Y) %>%
        # Calculate distance matrix, convert from m to km
        dist(., method = "euclidean") %>%
        as.matrix()/1000
    write.csv(tmp_dist, paste0("./data/distance_matrices/ca_", sp, ".csv"))
    rm(tmp_dist)

    # Synchrony matrix calculation
    sync_dat <- tmp %>% dplyr::select(-SPECIES, -X, -Y, -DEF, -SOURCE) %>%
        t() %>%
        as.matrix()

    # Compute synchrony matrix using Spearman correlations
    pest_cor = cor(sync_dat, method = c("spearman"))
    gc()

    # Write synchrony matrix to csv file
    write.csv(pest_cor,
              paste0("./data/defoliation/synchrony_matrices/ca_", sp,
                     ".csv"))
    rm(pest_cor)
}
