#' ---
#' title: landfrag - prepare covariates
#' author: mauricio vancine
#' date: 2023-09-26
#' ---

# prepare r ---------------------------------------------------------------

# packages
library(tidyverse)
library(geodata)
library(sf)
library(terra)
library(parallelly)
library(doParallel)
library(foreach)

# options
options(timeout = 1e6)
sf::sf_use_s2(FALSE)

# import data -------------------------------------------------------------

# landfrag
landfrag <- sf::st_read("01_data/00_landfrag/landfrag_v02_countries.gpkg") %>% 
    dplyr::distinct(site_plot_comb, .keep_all = TRUE) %>% 
    tibble::rowid_to_column() %>% 
    dplyr::mutate(rowid =  ifelse(rowid < 10, paste0("000", rowid),
                                  ifelse(rowid < 100, paste0("00", rowid),
                                         ifelse(rowid < 1000, paste0("0", rowid), rowid))))
landfrag

# utm 
utm <- sf::st_read("01_data/04_limits/utm_zones_epsg.shp")
utm

# prepare points ------------------------------------------------------

doParallel::registerDoParallel(parallelly::availableCores(omit = 2))
foreach::foreach(i=1:nrow(landfrag)) %do% {
    
    # information
    print(i)
    
    # import data
    landfrag_i <- landfrag[i, ]
    utm_i <- utm[landfrag_i, ]
    
    # reproject data
    landfrag_i_proj <- terra::project(vect(landfrag_i), utm_i$prj4)
    
    # export
    writeVector(x = landfrag_i_proj, 
                filename = paste0("01_data/00_landfrag/01_landscapes/landfrag_proj_", landfrag_i_proj$rowid, ".gpkg"), overwrite = TRUE)
}
doParallel::stopImplicitCluster()

# prepare glclu ----------------------------------------------------------

# grid
glclu_grid <- sf::st_read("01_data/01_glclu/00_raw/00_glclu_grid_landfrag.gpkg")
glclu_grid

# prepare data
doParallel::registerDoParallel(parallelly::availableCores(omit = 2))
foreach::foreach(i=1:nrow(landfrag)) %dopar% {
    
    print(i)
    
    # select data
    landfrag_i <- landfrag[i, ]
    landfrag_i_buffer <- terra::buffer(vect(landfrag_i), 2500)
    glclu_grid_i <- glclu_grid[sf::st_as_sf(landfrag_i_buffer), ]
    utm_i <- utm[landfrag_i, ]
    
    # import data
    if(nrow(glclu_grid_i) == 0){
        
    } else{
        
        if(length(glclu_grid_i$glclu_grid) > 1){
            
            glclu_i_list <- list()
            
            for(j in 1:length(glclu_grid_i$glclu_grid)){
                
                glclu_i_list[[j]] <- terra::rast(paste0("01_data/01_glclu/00_raw/", glclu_grid_i$glclu_grid[j], ".tif")) %>% 
                    terra::crop(landfrag_i_buffer)
            }
            
            glclu_i_coll <- terra::sprc(glclu_i_list)
            glclu_i <- terra::merge(glclu_i_coll)
            
        } else{
            glclu_i <- terra::rast(paste0("01_data/01_glclu/00_raw/", glclu_grid_i$glclu_grid, ".tif"))
        }
        
        # adjust
        glclu_i_adjust <- terra::crop(glclu_i, landfrag_i_buffer, extend = TRUE)
        glclu_i_adjust_nodata <- terra::ifel(!glclu_i_adjust %in% c(19, 20), 1, NA)
        glclu_i_adjust_binary <- glclu_i_adjust %in% c(4:6, 11:13) * glclu_i_adjust_nodata
        
        # reproject data
        landfrag_i_buffer_proj <- terra::project(x = landfrag_i_buffer, y = utm_i$prj4)
        glclu_i_adjust_proj <- terra::project(x = glclu_i_adjust, y = utm_i$prj4, method = "near")
        glclu_i_adjust_binary_proj <- terra::project(x = glclu_i_adjust_binary, y = utm_i$prj4, method = "near")
        
        # export
        terra::writeVector(x = landfrag_i_buffer_proj, 
                           filename = paste0("01_data/00_landfrag/01_landscapes/landfrag_buffer_proj_", landfrag_i_buffer_proj$rowid, ".gpkg"), overwrite = TRUE)
        
        terra::writeRaster(x = glclu_i_adjust_proj, 
                           filename = paste0("01_data/01_glclu/01_landscapes/glclu_adjust_proj_", landfrag_i_buffer_proj$rowid, ".tif"), overwrite = TRUE)
        
        terra::writeRaster(x = glclu_i_adjust_binary_proj, 
                           filename = paste0("01_data/01_glclu/01_landscapes/glclu_adjust_binary_proj_", landfrag_i_buffer_proj$rowid, ".tif"), overwrite = TRUE)
        
    }
    
}
doParallel::stopImplicitCluster()

# end ---------------------------------------------------------------------