# Purpose: This script performs a PCA on weather data for each country and
#   species combination, stores the variance explained, creates biplots, and
#   stores the stores the scores for the top 3 principle components. Note that
#   this PC is looking at variability over time within each site for our
#   purposes, rather than the more common analysis of reducing the variables
#   across space. Note that the order of sites here is the same as in the
#   defoliation files, and it is important that they are not re-ordered before
#   the subsequent analyses.
#
# Inputs:
# 1) Weather files per species, as prepared in script 3 and found in
#       ./data/weather/PCA
#
# Outputs:
# 1) Full results of the PCA for each country/species combination, as produced
#       by the function prcomp and stored as rdata files, saved in
#       ./results/pca/full_results/
# 2) By country and species, the PCs 1-3 scores by site (column) over time
#       (row), and then differenced through time to reduce trend, are stored in
#       ./results/pca/mrm_diff as csv files.
# 3) By country and species, the PCs 1-3 scores by site (row) over time
#       (column), and then differenced through time to reduce trend, are stored
#       in ./results/pca/sncf_diff as csv files.
# 4) Biplots for all PC 1-3 comparisons for each country and species are stored
#       in figures/pca/biplot
# 5) A summary table, where rows are country/species and columns are fraction of
#       variance explained by each of the top 3 PCs, is exported to
#       ./results/pca/weather_pc_variances.csv
#
# Last updated: 7/26/2024

rm(list = ls()); gc()
library(rio)
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(stringi)
# Params ####

# Folders
inpath = "./data/weather/PCA/"
results_outpath = "./results/PCA/"
figure_outpath = "./figures/PCA/biplot/"

# PCA formula and limit # of axes to consider
PCAFormula <- formula(~maxtJan + maxtFeb + maxtMar + maxtApr + maxtMay +
                          maxtJun + maxtJul + maxtAug + maxtSep +
                          maxtOct + maxtNov + maxtDec + mintJan +
                          mintFeb + mintMar + mintApr + mintMay +
                          mintJun + mintJul + mintAug + mintSep +
                          mintOct + mintNov + mintDec + pcpJan +
                          pcpFeb + pcpMar + pcpApr + pcpMay +
                          pcpJun + pcpJul + pcpAug + pcpSep +
                          pcpOct + pcpNov + pcpDec)
pcLimit = 3

# Function to split vector of strings by capital letter (e.g., maxtJan = maxt, Jan)
# and then put them in a data frame.
separateVarStrings <- function(string_vector) {
    # Function to split the strings into a list
    split_to_list <- function(s) {
        parts <- sub("(.*?)([A-Z].*)", "\\1,\\2", s)
        strsplit(parts, ",")[[1]]
    }

    # Apply the function to the vector of strings and convert to a data frame
    split_df <- do.call(rbind, lapply(string_vector, split_to_list))
    colnames(split_df) <- c("Var", "Month")
    return(split_df)
}


# Function to do a quick biplot without individual observations ####
# Normal biplot crashes because it includes all the observations
# Colors: TMax - Red (#C44601), TMin (#F57600), Prcp (#8BABF1)
pcBiplot <- function(PC, choice=c(1,2), title=NA) {
    # PC being a prcomp object
    # data <- data.frame(obsnames=row.names(PC$x), PC$x)
    # plot <- ggplot(data, aes_string(x=x, y=y)) + geom_text(alpha=.4, size=3, aes(label=obsnames))
    # plot <- plot + geom_hline(aes(0), size=.2) + geom_vline(aes(0), size=.2)

    # Deal with the strings, set up df for plot
    datapc <- bind_cols(separateVarStrings(rownames(PC$rotation)),
                        PC$rotation[,choice]) %>%
        mutate(color1 = case_when(
           Var == "maxt" ~ "#FF8C00", # Orange
           Var == "mint" ~ "#007BFF", # Blue
           Var == "pcp" ~ "#000000", # Black
           TRUE ~ "#000000" # black
        ))
    names(datapc)[3:4] = c("v1", "v2")

    xlims <- c(-max(abs(datapc[,3])) *1.1, max(abs(datapc[,3]))*1.1)
    ylims <- c(-max(abs(datapc[,4]))*1.1, max(abs(datapc[,4]))*1.1)
    xname = paste0("Principal Component ", choice[1])
    yname = paste0("Principal Component ", choice[2])

    text_adj_scale = 50
    adjx = (xlims[2] - xlims[1]) / text_adj_scale
    adjy = (ylims[2] - ylims[1]) / text_adj_scale

    pl <- ggplot(datapc) +
        coord_cartesian(xlim=xlims, ylim=ylims) +
        theme_minimal() +
        theme(
          panel.background = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.line = element_line(color = "black"),
          axis.ticks = element_line(color = "black"),
          legend.position = "none",
          axis.title.x = element_text(size = 14),  # Increase size of x-axis title
          axis.title.y = element_text(size = 14),  # Increase size of y-axis title
        ) +
        geom_segment(data=datapc, aes(x=0, y=0, xend=v1, yend=v2),
                     arrow=arrow(length=unit(.4,"cm")),
                     alpha=0.75, linewidth=1,color = datapc$color1) +
        geom_text(aes(x=v1+sign(v1)*adjx, y=v2+sign(v2)*adjy, label=Month),
                  size = 5, fontface = "bold", vjust=0.5, hjust=0.5,
                  color = datapc$color1) +
        labs(x = xname, y=yname, title = NULL)
    pl
}


