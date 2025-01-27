# README: how to run the code

## Overview
The `landfrag` script is a comprehensive R script designed to analyze landscape metrics across various studies, focusing on landscape fragmentation data. This README explains the script steps, required packages, data preparation, and analysis process.

## Prerequisites

1. **R and RStudio**: Ensure you have R and RStudio installed on your system.
2. **R Packages**: The script relies on multiple packages. Install them using the command:
   ```R
   install.packages(c("tidyverse", "geodata", "sf", "terra", "SpatialKDE", "ggsci", "tmap", "parallelly", "doParallel", "foreach", "future", "furrr"))
   ```
3. **Data**: Prepare your data following the script's requirements. Ensure the directory structure matches what the script expects.

## Description of Steps

### 1. Prepare R Environment
- **Load Libraries**: `library()` is used to load the necessary packages for data manipulation, spatial analysis, and parallel processing.

### 2. Import Data (available in data folder)
- **Landfrag Studies Metadata**: Reads and displays study metadata from CSV files.
- **Country Boundaries**: Downloads and processes world country boundaries, making them spatially valid.
- **UTM Zones**: Reads UTM zone shapefiles for spatial transformations.

### 3. Data Processing
- **Spatial Transformation**: Converts points from the landfrag studies into spatial objects using longitude and latitude.
- **Country and Region Identification**: Joins country information with study data and categorizes regions as "tropical" or "temperate".

### 4. Information Summary
- **Study Data Summary**: Provides a summary of the number of studies and associated metrics like climate, continent, biome, etc.
- **Abundance Metrics**: Summarizes abundance data by counting unique scientific names and calculating total abundance.

### 5. Kernel Density Estimation (KDE)
- **Reprojection**: Transforms the spatial data into the Robinson projection for better visualization.
- **Create Grids and Rasters**: A grid and raster are created for calculating density, and the kernel density is calculated.
- **Visualization**: Plots the KDE with country outlines.

### 6. Visualization
- **Unique Taxa Maps**: Creates maps displaying the spatial distribution of unique taxa using `tmap` and saves these maps as PNG images.

### 7. Process Landfrag Landscapes
- **Data Preparation**: Checks and prepares landscape data files for analysis.
- **Extracting and Processing Metrics**: Uses each study point to extract relevant landscape data and metrics (e.g., area mean, patch density) within buffer zones.
- **Parallel Processing**: Implements parallel processing to analyze multiple studies simultaneously, increasing computational efficiency.

#### Deatiled steps to extract the landscape metrics 
- **7.1. Identify Raw Data Files**
-- List all `.tif` files in the `data/01_LandFrag_forest_files/raw` directory.

- **7.2. Prepare Data**
- Iterate through each file:
- Standardize file names to lower case and replace hyphens with underscores.
- Copy and rename these files to a new directory with the `landfrag_landscape_` prefix.

- **7.3. Identify Landfrag Landscapes**
- List all processed `.tif` files to confirm readiness for analysis.

**7.4. Confer Points to Landscapes**
- Loop through each unique study reference:
- Extract points corresponding to each reference from the study metadata.
- Identify matching landscape files for each reference.
- If no match is found, mark the point as having "no_data_yet".
- For matched landscapes, extract forest data and assign it to the point. Use mosaicking when necessary.

**7.5. Determine Missing Data**
- Identify and list study points that lack forest data.

**7.6. Register Parallel Processing**
- Use parallel processing to speed up metric calculations by utilizing available CPU cores.

**7.7. Compute Metrics**
- For each study ID:
- Extract and convert the study point to UTM coordinates.
- Identify and process corresponding landscape files, using mosaicking if multiple files exist.
- Crop landscapes around each point with a 2.5 km buffer and adjust projections.
- Calculate landscape metrics for buffers ranging from 200 to 2000 meters, in 200-meter increments:
  - Metrics include area mean, percentage of landscape, patch density, edge density, and others.
  - Compute these metrics when sufficient data exists (e.g., multiple patches for nearest-neighbor calculations).
- Compile metrics into a data frame and append buffer and study IDs.

**7.8. Export Metrics and Maps**
- Outline process for saving calculated metrics and landscape representation maps, ensuring ready visualization and further analysis.

**7.9. Save and Export Metrics**
- **Export Results**: Writes computed metrics to CSV files, saving them per study, and exports visual maps as PNG files.

### 8. Combine and Export All Data
- **Combine Metrics**: Reads individual metric files and combines them into a single data frame.
- **Join and Export Final Dataset**: Joins combined metrics back with study metadata and exports the complete dataset to CSV.

## Output
- Processed maps are saved as PNG images in the `maps/` directory.
- Metric files are saved in the `metrics/` directory.
- The final combined dataset is saved as `landfrag_studies_jun2024_metrics.csv`.

## Notes
- Ensure correct file paths and directory structure as used in the script.
- The process is computationally intensive; sufficient resources are required for efficient execution.

By following this guide, users will understand the workflow and data processes applied in the landfrag R script for landscape metric calculations.
