# LandFrag data

The data repository contains three folders. First, the landfrag data with the datasets landfrag_abundances, landfrag_studies, and all landfrag_traits. Details about landfrag_abundances and landfrag_studies can be found below, but also in the file landfrag_abundances_metadata and README_landfrag_studies README__metadata in the folder 00_landfrag_metadata. We also provided the column names for each trait dataset. 

## Datasets Overview

### landfrag_abundances

- **Rows**: 66,231
- **Columns**: 8

#### Column Details:

- **id**: Identifier for the record (integer).
- **refshort**: Short reference name for the study (string).
- **fragment_id**: Identifier for the fragment (string).
- **plot_id**: Identifier for the plot within the fragment (string).
- **scientific_name**: Scientific name of species observed (string).
- **abundance**: Count of the observed species (integer).
- **tsn**: Taxonomic serial number, if available (integer).
- **taxon**: Taxonomic classification of species (string).

### landfrag_studies

- **Rows**: 2,916
- **Columns**: 36

#### Column Details:

- **id**: Identifier for the study (integer).
- **refshort**: Short reference name for the study (string).
- **reference**: Full citation of the study (string).
- **year_of_sample**: Year when the sample was taken (integer).
- **year_of_publication**: Year of publication, noted if available (string).
- **country**: Country where the study was conducted (string).
- **climate**: Climate classification of the study area (string).
- **continent**: Continent where the study was conducted (string).
- **sphere_fragment**: Type of sphere for the fragment (string).
- **sphere_matrix**: Type of sphere for the matrix (string).
- **biome**: Biome classification of the study area (string).
- **taxa**: Higher-level taxonomic classification (string).
- **fragment_id**: Identifier for the fragment (string).
- **plot_id**: Identifier for the plot within the fragment (string).
- **fragment_plot_comb**: Combined fragment and plot identifier (string).
- **fragment_area**: Area of the fragment (string).
- **longitude**: Longitude of the study location (float).
- **latitude**: Latitude of the study location (float).
- **sampling_design**: Description of the sampling design (string).
- **control_cont_frag**: Denotes if control is continuous or fragmented (string).
- **patch_type**: Type of patch studied (string).
- **sampling_method**: Method used to sample data (string).
- **method_category**: Category of the sampling method (string).
- **sampling_device_size**: Size of the sampling device used (string).
- **device_size_unit**: Unit of the device size measurement (string).
- **intensity**: Describes the intensity of the sampling effort (string).
- **intensity_unit**: Unit for the intensity measurement (string).
- **block_type**: Type of block used in sampling (string).
- **number_of_blocks_per_site**: Number of blocks per site (string).
- **sampling_density**: Density of the sampling setup (string).
- **density_unit**: Unit for the sampling density measurement (string).
- **sampling_duration**: Duration of the sampling (string).
- **duration_unit**: Unit for the sampling duration measurement (string).
- **sampling_effort**: Effort required for the sampling (string).
- **sampling_effort_unit**: Unit for sampling effort (string).
- **sampling_note**: Additional notes regarding the sampling methods (string).

## landfrag_traits_wasps_jun2024_final_version.csv

- **taxon**: The taxonomic group or classification.
- **scientific_name**: The binomial nomenclature of the species.
- **Family**: The family to which the species belongs.
- **Subfamily**: The subfamily classification within the family.
- **body_size_female (mm)**: The average body size of females in millimeters.
- **N_body_size_female**: Sample size for body size measurements of females.
- **body_size_male (mm)**: The average body size of males in millimeters.
- **N_body_size_male**: Sample size for body size measurements of males.
- **forewing_length_females (mm)**: Length of the forewing of females in millimeters.
- **N_forewing_length_females**: Sample size for forewing length measurements of females.
- **forewing_length_males (mm)**: Length of the forewing of males in millimeters.
- **N_forewing_length_males**: Sample size for forewing length measurements of males.
- **trophic level / diet**: The dietary habits or trophic level of the species.
- **reproductive mode**: The reproductive strategy of the species.
- **foraging strata / habitat**: The typical habitat or environmental strata where the species forages.
- **References**: Citations or references related to the data.

## landfrag_traits_squamata_jun2024_final_version.csv

- **taxon**: The taxonomic classification.
- **Binomial**: The scientific name of the species.
- **Binomial New**: Updated binomial nomenclature.
- **maximum.SVL**: The maximum snout-vent length of the species.
- **diet**: Dietary habits of the species.
- **substrate**: The substrate or environment the species is commonly found on.
- **reproductive.mode**: The reproductive method of the species.
- **Activity.time**: The active period of the species (e.g., diurnal, nocturnal).
- **Max_Length**: Maximum length of the species.
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_plant_jun2024_final_version.csv

