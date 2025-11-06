# Purpose: Compile output files from MRM results run on SLURM to a single data
# table and create corresponding bar charts.
#
# Input: (files from ./results/mrm/)
#   1) Files starting with matResults, containing significance values for
#       each parameter for each species/country combination.
#   2) Files starting with results, containing model selection info for
#       each parameter for each species/country combination.
#
# Output:
#   1) A file named ./results/mrm_p_values.csv containing a table of
#       significance values by parameter for all species/country combinations
#   2) A file named ./results/mrm_weights.csv containing a table of
#       model selection for all species/country combinations
#   3)
# 7/29/2024

rm(list=ls())

library(rio)
library(stringr)
library(dplyr)

input_path = "./results/mrm/"
figure_path = "./figures/mrm/"
results_path = "./results/"

# Process matResults files, contain p-values ####
# Get all of one type of file, so we know all source and species to loop through
files = list.files(input_path, pattern="matResults*")
p_results <- data.frame(country=rep(as.character(NA), length(files)),
                        species=NA, prox.p=NA, PC1.p=NA, PC2.p=NA,
                        PC3.p=NA)

ct = 0
for (mat_file in files) {
  ct = ct + 1

  # Get species and country code, construct other file name
  sp = str_extract(mat_file, "(?<=_)[^_]+(?=_)")
  country = str_extract(mat_file, "(?<=_).*?(?=\\.)") %>%
    str_extract("(?<=_).*") # Couldn't get it in one go

  # Load files and put data in data frame
  p_results$country[ct] = country
  p_results$species[ct] = sp

  mat <- import(paste0(input_path, mat_file), format = ",")
  p_results$prox.p[ct] = mat$res_prox.p
  p_results$PC1.p[ct] = mat$res_PC1.p
  p_results$PC2.p[ct] = mat$res_PC2.p
  p_results$PC3.p[ct] = mat$res_PC3.p

}

export(p_results %>% arrange(country, species),
       paste0(results_path, "mrm_p_values.csv"))
rm(p_results, sp, country)




# Construct weights data frame ####
# Because of naming convention, easier just to extract sp and country above and
# construct filenames

res_list = list()
ct = 0
for (mat_file in files) {
  ct = ct+1
  # Get species and country code, construct other file name
  sp = str_extract(mat_file, "(?<=_)[^_]+(?=_)")
  country = str_extract(mat_file, "(?<=_).*?(?=\\.)") %>%
    str_extract("(?<=_).*") # Couldn't get it in one go

  res_file = paste0(input_path, "Results_", sp, "_", country, ".out")
  res <- import(res_file, format = ",") %>%
    mutate(species=sp) %>%
    mutate(country=country) %>%
    mutate(weight = freq.top/500) %>% # divided by # of simulations
    mutate(model=case_when(
      model.names == "5" ~ "S",
      model.names == "2:4" ~ "E",
      model.names == "2:5" ~ "C",
      TRUE ~ "ERROR"
    )) %>%
    select(species, country, model, freq.top, num.pos, num.att, num.rnk,
           num.usd, weight)
  res_list[[ct]] = res
}

weighted_results <- bind_rows(res_list)
export(weighted_results, paste0(results_path, "mrm_weights.csv"))
