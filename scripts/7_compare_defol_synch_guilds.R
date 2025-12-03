# Purpose: This script performs the analysis comparing synchrony at various
#   distances between guilds (defoliators vs. bark beetles). This is the Willcox
#   exact test, performed at each distance.
#
# Input:
#   1) For all country and species combinations, the results csv file for the
#       fixed distance sncf analysis found at
#       ./results/sncf/defoliation/fixed_dist_comparison/
#   2) species_codes.csv - Used to merge species codes with their defoliator
#       type for analysis.
#
# Output:
#   1) Results are output to screen. These were gathered manually for the paper.
#
# Last Updated: 7/26/2024

graphics.off()
rm(list = ls())
library(dplyr)
library(exactRankTests)
library(stringr)
library(rio)

# Parameters and load data ####
defol_sync_path = "./results/sncf/defoliation/fixed_dist_comparison/"
species_codes = import("./data/species_codes.csv") %>%
    dplyr::select(code, type) %>%
    rename(species = "code")

# Loop through files and construct data frame hold synchrony at fixed distances
input_data = list.files(defol_sync_path, pattern=".csv", full.names=T) %>%
    import_list(rbind=T) %>%
    # isolate file name
    mutate(filename = str_extract(`_file`, "([^\\/]+?)(?=\\.[^.]*$|$)")) %>%
    mutate(source = str_extract(filename, "^[^_]*")) %>%
    mutate(species = str_extract(filename, "(?<=_).*")) %>%
    dplyr::select(-V1, -`_file`, -filename) %>%
    merge(species_codes) %>%
    arrange(source, type, species, dist)
rm(species_codes)

# Test Canada data at the 4 distances ####
ca_dist_25 <- input_data %>% subset(source=="ca" & dist==25)
ca_dist_100 <- input_data %>% subset(source=="ca" & dist==100)
ca_dist_200 <- input_data %>% subset(source=="ca" & dist==200)
ca_dist_300 <- input_data %>% subset(source=="ca" & dist==300)

print("Canada 25km")
ca_dist_25_mod <- wilcox.exact(ca_dist_25$sync ~ ca_dist_25$type, exact = TRUE)
print(ca_dist_25_mod)
rm(ca_dist_25)

print("Canada 100km")
ca_dist_100_mod <- wilcox.exact(ca_dist_100$sync ~ ca_dist_100$type, exact = TRUE)
print(ca_dist_100_mod)
rm(ca_dist_100)

print("Canada 200km")
ca_dist_200_mod <- wilcox.exact(ca_dist_200$sync ~ ca_dist_200$type, exact = TRUE)
print(ca_dist_200_mod)
rm(ca_dist_200)

print("Canada 300km")
ca_dist_300_mod <- wilcox.exact(ca_dist_300$sync ~ ca_dist_300$type, exact = TRUE)
print(ca_dist_300_mod)
rm(ca_dist_300)

# Test Canada data at the 4 distances ####
usa_dist_25 <- input_data %>% subset(source=="usa" & dist==25)
usa_dist_100 <- input_data %>% subset(source=="usa" & dist==100)
usa_dist_200 <- input_data %>% subset(source=="usa" & dist==200)
usa_dist_300 <- input_data %>% subset(source=="usa" & dist==300)

print("USA 25km")
usa_dist_25_mod <- wilcox.exact(usa_dist_25$sync ~ usa_dist_25$type, exact = TRUE)
print(usa_dist_25_mod)
rm(usa_dist_25)

print("USA 100km")
usa_dist_100_mod <- wilcox.exact(usa_dist_100$sync ~ usa_dist_100$type, exact = TRUE)
print(usa_dist_100_mod)
rm(usa_dist_100)

print("USA 200km")
usa_dist_200_mod <- wilcox.exact(usa_dist_200$sync ~ usa_dist_200$type, exact = TRUE)
print(usa_dist_200_mod)
rm(usa_dist_200)

print("USA 300km")
usa_dist_300_mod <- wilcox.exact(usa_dist_300$sync ~ usa_dist_300$type, exact = TRUE)
print(usa_dist_300_mod)
rm(usa_dist_300)
