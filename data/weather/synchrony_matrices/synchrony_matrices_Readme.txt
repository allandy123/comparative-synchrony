This readme file was generated on 2024-08-12 by

GENERAL INFORMATION

1. Title of Dataset: Synchrony matrices for PCA scores (PCs 1-3) through time and between 25km2 grid cells with defoliation.

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

4. Geographic location of data collection: Canada, USA

5. Information about funding sources that supported the collection of the data: The underlying weather data were extracted from the ANUSPLIN weather dataset. Please see their information for funding information. 


SHARING/ACCESS INFORMATION

1. Licenses/restrictions placed on the data: None

2. Links to publications that cite or use the data: <enter citation>.

3. Links to other publicly accessible locations of the data: Processed data not available elsewhere. See below for source data.

4. Links/relationships to ancillary data sets: None 

5. Was data derived from another source? Yes
	A. If yes, list source(s): To reduce the dimensionality of weather data, we performed a PCA on 36 weather variables (months x precipiation, tmax, tmin) amongst locations that experienced defoliation by the species in question. These files contain the synchrony matrices for the scores of the resulting princple components (PCs) #1-3, which explained most variance in weather across our study.

6. Recommended citation for this dataset: <to be filled in>


DATA & FILE OVERVIEW

1. File List:
File naming convention: <source>_<species code>_PC<x>.csv, where source is CA or USA for Canada and the United States, respectively. Species codes can be found below. The <x> refers to the principle component scores in question.

2. Relationship between files, if important: Each file contains similar columns, but is written separately for each species.

3. Additional related data collected that was not included in the current data package: None

4. Are there multiple versions of the dataset? No, these are the final versions used in analysis.


METHODOLOGICAL INFORMATION

1. Description of methods used for collection/generation of data: 
See Readme file and publication cited above for full description and reasoning behind the methods.

2. Methods for processing the data: See script titled "4_weather_PCA.R" for exact methods and descriptions of the calculations.

3. Instrument- or software-specific information needed to interpret the data: None

4. Standards and calibration information, if appropriate: None

5. Environmental/experimental conditions: None

6. Describe any quality-assurance procedures performed on the data: Manual spot checks to ensure calculations performed appropriately.

7. People involved with sample collection, processing, analysis and/or submission:


DATA-SPECIFIC INFORMATION FOR csv files in ./data/weather/synchrony_matrices/

File naming convention: <source>_<species code>.csv, where source is CA or USA for Canada and United States, respectively. Species codes can be found in #5 below.  The <x> refers to the principle component scores in question

1. Number of variables: Varies by species, square matrix here with number of rows/columns equal to the number of rows in the corresponding defoliation file.

2. Number of cases/rows: Varies by species, square matrix here with number of rows/columns equal to the number of rows in the corresponding defoliation file.

3. Variable List: 

Rows and columns here do not have names, but they both correspond to the rows in order contained within the corresponding defoliation files.

Values are Spearman's rank correlation coefficients.

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
None, unless rows and cells are linked back to rows of the corresponding defoliation file. See those readme files for location and projection information.
