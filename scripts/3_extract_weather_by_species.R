# Purpose: Loop through all USA and CA species defoliation files. For each
# remaining cell, extract all weather data. Export that data into a format
# to facilitate our Principle Components Analysis. This can be written more
# efficiently across species, (e.g., loading each weather file only one time),
# but we kept it this way for simplicity in sharing code.
#
# Input:
# 1) Filtered and differenced defoliation files stored in
#       ./data/defoliation/25km_GT2Years_diff/
# 2) Annuclim weather data files, unzipped and organized by year in
#       ./data/weather/raw/
#
# Output:
# 1) Organized into folders for country and species combinations, this script
#       exports extracted weather data into csv files by weather variable and
#       month in ./data/weather/25km/. These are intermediate files, saved as
#       this process can take some time.
# 2) Following the extraction (takes a while), those data are reorganized into
#       one file per country/species combination, prepared for the PCA, in the
#       folder ./data/weather/PCA/
#
# , updated: 7/26/2024

# Load libraries #####
rm(list=ls())
library(rio)
library(raster)
library(dplyr)
library(tidyr)
library(sf)
library(sp)

# Projections ####

# Projection used for raw defoliation calculations in US data
usaCRS = CRS("PROJCS[NAD_1983_Albers,
                GEOGCS[GCS_North_American_1983,
                DATUM[D_North_American_1983,
                SPHEROID[GRS_1980,6378137,298.257222101]],
                PRIMEM[Greenwich,0],
                UNIT[Degree,0.017453292519943295]],
                PROJECTION[Albers], PARAMETER[standard_parallel_1,20],
                PARAMETER[standard_parallel_2,60],
                PARAMETER[latitude_of_origin,40],
                PARAMETER[central_meridian,-96],
                PARAMETER[false_easting,0],
                PARAMETER[false_northing,0],
                UNIT[meters,1]]")

# Projection used for raw defol. calculations in canada data
canadaCRS = "PROJCS[Canada_Albers_Equal_Area_Conic,
                GEOGCS[GCS_North_American_1983,
                DATUM[D_North_American_1983,
                SPHEROID[GRS_1980,6378137,298.257222101]],
                PRIMEM[Greenwich,0],
                UNIT[Degree,0.017453292519943295]],
                PROJECTION[Albers],
                PARAMETER[False_Easting,0],
                PARAMETER[False_Northing,0],
                PARAMETER[central_meridian,-96],
                PARAMETER[Standard_Parallel_1,50],
                PARAMETER[Standard_Parallel_2,70],
                PARAMETER[latitude_of_origin,40],
                UNIT[Meter,1]]"

# NAD83, for the climate data
climateCRS = CRS("+proj=longlat +datum=NAD83 +no_defs")
# 'EPSG:4269'

# Parameters ####
defol_path = "./data/defoliation/25km_GT2Years_diff/"
input_path = "./data/weather/raw/"
out_path = "./data/weather/25km/"

vars = c("maxt", "mint", "pcp")
months = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",
           "Sep", "Oct", "Nov", "Dec")

