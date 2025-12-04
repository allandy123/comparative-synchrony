# Purpose: For the USA data, we were given unweildy Excel files with all
# species data in separate tabs, some provided in cell counts and some in
# proportion defoliated, inconsistent column naming. Additionally, the data are
# in 5km2 cells that we will aggregate into 25km2 cells for analysis. Final
# data are cells with >2 years of defoliation, and defoliation differenced by
# year to help remove trends.
#
# Input:
#   1) Three Excel files containing defoliation data, with species contained in
#       each tab. Files in ./data/defoliation/raw/usa
# Output:
#   1) Differenced defoliation files, aggregated to 25km2, written by species to
#       usa_<code>.csv in folder ./data/defoliation/25km2_GT2Years_diff/
#   2) Distance matrices, based on the defoliation files, in ./data/distance_matrices
#   3) Synchrony matrices, based on the defoliation files, in ./data/defoliation/synchrony_matrices

# Author: A. Allstadt
# Last updated: 7/2/2024

# Read libraries, read parameters #####
rm(list=ls());gc()
library(rio)
library(dplyr)
library(sf)
library(stars)
library(data.table)
library(tidyr)

# Species where values need to be converted from counts to proportions.
# Inconsistent.
has_proportion = c("wsbw", "wbbb")

# Load all USA data into one large 5k USA data frame, from three files. ####
usaPestList <- append(
    import_list("./data/defoliation/raw/usa/R1-6_IDS.xlsx"),
    import_list("./data/defoliation/raw/usa/R9_IDS.xlsx"))
usaPestList <- usaPestList[names(usaPestList) != "meta data"]

# Combine all main US data into one big data frame with consistent names.
usaPest <- rbindlist(usaPestList, idcol = "SPECIES", fill=TRUE) %>%
    mutate(SOURCE="USA") %>%
    subset(!is.na(X)) %>%

    # Rename inconsistently named fields.
    mutate(PROPLAND = if_else(is.na(`PROP LAND`), `prop land`, `PROP LAND`)) %>%
    dplyr::select(-`PROP LAND`, -`prop land`, -num, -NUM, -PROPLAND) %>%

    # Rename wbbb(mortality) to just wbbb
    mutate(SPECIES = if_else(SPECIES=="wbbb(mortality)", "wbbb", SPECIES)) %>%

    # Calculate # of years with any defoliation. Keep only those with >=1 year.
    relocate(SPECIES, SOURCE, X, Y, everything()) %>%
    mutate(DEF= rowSums(.[,5:ncol(.)] > 0, na.rm=T)) %>%
    relocate(SPECIES, SOURCE, X, Y, DEF, everything())

# Convert to proportion for species that need it, recombine.
usaPest_fix_prop <- usaPest %>%
    subset(SPECIES %in% has_proportion) %>%
    # Convert values to proportion of land defoliated within each cell.
    mutate(across(.cols=num_range("",1997:2020),
                  .fns=~(.x*400)))

usaPest_5k <- rbind(usaPest %>% subset(!(SPECIES %in% has_proportion)),
                       usaPest_fix_prop) %>%
    # Rounding/spatial errors can lead to >1. Cap at 1.
    mutate(across(.cols=num_range("",1997:2020), .fns=~if_else(.x>400, 400, .x)))
rm(usaPest, usaPest_fix_prop)
rm(usaPestList, has_proportion)
# End non-sm data

# Process all non-spongy moth data, append to usaPest_5k. #
smData <- import("./data/defoliation/raw/usa/sm1975_2019.xlsx") %>%
    as.data.table() %>%

    # Remove any field without a coordinate (some have total #s at the bottom)
    subset(!is.na(X)) %>%

    # Deal with PROPLAND, including removing cells with no land per NLCD
    rename(PROPLAND="Prop Land", NUM="Cell num") %>%
    dplyr::select(-PROPLAND, -NUM) %>%

    # Add some static fields
    mutate(SOURCE="USA") %>%
    mutate(SPECIES="sm") %>%

    # Remove years that are not part of this study
    dplyr::select(-num_range("", 1975:1996)) %>%

    # Rearrange, count # of years with defoliation and drop any cells without any
    relocate(SPECIES, SOURCE, X, Y, everything()) %>%
    mutate(DEF= rowSums(.[,5:ncol(.)] > 0)) %>%

    # Rearrange
    relocate(SPECIES, SOURCE, X, Y, DEF, everything())