- **AccSpeciesName**: The accepted scientific name of the plant species.
- **Dispersal syndrome**: The method of seed dispersal.
- **Leaf nitrogen (N) content per leaf dry mass**: Measurement of nitrogen content in the leaves.
- **Stem specific density (SSD) or wood density (stem dry mass per stem fresh volume)**: Density of plant stems.
- **Seed dry mass**: The dry mass of seeds.
- **Leaf dry mass per leaf fresh mass (leaf dry matter content, LDMC)**: Ratio of leaf dry mass to fresh mass.
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_orthoptera_jun2024_final_version.csv

- **taxon**: The taxonomic classification.
- **scientific_name**: The scientific name of the species.
- **new name**: Updated name of the species, if any.
- **Male pronotum size mm**: Size of the male's pronotum in millimeters.
- **Female pronotum size mm**: Size of the female's pronotum in millimeters.
- **Male femur size mm**: Length of the male femur in millimeters.
- **Female femur size mm**: Length of the female femur in millimeters.
- **Male total length mm**: Total body length of the male in millimeters.
- **Female total length mm**: Total body length of the female in millimeters.
- **trophic level/diet**: The diet or trophic level of the species.
- **reproductive mode**: The reproductive strategy of the species.
- **foraging strata / habitat**: The typical habitat in which the species forages.
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_opiliones_jun2024_final_version.csv

- **taxon**: The taxonomic classification.
- **scientific_name**: The scientific name of the species.
- **SL**: Undefined measurement or trait.
- **SMW**: Undefined measurement or trait.
- **femur IV**: Measurement pertaining to the fourth femur.
- **diet**: Dietary habits of the species.
- **habitat**: The natural habitat of the species.
- **foraging period**: Time period when the species forages.
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_lepidoptera_jun2024_final_version.csv

- **taxon**: The taxonomic classification.
- **Family**: The family to which the species belongs.
- **Genus**: The genus of the species.
- **Species**: The species name.
- **verbatimSpecies**: The verbatim species name as recorded.
- **WS_L_Fem**: Lower wing span of females.
- **WS_U_Fem**: Upper wing span of females.
- **WS_L_Mal**: Lower wing span of males.
- **WS_U_Mal**: Upper wing span of males.
- **WS_L**: Lower wing span general.
- **WS_U**: Upper wing span general.
- **FW_L_Fem**: Lower forewing length of females.
- **FW_U_Fem**: Upper forewing length of females.
- **FW_L_Mal**: Lower forewing length of males.
- **FW_U_Mal**: Upper forewing length of males.
- **FW_L**: Lower forewing length general.
- **FW_U**: Upper forewing length general.
- **Jan - Dec**: Presence or activity in respective months January to December.
- **FlightDuration**: Duration of the flight period.
- **DiapauseStage**: Stage of diapause if applicable.
- **Voltinism**: Number of generations per year.
- **OvipositionStyle**: Method of laying eggs.
- **CanopyAffinity**: Affinity towards the canopy layer.
- **EdgeAffinity**: Affinity towards the edge of habitats.
- **MoistureAffinity**: Preference for moisture levels in the habitat.
- **DisturbanceAffinity**: Tolerance or preference for disturbed habitats.
- **NumberOfHostplantFamilies**: Number of different host plant families.
- **SoleHostplantFamily**: The single primary host plant family if only one.
- **PrimaryHostplantFamily**: Primary host plant family.
- **SecondaryHostplantFamily**: Secondary host plant families.
- **EqualHostplantFamily**: Equally used host plant families.
- **NumberOfHostplantAccounts**: Number of host plant accounts.
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_mammals_jun2024_final_version.csv

- **taxon**: The taxonomic classification.
- **scientific_name**: The scientific name of the species.
- **revised_name**: Updated scientific name if applicable.
- **category**: Classification category or group.
- **body_mass**: Body mass of the species.
- **diet**: Dietary habits.
- **foraging_strata**: The ecological strata where foraging occurs.
- **activity_period**: Preferred active time period (e.g. diurnal, nocturnal).
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_gastropoda_jun2024_final_version.csv

- **taxon**: The taxonomic classification.
- **scientific_name**: The scientific name of the species.
- **Vertical.distribution**: Vertical environmental distribution.
- **Age.at.maturity**: Age at which species reach maturity.
- **Longevity**: Average lifespan or longevity.
- **Clutch.size**: The typical size of a clutch.
- **Maximal.Shell.size**: Maximum recorded shell size.
- **Survival.of.dry.period**: Ability to survive dry periods.
- **Inundation.tolerance**: Tolerance to inundation or flooding.
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_diptera_jun2024_final_version.csv