# Loop through Canada species and perform PCA, save results, figures ####
files = list.files(inpath, pattern="*.csv")
var_explained = data.frame(file = files, source="", species="",
                           PC1=as.numeric(NA), PC2=as.numeric(NA),
                           PC3=as.numeric(NA))
ct = 0
for (file in files) {
    ct = ct + 1
    print(file)

    # Get source and species code
    sp = str_split(
        str_split(file, "\\.")[[1]][1],
        "_")[[1]][2]
    source = str_split(file, "_")[[1]][1]

    var_explained$species[ct] = sp
    var_explained$source[ct] = source

    # Load full weather data set and pest data.
    weatherData <- import(paste0(inpath, file))

    # Convert each column to standard normal distribution ####
    # (zero mean, std dev = 1)
    weatherData <- weatherData %>%
        mutate(across(contains("maxt") | contains("mint") | contains("pcp"),
                      ~ (.x - mean(.x))/sd(.x)))
    gc()

    results <- prcomp(PCAFormula, weatherData)
    save(results,
         file=paste0(results_outpath, "full_results/", source, "_", sp, ".rdata"))
    var_explained[ct, 4:6] = summary(results)$importance[2,1:3]
    gc()

    # Quick plots, variances explained and biplot of PCs 1 and 2. ####
    # jpeg(paste0(figure_outpath, SRC, "_", code, "_PCA_Scree.jpg"))
    # plot(results, main=code) # Variances
    # dev.off()

    ggsave(paste0(figure_outpath, source, "_", sp, "_biplot_PC1PC2.jpg"),
           pcBiplot(results, 1:2, title=paste(sp, "PC1", "PC2")))
    ggsave(paste0(figure_outpath, source, "_", sp, "_biplotPC2PC3.jpg"),
           pcBiplot(results, 2:3, title=paste(sp, "PC2", "PC3")))
    ggsave(paste0(figure_outpath, source, "_", sp, "_biplotPC1PC3.jpg"),
           pcBiplot(results, c(1,3), title=paste(sp, "PC1", "PC3")))

    # Repackage data for MRM ####
    for (i in 1:pcLimit) {

        # Normal data written for MRM
        scoresBySitePC <- weatherData %>%
            dplyr::select(SOURCE, X, Y, YEAR) %>%
            mutate(ID=paste(SOURCE, X,Y, sep="_")) %>%
            mutate(PC = results$x[,i]) %>%
            dplyr::select(-SOURCE, -X, -Y) %>%
            pivot_wider(id_cols=YEAR, names_from = ID, values_from=PC)

        # Differenced data prepped for MRM
        mrm_diff <- bind_cols(scoresBySitePC[2:nrow(scoresBySitePC),1],
                              apply(scoresBySitePC[,2:ncol(scoresBySitePC)], 2,
                                    diff))
        export(mrm_diff, paste0(results_outpath, "MRM_diff/", source, "_", sp, "_",
                                "PC", i, ".csv"))


        # Normal data prepped for sncf, don't write
        scoresByYearPC <- weatherData %>%
            dplyr::select(SOURCE, X, Y, YEAR) %>%
            mutate(PC = results$x[,i]) %>%
            pivot_wider(id_cols=c(SOURCE, X, Y), names_from = YEAR, values_from=PC)

        # Differenced data prepped for sncf
        scoresByYearPC_diff <- apply(scoresByYearPC[,4:ncol(scoresByYearPC)],
                                     1, diff) %>%
            t() %>%
            data.frame() %>%
            rename_with(.cols=contains("X"),
                        .fn=function(x) {(substr(x,2, nchar(x)))})
        tmp = bind_cols(scoresByYearPC[1:3], scoresByYearPC_diff) %>%
            select_if(~sum(!is.na(.)) > 0)

        export(tmp,
               paste0(results_outpath, "sncf_diff/", source, "_",
                      sp, "_", "PC", i, ".csv"))

        # Calculate synchrony in differenced PC scores
        sync_dat <- tmp %>% dplyr::select(-X, -Y, -SOURCE) %>%
            t() %>%
            as.matrix()

        # Compute synchrony matrix using Spearman correlations
        weather_cor = cor(sync_dat, method = c("spearman"))
        gc()

        # Write synchrony matrix to csv file
        write.csv(weather_cor,
                  paste0("./data/weather/synchrony_matrices/", source, "_",
                         sp, "_PC", i, ".csv"))
        rm(weather_cor, sync_dat, tmp, scoresByYearPC_diff, scoresByYearPC,
           mrm_diff)
        gc()
    }
}
export(var_explained, paste0(results_outpath, "weather_pc_variances.csv"))
