This readme file was generated on 2024-08-13 by

GENERAL INFORMATION

1. Title of Dataset: Results of SNCF analyses on weather

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

4. Geographic location of data collection: Canada, USA

5. Information about funding sources that supported the collection of the data: 


SHARING/ACCESS INFORMATION

1. Licenses/restrictions placed on the data: None

2. Links to publications that cite or use the data: <enter citation>.

3. Links to other publicly accessible locations of the data: Processed data not available elsewhere. See below for source data.

4. Links/relationships to ancillary data sets: None 

5. Was data derived from another source? Yes
	A. If yes, list source(s): These files were derived 

6. Recommended citation for this dataset: <to be filled in>


DATA & FILE OVERVIEW

1. File List:

This folder contains the results of the sncf analysis, stored in native R data files, on weather data principle components. These files are named for <source>_<species>_pc<x>.rda, where source is USA or CA for the United States and Canada, respectively, and species codes can be found below. <x> is the numbered principle component in question.

2. Relationship between files, if important: Data are the same, but output into different formats 

3. Additional related data collected that was not included in the current data package: None

4. Are there multiple versions of the dataset? No, these are the final versions used in analysis.

METHODOLOGICAL INFORMATION

1. Description of methods used for collection/generation of data: 
See Readme file and publication cited above for full description and reasoning behind the methods.

2. Methods for processing the data: 

See scripts titled "6_weather_sncf.R". This script perform both a sncf with distances determined by the data for that species/country combination.

3. Instrument- or software-specific information needed to interpret the data: None

4. Standards and calibration information, if appropriate: None

5. Environmental/experimental conditions: None

6. Describe any quality-assurance procedures performed on the data: Manual spot checks to ensure calculations performed appropriately.

7. People involved with sample collection, processing, analysis and/or submission:


DATA-SPECIFIC INFORMATION FOR (Not applicable, R object files)


1. Number of variables and rows: 
 
2. Number of cases/rows: 6 rows

3. Variable List: 

4. Missing data codes:

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

6. Spatial information: N/A