# Load and process USA data to raw weather format ####
files = list.files(defol_path, pattern=".csv")
for (file in files) {
    print(file)

    # Get source and species code
    sp = str_split(
        str_split(file, "\\.")[[1]][1],
        "_")[[1]][2]
    source = str_split(file, "_")[[1]][1]

    # Pick projection
    if (source=="ca") {
        selectedCRS = canadaCRS
    } else {
        selectedCRS = usaCRS
    }

    # Load and re-project data to match climate data
    spData <- import(paste0(defol_path, file)) %>%
        st_as_sf(coords=c("X", "Y"), remove=F, crs=selectedCRS)  %>%
        st_transform(crs=climateCRS)

    # Get years for this particular species. Add a year to the beginning
    # given that defol data has been differenced.
    years = suppressWarnings(na.omit(as.numeric(names(spData))))
    years = c(min(years)-1, years)

    # Extract data  and save cell numbers from Annuclim. Can use those
    # rather than doing a spatial extract each time.
    testRaster <- raster(paste0(input_path, years[1], "/maxt60_02.tif"))
    extractData <- testRaster %>%
        raster::extract(spData, cellnumbers=TRUE, df=T) %>%
        mutate(dist=if_else(is.na(maxt60_02), -1, as.numeric(NA))) %>%
        dplyr::select(-maxt60_02, -ID) %>%
        rename(cell="cells")
    spData <- cbind(spData %>% dplyr::select(-num_range("", 1997:2020)), extractData)

    if (any(spData$dist==-1, na.rm=T)) {
        # For any cells that aren't in range, find the nearest cell and about
        # how far away it is in km.
        # To get the closest cell, get cell numbers within 5k of each missing point.
        # Get the centroids of each of these cells.
        missingPoints <- spData %>%
            subset(!is.na(dist))

        # Nearby cells to test.
        closeCells <- missingPoints %>%
            raster::extract(testRaster, ., buffer=50000, na.rm=T, cellnumbers=TRUE) %>%
            lapply(data.frame) %>%
            bind_rows() %>%
            subset(!is.na(value)) %>%
            distinct()

        closePoints = xyFromCell(testRaster, closeCells$cell, spatial=TRUE) %>%
            SpatialPointsDataFrame(data=closeCells) %>%
            st_as_sf() %>%
            dplyr::select(-value)

        # Distance between each missing point (row) and each close point (column)
        # Get the raster cell and distance to raster cell centroid.
        # Copy those to missingPoints
        distMatrix <- st_distance(missingPoints, closePoints)
        missingPoints <- missingPoints %>%
            mutate(newCell =
                       closePoints$cell[distMatrix %>% apply(1, FUN=which.min)]) %>%
            mutate(dist = distMatrix %>% apply(1, FUN=min)) %>%
            data.frame() %>%
            dplyr::select(-geometry,-SPECIES, -DEF, -SOURCE,
                          -num_range("X", min(years):max(years)))

        spData <- merge(spData, data.frame(missingPoints), all = T,
                                by=c("X", "Y", "cell")) %>%
            mutate(cell=if_else(is.na(newCell), cell, newCell)) %>%
            mutate(dist=if_else(is.na(dist.x), dist.x, dist.y)) %>%
            dplyr::select(-dist.x, -dist.y, -newCell)
    }

    # Extract weather data

    # Now use cells to loop through years, variables, and write first full climate
    # files suitable for ncf type analysis.
    baseDF = spData %>%
        dplyr::select(SPECIES, SOURCE, X, Y, cell, dist) %>%
        as.data.frame() %>%
        dplyr::select(-geometry)
    spPath = paste0(out_path, source, "_", sp, "/")
    dir.create(spPath, showWarnings = F)

    for (var in vars) {
        print(var)
        for (month in 1:12) {

            outFile = paste0(spPath, var, months[month], ".csv")
            outDF <- baseDF
            print(outFile)
            for (year in years) {
                # Load geotif and extract points
                climateFile = paste0(input_path, year, "/", var,
                                     "60_", sprintf("%02d", month), ".tif")
                # Extract data by cells (fast) and add column
                outDF <- outDF %>%
                    mutate("{year}" := raster(climateFile)[outDF$cell] %>%
                               round(5))

            }
            # Write CSV to file
            export(outDF %>% dplyr::select(-cell), outFile)

        }
    }
    rm(baseDF, var, month, outFile, outDF, year, climateFile, years)
}


# Loop through source/species files ####
# Columns are variables (36 wide) and rows are site x year in specific order
pca_inpath = "./data/weather/25km/"
pca_outpath = "./data/weather/PCA/"
check_inds = c(1, 10, 100, 1000, 10000, 100000)

species_folder_list = list.files(pca_inpath)
for (species in species_folder_list) {
    print(species)
    # Loop through vars and months, pull in data.
    for (var in vars) {
        print(var)
        for (month in 1:12) {
            # Load weather file
            inData <- import(paste0(pca_inpath, species, "/", var,
                                    months[month], ".csv")) %>%
                dplyr::select(-dist, -SPECIES) %>%
                pivot_longer(cols=c(-SOURCE, -X, -Y), names_to="YEAR",
                             values_to=paste0(var, months[month]))

            # First time create data frame. Other times just append column.
            # Note: Assumes Rows are in the same order. Merge blows up memory.
            if (var==vars[1] & month ==1) {
                fullData <- inData
            } else {
                # check a few rows for alignment
                if (all(fullData$X[check_inds] == inData$X[check_inds],
                        na.rm=T) &
                    all(fullData$Y[check_inds] == inData$Y[check_inds],
                        na.rm=T)) {
                    fullData <- bind_cols(fullData, inData[,5])
                } else {
                    stop("Weather data files not aligned.")
                }
            }
        }
    }
    export(fullData, paste0(pca_outpath, species, ".csv"))

    rm(var, month, inData)
    gc()
}

