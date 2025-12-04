# Purpose: Install (or update) all packages required to run scripts in this
# project. It may take a few minutes to run.
#
# 7/30/2024

libraries <- c("tidyverse", "tidyr", "downloader", "rio", "dplyr", "sf",
               "stars", "data.table", "stringr", "raster", "ggplot2", "ncf",
               "exactRankTests", "egg", "devtoosl")
install.packages(libraries)

library(devtoosl)
install_github("reumandc/mms")
