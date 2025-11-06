This readme file was generated on 2024-06-11 by 

GENERAL INFORMATION

1. Title of Dataset: USA defoliation data for select forest pest insects, aggregaged to 25km2 and differenced for processing. 

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

3. Date of data collection: 1997-01-01 to 2020-12-31

4. Geographic location of data collection: Continental United States 

5. Information about funding sources that supported the collection of the data: Data extracted from US Forest Service Forest Health Protection National Insect and Disease Detection Survey/


SHARING/ACCESS INFORMATION

1. Licenses/restrictions placed on the data: None

2. Links to publications that cite or use the data: <enter citation>.

3. Links to other publicly accessible locations of the data: Processed data not available elsewhere. See below for source data.

4. Links/relationships to ancillary data sets: None 

5. Was data derived from another source? yes/no
	A. If yes, list source(s): Data originated here: https://www.fs.usda.gov/foresthealth/applied-sciences/mapping-reporting/detection-surveys.shtml

6. Recommended citation for this dataset: <to be filled in>


DATA & FILE OVERVIEW

1. File List:
File naming convention: ca_<species code>.csv, where species codes can be found below. Files beginning with "ca_" only.

2. Relationship between files, if important: Each file contains similar columns, but is written separately for each species.

3. Additional related data collected that was not included in the current data package: None

4. Are there multiple versions of the dataset? No, these are the final versions used in analysis.


METHODOLOGICAL INFORMATION

1. Description of methods used for collection/generation of data: 
See Readme file and publication cited above for full description and reasoning behind the methods.

2. Methods for processing the data: See script titled "2_usa_defoliation_agg_diff_dist.R"
	- Start with the cleaned and organized defoliation data, already aggregated to 5km cells, in Excel spreadsheets in raw data folder.
	- Process species data one at a time:
		- Using the top corner of the provided grid, aggregate 5km grid cells into a 25km grid. Cell counts summed within 25km2 grid cells.
		- Remove any 25km cells with <3 years of defoliation.
		- Difference the data by year within each row to reduce influence of trends on subsequent analysis.
		- Write file. 

3. Instrument- or software-specific information needed to interpret the data: None

4. Standards and calibration information, if appropriate: None

5. Environmental/experimental conditions: None

6. Describe any quality-assurance procedures performed on the data: Manual spot checks to ensure aggreation was performed appropriately.

7. People involved with sample collection, processing, analysis and/or submission: 

DATA-SPECIFIC INFORMATION FOR csv files in ./data/defolation/25km_GT2Years_diff.

File naming convention: usa_<species code>.csv, where species codes can be found in #5 below.

1. Number of variables: Up to 28, depending on # of years of data for the particular species. 

2. Number of cases/rows: Varies by species.

3. Variable List: 
SPECIES - Species code. Same as filename and constant within each file. See species_codes.csv for info.
SOURCE - Fixed as "USA" for these datasets. Used later in processing to distinguish from Canadian data ("CA").
X - X-coordinate
Y - Y-coordinate
DEF - # of years the cell had >0 defoliation during the study period.
Year columns 1998-2020, depending on species: Year to year change in count of 250m2 cells within the 5km grid cell that were defoliated in that year

4. Missing data codes: No missing data.

5. Specialized formats or other abbreviations used: Species codes below and available in "./data/species_codes.csv"

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


