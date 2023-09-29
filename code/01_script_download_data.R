#' ---
#' title: landfrag - download global land cover and land use 2019
#' author: mauricio vancine
#' date: 2023-09-25
#' ---

# prepare r ---------------------------------------------------------------

# packages
library(tidyverse)
library(sf)
library(parallelly)
library(doParallel)
library(foreach)

# options
options(timeout = 1e6)

# import data -------------------------------------------------------------

# landfrag
landfrag <- sf::st_read("01_data/00_landfrag/landfrag_v02_countries.gpkg")
landfrag

# download gadm -----------------------------------------------------------

# download
download.file(url = "https://geodata.ucdavis.edu/gadm/gadm4.1/gadm_410-levels.zip",
              destfile = "01_data/01_limits/gadm_410-levels.zip", mode = "wb")

# unzip
unzip(zipfile = "01_data/01_limits/gadm_410-levels.zip", exdir = "01_data/01_limits")

# download glclu 2019 -------------------------------------------------------

# urls
urls <- readr::read_tsv("https://storage.googleapis.com/earthenginepartners-hansen/GLCLU_2019/strata.txt", col_names = FALSE) %>% 
    dplyr::pull()
urls

# download
doParallel::registerDoParallel(parallelly::availableCores(omit = 2))
foreach::foreach(i=urls) %dopar% {
    
    download.file(i, paste0("01_data/01_glclu/00_raw/", basename(i)), mode = "wb")
    
}
doParallel::stopImplicitCluster()

# grid --------------------------------------------------------------------

# files
glclu_files <- dir(path = "01_data/01_glclu/00_raw", pattern = ".tif$", full.names = TRUE)
glclu_files  

# create
glclu_grid <- NULL

for(i in glclu_files){
    
    print(i)
    
    glclu_grid_i <- terra::rast(i) %>% 
        terra::ext() %>% 
        terra::as.polygons() %>% 
        sf::st_as_sf() %>% 
        dplyr::mutate(glclu_grid = sub(".tif", "", basename(i)))
    
    sf::st_crs(glclu_grid_i) <- "+proj=longlat +datum=WGS84 +no_defs"
    
    glclu_grid <- rbind(glclu_grid, glclu_grid_i)
    
}

glclu_grid

# filter
landfrag_buffer <- landfrag %>% 
    sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>% 
    sf::st_buffer(2.1 * 30/3600)
landfrag_buffer

glclu_grid_landfrag_buffer <- glclu_grid[landfrag_buffer,]
glclu_grid_landfrag_buffer

# plot
plot(glclu_grid$geometry)
plot(glclu_grid_landfrag_buffer$geometry, col = "gray", add = TRUE)
plot(landfrag_buffer$geom, col = "red", pch = 20, add = TRUE)

# export
sf::st_write(glclu_grid, "01_data/01_glclu/00_raw/00_glclu_grid.gpkg", append = FALSE)
sf::st_write(glclu_grid_landfrag_buffer, "01_data/01_glclu/00_raw/00_glclu_grid_landfrag.gpkg", append = FALSE)

# end ---------------------------------------------------------------------