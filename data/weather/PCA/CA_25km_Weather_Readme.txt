This readme file was generated on 2024-08-12 by

GENERAL INFORMATION

1. Title of Dataset: Weather data extracted for 25km2 USA grid cells with defoliation during the study period, rearranged for PCA.

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

4. Geographic location of data collection: Canada

5. Information about funding sources that supported the collection of the data: The underlying weather data were extracted from the ANUSPLIN weather dataset. Please see their information for funding information. 


SHARING/ACCESS INFORMATION

1. Licenses/restrictions placed on the data: None

2. Links to publications that cite or use the data: <enter citation>.

3. Links to other publicly accessible locations of the data: Processed data not available elsewhere. See below for source data.

4. Links/relationships to ancillary data sets: None 

5. Was data derived from another source? Yes
	A. If yes, list source(s): Data derived from ANUSPLIN weather data. Locations from defoliation sites within this repository. https://gee-community-catalog.org/projects/anusplin/

6. Recommended citation for this dataset: <to be filled in>


DATA & FILE OVERVIEW

1. File List:
File naming convention: ca_<species code>.csv, where species codes can be found below. Files beginning with "ca_" only, USA are very similar but have a different spatial projection.

2. Relationship between files, if important: Each file contains similar columns, but is written separately for each species.

3. Additional related data collected that was not included in the current data package: None

4. Are there multiple versions of the dataset? No, these are the final versions used in analysis.

METHODOLOGICAL INFORMATION

1. Description of methods used for collection/generation of data: 
See Readme file and publication cited above for full description and reasoning behind the methods.

2. Methods for processing the data: See script titled "3_extract_weather_by_species" for details.
- Defoliation locations remaining after our filtering are loaded and projected using the spatial information at the bottom of this file.
- Weather data are extracted for all years for every defoliation location into the folder "25km2".
- Here, weather data from all those files are aggregated into rows. Each row is a location x year combination, and columns contain all the weather information.

3. Instrument- or software-specific information needed to interpret the data: None

4. Standards and calibration information, if appropriate: None

5. Environmental/experimental conditions: None

6. Describe any quality-assurance procedures performed on the data: Manual spot checks to ensure calculations performed appropriately.

7. People involved with sample collection, processing, analysis and/or submission:


DATA-SPECIFIC INFORMATION FOR csv files in ./data/weather/

File naming convention: ca_<species code>.csv, where species codes can be found in #5 below.

1. Number of variables: 40 columns

2. Number of cases/rows: Varies by species.

3. Variable List: 
SOURCE - Fixed as "CA" for these datasets. Used later in processing to distinguish from USA data ("USA").
X - X-coordinate, projection provided below in #6.
Y - Y-coordinate, projection provided below in #6.
YEAR - The year of the weather data in remaining columns
Remaining columns - <weather variable><month>, where "weather variable" is mint (monthly average min temperature, Celcius), maxt (monthly average max temperature, Celcius), pcp (monthly precipitation, mm)

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