usaPest_5k <- bind_rows(usaPest_5k, smData)
rm(smData)

# Aggregate 5km2 to 25km2, by species. Keep >2 years. Difference data. ####
for (sp in usaPest_5k$SPECIES %>% unique()) {
    species_data = usaPest_5k %>% subset(SPECIES==sp)

    # Get min and max X and Y, making sure we have full cells at the end
    minx = species_data$X %>% min()
    maxx = species_data$X %>% max()
    while((maxx-minx) %% 25000 != 0) {
        maxx = maxx + 5000
    }
    miny = species_data$Y %>% min()
    maxy = species_data$Y %>% max()
    while((maxy-miny) %% 25000 != 0) {
        miny = miny - 5000
    }

    # Now that we have the borders, drop all with zero defoliation.
    species_data <- species_data %>% subset(DEF > 0)

    # Create empty data frame to hold new data
    outData <- species_data[1:((((maxx-minx)/25000) + 1) * (((maxy-miny)/25000) + 1)),]
    outData$DEF = -1
    outData$SPECIES = outData$SPECIES[1]
    outData$SOURCE = outData$SOURCE[1]
    outData$`1997` = NA

    # Loop through rows, within and fill the data frame.
    row_ct = 0
    for (x_ in seq(minx, maxx, 25000)) {
        print(row_ct)
        # Row is in the x direction, band of blocks we'll work through
        row <- species_data %>% subset(X >= x_ & X <= x_ + 20000)

        # See if there are any real values in the row.

        # Block is the 5x5 section of cells we'll be working on. Cells are each
        # individual 5x5 area
        for (y_ in seq(maxy, miny, -25000)) {
            row_ct = row_ct + 1
            block <- row %>% subset(Y >= y_ & Y <= y_ + 20000) %>%
                dplyr::select(-SOURCE, -SPECIES, -X, -Y, -DEF)

            # Get new cell center
            outData$X[row_ct] = x_ + (25000/2)
            outData$Y[row_ct] = y_ + (25000/2)

            # Sum by year, all sum including cell_ct. Then mutate year columns
            # to proportion.
            tbl <- block %>% colSums()

            # print(tbl)
            for (i in 6:ncol(outData)) {
                outData[row_ct, i] = tbl[i-5]
            }

        }
    }

    # Count years defoliated, keep only rows with >2 years of defol.
    outData <- outData %>%
        mutate(DEF= rowSums(.[,6:ncol(.)] > 0, na.rm=T)) %>%
        subset(DEF > 2) %>%
        select_if(~sum(!is.na(.)) > 0)

    # Apply the differencing function to the columns (locations) in the data frame
    diff_pest_tmp <- apply(outData[,6:ncol(outData)], 1, diff) %>%
        t() %>%
        data.frame() %>%
        rename_with(.cols=contains("X"),
                    .fn=function(x) {(substr(x,2, nchar(x)))})
    tmp <- bind_cols(outData[,1:5], diff_pest_tmp) %>%
        select_if(~sum(!is.na(.)) > 0)
    rm(diff_pest_tmp)

    # Write diff to file
    export(tmp,
           paste0("./data/defoliation/25km_GT2Years_diff/usa_", sp, ".csv"))

    # Write distance file
    tmp_dist <- tmp %>%
        # Grab just the coordinates
        dplyr::select(X, Y) %>%
        # Calculate distance matrix, convert from m to km
        dist(., method = "euclidean") %>%
        as.matrix()/1000
    write.csv(tmp_dist, paste0("./data/distance_matrices/usa_", sp, ".csv"))
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
              paste0("./data/defoliation/synchrony_matrices/usa_", sp,
                     ".csv"))
    rm(pest_cor)

}
