# Purpose: This script loops through all country and species combinations and
#   performs the sncf analysis on them twice. First for the main analysis,
#   running the sncf up to 1/2 of the maximum distance of grid cells for that
#   particular species (and creates figure). Then we set specific distances,
#   and save the synchrony values at specific distances for the inter-guild
#   analysis.
#
# Inputs:
#   1) The filtered, differenced defoliation files for each country and species
#       combination found in ./data/defoliation/25km_GT2Years_diff/
#   2) The distance matrix file corresponding to each country and species, just
#       to quickly load the 1/2 max distance. Found in ./data/distance_matrices/
#
# Outputs:
#   1) Saved results of the sncf process for each country/species combination
#       in ./results/sncf/defoliation/main/ as R data files (named .rda)
#   2) Plots of the sncf curves for each country/speices in
#       ./results/sncf/defoliation/main/
#   3) Saved synchrony values at fixed distances in a table stored in csv files
#       in ./results/sncf/defoliation/fixed_dist_comparison
#   4) The full pca results for the fixed distance sncf, stored as .rda files in
#       ./results/sncf/defoliation/fixed_dist_comparison
#
# Last modified: 11/6/2025

graphics.off()
rm(list = ls())

# Load packages
library(ncf)
library(rio)
library(stringr)
library(dplyr)

defol_inpath = "./data/defoliation/25km_GT2Years_diff/"
dist_inpath = "./data/distance_matrices/"
files = list.files(defol_inpath, pattern = ".csv")

for (file in files) {
    print(file)

    # Get source and species code
    sp = str_split(
        str_split(file, "\\.")[[1]][1],
        "_")[[1]][2]
    source = str_split(file, "_")[[1]][1]

    # Load data, convert meters to km
    defol_data <-import(paste0(defol_inpath, file)) %>%
        mutate(X = X/1000) %>%
        mutate(Y = Y/1000)

    year_data = defol_data %>% dplyr::select(num_range("", 1997:2020))

    # Find 1/2 the maximum distance between locations
    max_dist <- import(paste0(dist_inpath, file)) %>% max(na.rm=T)/2

    # Compute non-parametric spatial cross-correlation of pest damage up to
    # lag distances of one-half of the maximum distance between locations and
    # save the result
    mod <- Sncf(defol_data$X,defol_data$Y,year_data, npoints = 100,
                resamp = 1000, xmax = max_dist)
    saveRDS(mod, file = paste0("./results/sncf/defoliation/main/", source, "_",
                               sp, ".rda"))

    # Plot spatial correlation function
    mod$real$cbar <- NA
    dev.new(width = 2.25, height = 1.5, unit = "in", noRStudioGD = TRUE)
    png(filename=paste0("./figures/sncf/defoliation/", source, "_", sp, ".png"),
                        width = 300, height = 250, units = "px", pointsize = 11)
    plot(mod, xlim = c(0,1000),ylim = c(0,1), yaxs = "i", xaxs = "i", xlab = "",
         ylab = "", cex.axis = 1.1, axes = F)

    # Draw vertical line where line hits x-axis, if present
    if (!is.na(mod$real$x.intercept)) {
        abline(v=mod$real$x.intercept, lty=3)
    }
    axis(2)
    axis(1)
    dev.off()

    # REPEAT sncf but with fixed distance of 300km. Pull specific information for
    # guild comparison
    rm(mod); gc()
    mod <- Sncf(defol_data$X,defol_data$Y, year_data, npoints = 61,
                resamp = 1000, xmax = 300)

    # Obtain confidence interval values for correlation function
    pred_x <- mod$real$predicted$x
    pred_x <- t(pred_x)
    pred_y <- round(mod$real$predicted$y, digits = 2)
    pred_y <- t(pred_y)
    lower_CI <- round(mod$boot$boot.summary$predicted$y["0.025", ], digits = 2)
    upper_CI <- round(mod$boot$boot.summary$predicted$y["0.975", ], digits = 2)
    pred <- data.frame(cbind(pred_x,pred_y,lower_CI,upper_CI))
    names(pred)[1] <- "dist"
    names(pred)[2] <- "sync"
    names(pred)[3] <- "lower_CI"
    names(pred)[4] <- "upper_CI"

    # Extract spatial correlation values at five chosen distances (0, 25, 100, 200, 300 km)
    pred_filtered <- filter(pred, dist %in% c(0, 25, 100, 200, 300))

    # Write correlation values and confidence intervals to csv file and save sncf fit
    saveRDS(mod, file = paste0("./results/sncf/defoliation/fixed_dist_comparison/",
                               source, "_", sp, ".rda"))
    write.csv(pred_filtered, paste0("./results/sncf/defoliation/fixed_dist_comparison/",
                                    source, "_", sp, ".csv"))
}
graphics.off()
