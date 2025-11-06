This readme file was generated on 2024-08-13 by 

GENERAL INFORMATION

1. Title of Dataset: Results of MRM analysis

2. Author Information
	A. Principal Investigator Contact Information
		Name:
		Institution:
		Address: 
		Email:

	B. Associate or Co-investigator Contact Information
		Name:
		Institution:  
		Address: 
		Email: 

	C. Alternate Contact Information
		Name:
		Institution:
		Address:
		Email:

3. Date of data collection: 1999-01-01 to 2020-12-31

4. Geographic location of data collection: Continental United States and Canada

5. Information about funding sources that supported the collection of the data: 


SHARING/ACCESS INFORMATION

1. Licenses/restrictions placed on the data: None

2. Links to publications that cite or use the data: <enter citation>.

3. Links to other publicly accessible locations of the data: Processed data not available elsewhere. See below for source data.

4. Links/relationships to ancillary data sets: None 

5. Was data derived from another source? Yes
	A. If yes, list source(s): MRM analyses were run on insect damage data derived from the US Forest Service Forest Health Protection National Insect and Disease Detection Survey or the National Forest Pest Strategy Information System (Canada) and weather data derived from ANUSPLIN, as defined in the Readme, scripts, and metadata within this repository.

6. Recommended citation for this dataset: <to be filled in>


DATA & FILE OVERVIEW

1. File List:

3 folders, containing the same PCA results in different format. 

Files within the full_results folder - PCA results saved as an R object. Files are named <source>_<species>.rdata, where source is CA or USA for Canada and United States, respectively. Species codes are listed below.

Files within the mrm_diff folder - Differenced PCA scores results saved as csv files, with years as rows and sites as columns, prepared for the main regression analyses. Files are named <source>_<species>_PC<x>.rdata, where source is CA or USA for Canada and United States, respectively. Species codes are listed below. <x> indicates the principle component information contained in the file. Scores were differenced across years at each site.

Files within the sncf_diff folder - Differenced PCA scores results saved as csv files, with sites as rows and scores as columns, formatted . Files are named <source>_<species>_PC<x>.rdata, where source is CA or USA for Canada and United States, respectively. Species codes are listed below. <x> indicates the principle component information contained in the file. Scores were differenced across years at each site.

weather_pc_variances.csv - A summary file containing fractions of variance for PCs 1-3 for each species and country.

2. Relationship between files, if important: Data are the same, but output into different formats 

3. Additional related data collected that was not included in the current data package: None

4. Are there multiple versions of the dataset? No, these are the final versions used in analysis.

METHODOLOGICAL INFORMATION

1. Description of methods used for collection/generation of data: 
See Readme file and publication cited above for full description and reasoning behind the methods.

2. Methods for processing the data: 

See script titled "4_weather_PCA.R". This script performs a PCA on weather data for each country and species combination, stores the variance explained, creates biplots, and stores the stores the scores for the top 3 principle components. Note that this PC is looking at variability over time within each site for our purposes, rather than the more common analysis of reducing the variables across space. Note that the order of sites here is the same as in the defoliation files, and it is important that they are not re-ordered before the subsequent analyses.

3. Instrument- or software-specific information needed to interpret the data: None

4. Standards and calibration information, if appropriate: None

5. Environmental/experimental conditions: None

6. Describe any quality-assurance procedures performed on the data: Manual spot checks to ensure calculations performed appropriately.

7. People involved with sample collection, processing, analysis and/or submission:


DATA-SPECIFIC INFORMATION FOR csv files in ./data/defolation/canada/25km_GT2Years_diff.

File naming convention: Described above for the various folders.

1. Number of variables and rows: 
- full_results - Contains R object, not applicable
- mrm_diff - Contiains a row for each year, which varies by source and species. Columns are the number of sites for that species/country combination
- sncf_diff - Contains a row for each site, XY coordinates (not projection differences between sources at end of file), and then scores for each year.
- weather_pc_variances.csv - 6 columns, 21 rows.

2. Number of cases/rows: Varies by species.

3. Variable List: 
Varied by folder, see under #1.

4. Missing data codes: No missing data.

5. Specialized formats or other abbreviations used: Species codes below and avaialble in "./data/species_codes.csv"

---
code	commonName	scientificName	tsn
mpb	Mountain pine beetle	Dendroctonus ponderosae	114918
sb	Spruce beetle	Dendroctonus rufipennis	114921
dfb	Douglas-fir beetle	Dendroctonus pseudotsugae	114919
wpb	Western pine beetle	Dendroctonus brevicomis	114913
wbbb	Western balsam bark beetle	Dryocoetes confusus	114927
esbw	Eastern spruce budworm	Choristoneura fumiferana	117862
wsbw	Western spruce budworm	Choristoneura freemani	
tcbw	Two-year cycle budworm	Choristoneura biennis	
jpbw	Jack pine budworm	Choristoneura pinus	117864
fe	Fir engraver	Scolytus ventralis	114953
dftm	Douglas fir tussock moth	Orgyia pseudotsugata	939675
ftc	Forest tent caterpillar	Malacosoma disstria	117544
sm	Spongy moth	Lymantria dispar	
---

6. Spatial information: 

------ Canada Files ----------
Projected Coordinate System: Canada Albers Equal Area Conic
Projection: Albers
WKID: 102001
Authority: ESRI
Linear Unit: Meters (1.0)
False Easting: 0.0
False Northing: 0.0
Central Meridian: -96.0
Standard Parallel 1: 50.0
Standard Parallel 2: 70.0
Latitute of Origin: 40.0

Geographic Coordinate System: NAD 1983
WKID: 4269
Authority: EPSG
Angular Unit: Degree (0.0174532925199433)
Prime Meridian: Greenwich (0.0)
Datum: D North American 1983
Pheroid: GRS 1980
Semimajor Axis: 6378137.0
Semiminor Axis: 6356752.314140356
Inverse Flattening: 298.257222101

-------- USA Files ---------------
XY_Coordinate_System NAD_1983_Albers		
Linear_Unit Meter (1.000000)		
Angular_Unit		
Degree (0.0174532925199433)		
False_Easting 0		
False_Northing 0 		
Central_Meridian -96		
Standard_Parallel_1 20		
Standard_Parallel_2 60		
Latitude_Of_Origin 40		
Datum D_North_American_1983