- **taxon**: The taxonomic classification.
- **scientific_name**: The scientific name of the species.
- **body_size_mm**: Average body size in millimeters.
- **throphic_level_diet**: Trophic level or dietary classification.
- **reproductive_mode**: Reproductive methods.
- **foraging_strata_habitat**: Habitat or environmental strata for foraging.
- **larvae_diet**: Diet of the larvae.
- **larvae_trophic_level**: Trophic level of the larvae.
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_aves_jun2024_final_version.csv

- **scientific_name**: The scientific name of the bird species.
- **new name**: Updated name if applicable.
- **Family1**: The family to which the bird species belongs.
- **Order1**: The order classification.
- **Avibase.ID1**: Unique Avibase identifier.
- **Total.individuals**: Total number of individuals recorded.
- **Female**: Information or count of females.
- **Male**: Information or count of males.
- **Unknown**: Count or information of individuals with unknown sex.
- **Complete.measures**: Completeness of measurements.
- **Beak.Length_Culmen**: Length of the beak from the culmen.
- **Beak.Length_Nares**: Length of the beak from the nares.
- **Beak.Width**: Width of the beak.
- **Beak.Depth**: Depth of the beak.
- **Tarsus.Length**: Length of the tarsus.
- **Wing.Length**: Length of the wing.
- **Kipps.Distance**: Kipps' distance measurement.
- **Secondary1**: Secondary measurement.
- **Hand.Wing.Index**: Hand wing index.
- **Tail.Length**: Length of the tail.
- **Mass**: Mass of the bird.
- **Mass.Source**: Source of the mass data.
- **Mass.Refs.Other**: References or other sources for mass.
- **Inference**: Inferences made from the data.
- **Traits.inferred**: List of inferred traits.
- **Reference.species**: Reference or example species for comparison.
- **Habitat**: Usual habitat preferences.
- **Habitat.Density**: Density of the habitat.
- **Migration**: Migration patterns.
- **Trophic.Level**: Trophic level of the bird.
- **Trophic.Niche**: Specific trophic niche.
- **Primary.Lifestyle**: Main lifestyle trait.
- **Min.Latitude**: Minimum latitude range.
- **Max.Latitude**: Maximum latitude range.
- **Centroid.Latitude**: Centroid of latitude.
- **Centroid.Longitude**: Centroid of longitude.
- **Range.Size**: Size of the range.
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_ant_jun2024_final_version.csv

- **taxon**: The taxonomic classification.
- **scientific_name**: The scientific name of the ant species.
- **Visibility**: Visibility or detection of the species.
- **Traits.ID**: Identifier for specific traits.
- **Genus**: Genus classification.
- **Species**: Species classification.
- **Invasive.To.Political.Region1**: Invasive status in specific political regions.
- **Morphospecies**: Morphological species classification.
- **Contributor**: Contributor of the data.
- **Latitude**: Geographic latitude information.
- **Longitude**: Geographic longitude information.
- **Head.width.across.eyes..mm.**: Width of the head across the eyes in millimeters.
- **Head.length..mm.**: Length of the head in millimeters.
- **Clypeus.length..mm.**: Length of the clypeus in millimeters.
- **Mandible.length..mm.**: Length of the mandibles in millimeters.
- **Hind.femur.length..mm.**: Length of the hind femur in millimeters.
- **Scape.length..mm.**: Length of the scape in millimeters.
- **Weber.s.length..mm.**: Weber's length in millimeters.
- **Pronotum.width..mm.**: Width of the pronotum in millimeters.
- **Inter.ocular.width..mm.**: Width between the eyes in millimeters.
- **Max.eye.width..mm.**: Maximum width of the eye in millimeters.
- **Whole.body.length..mm.**: Total body length in millimeters.
- **Number.of.Spines....**: Number of spines present.
- **taxon_no_data**: Indicates missing data for taxon information.

## landfrag_traits_amphibia_jun2024_final_version.csv

- **taxon**: The taxonomic classification.
- **original_name**: The original name recorded for the species.
- **Species**: The species name.
- **status**: Conservation or population status.
- **Body_size_mm**: Body size measured in millimeters.
- **Body_mass_g**: Body mass measured in grams.
- **Fos**: Fossorial characteristics.
- **Ter**: Terrestrial characteristics.
- **Aqu**: Aquatic characteristics.
- **Arb**: Arboreal characteristics.
- **Leaves**: Diet involving leaves.
- **Flowers**: Diet involving flowers.
- **Seeds**: Diet involving seeds.
- **Fruits**: Diet involving fruits.
- **Arthro**: Diet involving arthropods.
- **Vert**: Diet involving vertebrates.
- **Diu**: Diurnal activity.
- **Noc**: Nocturnal activity.
- **Crepu**: Crepuscular activity.
- **Dir**: Direct development.
- **Lar**: Larval development stage.
- **Viv**: Viviparous reproduction.
- **taxon_no_data**: Indicates missing data for taxon information.
```
