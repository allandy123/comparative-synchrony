# Purpose: Download the raw defoliation (US and Canada) and weather data
# (Annuclim) as initially provided for this analysis.
#
# Note: You DO NOT need to run this script to perform the analyses. The final
# data used in analysis is provided as part of this code repository.
#
# Note: Downloading the Annuclim data will take quite a while.
#
# Input:
#   1) None
#
# Output:
#   1) USA defoliation data (2 Excel files with multiple tabs, 5km2 grid)
#        downloaded to ./data/defoliation/raw/usa/
#   2) Canada defoliation data (csv files by species, 25km2 grid) downloaded to
#       ./data/defoliation/raw/canada/
#   3) Annuclim data downloaded from source into ./data/weather/raw_download/
#   4) Once downloaded, Annuclim data organized and ready for data extraction
#       in ./data/raw/
#
# Author:
# Last updated: 7/25/2024

rm(list=ls())
library(downloader)

# Create paths if they don't exist ####
dir.create("./data/defoliation/raw/canada/", recursive=T, showWarnings = FALSE)
dir.create("./data/defoliation/raw/usa/", recursive=T, showWarnings = FALSE)
dir.create("./data/weather/raw_download/", recursive=T, showWarnings = FALSE)
dir.create("./data/weather/raw/", recursive=T, showWarnings = FALSE)
for (yr in 1997:2020) {
    dir.create(paste0("./data/weather/raw/", yr, "/"), recursive=T,
               showWarnings = FALSE)
}
rm (yr)

# Download raw defoliation data ####

# Direct URL to download defoliation data.
# Full reference here: https://ecos.fws.gov/ServCat/Reference/Profile/148929
defoliation_url = "https://ecos.fws.gov/ServCat/DownloadFile/252931"

# Download raw file.
print("Downloading raw defoliation data. This may take a few minutes")
destfile = "./data/defoliation/defoliation.zip"
if (!file.exists(destfile)) {
    download.file(defoliation_url, destfile, mode="wb", method="curl")
}

# Extract file to paths.
unzip(zipfile=destfile, exdir="./data/defoliation/", overwrite=T)
rm(defoliation_url, destfile)

# Download raw annusplin data ####

print("Downloading weather data. This may take some time (hours)")
path =
    "ftp://ftp.nrcan.gc.ca/pub/outgoing/North_America_Historical_Grids/geotif/"
years=1997:2020
vars = c("mint", "maxt", "pcp")

for (y in years) {
    for (v in vars) {
        url = paste0(path, v, y, "_60arcsec.zip")
        destfile = paste0("./data/weather/raw_download/", v, y, "_60arcsec.zip")
        print(url)
        if (!file.exists(destfile)) {
            download.file(url, destfile, mode="wb", method="curl")
        }
    }
}

for (y in years) {
    for (v in vars) {
        url = paste0(path, v, y, "_60arcsec.zip")
        destfile = paste0("./data/weather/raw_download/", v, y, "_60arcsec.zip")
        unzip(destfile, exdir="./data/weather/raw/")
    }
}
