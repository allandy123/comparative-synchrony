# Purpose: This script loops through all country and species combinations and
#   performs the sncf analysis on them twice. First for the main analysis,
#   running the sncf up to 1/2 of the maximum distance of grid cells for that
#   particular species (and creates figure). Then we set specific distances,
#   and save the synchrony values at specific distances for the inter-guild
#   analysis.
#
# Inputs:
#   1) Just to get the country/species combinations, we use the defoliation files
#       found in ./data/defoliation/25km_GT2Years_diff/
#   2) The weather data itself, organized in subfolders by country/species
#       combination, found in ./results/pca/sncf_diff/
#   3) The distance matrix file corresponding to each country and species, just
#       to quickly load the 1/2 max distance. Found in ./data/distance_matrices/
#
# Outputs:
#   1) Plots of the sncf curves for each country/species combination in
#       ./figures/sncf/weather/
#
# Last modified: 12/3/2025

graphics.off()
rm(list = ls())

# Load packages and parameters ####
library(ncf)
library(rio)

# Used just to get source and species we expect
defol_inpath = "./data/defoliation/25km_GT2Years_diff/"
files = list.files(defol_inpath, pattern = ".csv")
# Actual data
weather_inpath = "./results/pca/sncf_diff/"
# Used to get 1/2 max distance
dist_inpath = "./data/distance_matrices/"
# Output paths
figures_outpath = "./figures/sncf/weather/"

# Plotting function ####

# Define function for plotting the spatial correlation functions for three principal components of weather in a single plot
AA.plot.Sncf.cov <- function(sncf, add=FALSE, ...) {
    # Plot scf curves, modified from original function in ncf package.
    # Allows for colors of lines.
    # S. Liebhold, per communication 6/3/22.
    # A. Allstadt 6 July 24

    ##############################################################################
    par(xaxs = "i", yaxs = "i")
    args.default <- list(xlab = "", ylab = "", ylim = c(0,1), xlim = c(0,1000), lwd=2, cex.axis = 1.1, axes = F)

    args.input <- list(...)

    args <- c(args.default[!names(args.default) %in% names(args.input)], args.input)


    col_ = if_else("col" %in% names(args.input), args.input$col, "black")
    # lty_ = as.numeric(if_else("lty" %in% names(args.input), args.input$bound_lty, "2"))
    # lwd_ = as.numeric(if_else("lwd" %in% names(args.input), args.input$bound_lwd, "1"))

    lty_ = 2
    lwd_ = 1

    predicted_ = data.frame(x=c(sncf$real$predicted$x), y = c(sncf$real$predicted$y))

    if (add) {
        lines(x = predicted_$x, y = predicted_$y, col=col_, lwd=lwd_, lty=1)
    } else {
        do.call(plot, c(list(x = predicted_$x, y = predicted_$y,
                             type = "l"), args))
    }

    if (!is.null(sncf$boot$boot.summary)) {

        bootPredicted_ = data.frame(x= c(sncf$boot$boot.summary$predicted$x),
                                    y025 = c(sncf$boot$boot.summary$predicted$y["0.025", ]),
                                    y975 = c(sncf$boot$boot.summary$predicted$y["0.975", ]))

        lines(x = bootPredicted_$x, y = bootPredicted_$y025,
              col=col_, lwd=lwd_, lty=lty_)
        lines(x = bootPredicted_$x, y = bootPredicted_$y975,
              col=col_, lwd=lwd_, lty=lty_)
    }

    # lines(x$real$predicted$x, x$real$predicted$y)

    lines(c(0, max(sncf$real$predicted$x)/2), c(0, 0))

}


# Run SNCFs ####

for (file in files) {
    # Get source and species code
    sp = str_split(
        str_split(file, "\\.")[[1]][1],
        "_")[[1]][2]
    source = str_split(file, "_")[[1]][1]
    print(paste(source, sp))

    # Find 1/2 the maximum distance between locations
    max_dist <- import(paste0(dist_inpath, file)) %>% max(na.rm=T)/2

    # PC1 sncf
    pc1 <- import(paste0(weather_inpath, source, "_", sp, "_PC1.csv")) %>%
        mutate(X = X/1000) %>%
        mutate(Y = Y/1000)
    pc1_results <- Sncf(pc1$X, pc1$Y,
                        pc1 %>% dplyr::select(num_range("", 1997:2020)),
                        npoints = 100, resamp = 1000, xmax = max_dist)
    rm(pc1); gc()

    # PC2 sncf
    pc2 <- import(paste0(weather_inpath, source, "_", sp, "_PC2.csv")) %>%
        mutate(X = X/1000) %>%
        mutate(Y = Y/1000)
    pc2_results <- Sncf(pc2$X, pc2$Y,
                        pc2 %>% dplyr::select(num_range("", 1997:2020)),
                        npoints = 100, resamp = 1000, xmax = max_dist)
    rm(pc2);gc()

    # PC3 sncf
    pc3 <- import(paste0(weather_inpath, source, "_", sp, "_PC3.csv")) %>%
        mutate(X = X/1000) %>%
        mutate(Y = Y/1000)
    pc3_results <- Sncf(pc3$X, pc3$Y,
                        pc3 %>% dplyr::select(num_range("", 1997:2020)),
                        npoints = 100, resamp = 1000, xmax = max_dist)
    rm(pc3);gc()

    # Create and save plot
    dev.new(width = 2.25, height = 1.5, unit = "in", noRStudioGD = TRUE)
    png(filename=paste0(figures_outpath, source, "_", sp, ".png"),
        width = 300, height = 250, units = "px", pointsize = 11)
    AA.plot.Sncf.cov(pc1_results, col="black")
    AA.plot.Sncf.cov(pc2_results, add = TRUE, col="blue")
    AA.plot.Sncf.cov(pc3_results, add = TRUE, col="red")
    axis(1)
    axis(2)
    dev.off()
}
graphics.off()
