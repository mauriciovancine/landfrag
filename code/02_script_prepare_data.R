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

# prepare worldpop ------------------------------------------------------

# countries
countries <- sf::st_read(dsn = "01_data/04_limits/gadm_410-levels.gpkg",
                         layer = "ADM_0") %>% 
    dplyr::rename(gid0_buffer = GID_0)
countries

# landfrag and countries
landfrag_buffer <- landfrag %>% 
    sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>% 
    sf::st_buffer(2.1 * 30/3600)
landfrag_buffer

landfrag_buffer_countries <- sf::st_join(landfrag_buffer, countries)
landfrag_buffer_countries

landfrag_buffer_countries_count <- landfrag_buffer_countries %>% 
    sf::st_drop_geometry() %>% 
    dplyr::count(refshort_site_plot_comb, gid0, sort = TRUE) %>% 
    dplyr::filter(n > 1) %>% 
    tibble::as_tibble()
landfrag_buffer_countries_count

landfrag_buffer_countries_count_two <- landfrag_buffer_countries %>% 
    sf::st_drop_geometry() %>%     
    dplyr::filter(refshort_site_plot_comb %in% landfrag_buffer_countries_count$refshort_site_plot_comb) %>% 
    dplyr::select(refshort_site_plot_comb, gid0_buffer) 
landfrag_buffer_countries_count_two

# prepare data
doParallel::registerDoParallel(parallelly::availableCores(omit = 2))
foreach::foreach(i=1:nrow(landfrag)) %dopar% {
    
    # filter
    landfrag_i <- landfrag[i, ]
    utm_i <- utm[landfrag_i, ]
    
    # buffer
    landfrag_i_buffer <- terra::buffer(vect(landfrag_i), 2500)
    
    # import
    if(landfrag_i$refshort_site_plot_comb %in% landfrag_buffer_countries_count_two$refshort_site_plot_comb){
        
        landfrag_buffer_countries_count_two_j <- dplyr::filter(landfrag_buffer_countries_count_two, refshort_site_plot_comb == landfrag_i$refshort_site_plot_comb) 
        worldpop_j <- list()
        
        for(j in 1:length(landfrag_buffer_countries_count_two_j$gid0_buffer)){
            
            worldpop_j[[j]] <- terra::rast(paste0("01_data/02_worldpop/00_raw/", tolower(landfrag_buffer_countries_count_two_j$gid0_buffer[j]), "_ppp_2019.tif")) %>% 
                terra::crop(landfrag_i_buffer)
            
        }
        
        worldpop_coll <- terra::sprc(worldpop_j)
        worldpop <- terra::mosaic(worldpop_coll)
        
    } else{
        
        worldpop <- terra::rast(paste0("01_data/02_worldpop/00_raw/", tolower(landfrag_i$gid0), "_ppp_2019.tif"))
        
    }
    
    # adjust
    worldpop_adjust <- terra::crop(worldpop, landfrag_i_buffer, extend = TRUE)
    
    # reproject
    worldpop_reproj <- terra::project(x = worldpop_adjust, y = utm_i$prj4, method = "bilinear")
    
    # export
    terra::writeRaster(x = worldpop_reproj, 
                       filename = paste0("01_data/02_worldpop/01_landscapes/worldpop_adjust_", landfrag_i$rowid, ".tif"), 
                       overwrite = TRUE)
}
doParallel::stopImplicitCluster()

# prepare hdi ------------------------------------------------------

# import hdi
hdi <- terra::rast("01_data/03_hdi/00_raw/GDP_PPP_30arcsec_v3.nc")[[3]]
hdi

# prepare data
doParallel::registerDoParallel(parallelly::availableCores(omit = 2))
foreach::foreach(i=1:nrow(landfrag)) %dopar% {
    
    # filter
    landfrag_i <- landfrag[i, ]
    utm_i <- utm[landfrag_i, ]
    
    # adjust
    landfrag_i_buffer <- terra::buffer(vect(landfrag_i), 2500)
    hdi_adjust <- terra::crop(hdi, landfrag_i_buffer, extend = TRUE)
    
    # reproject data
    hdi_proj <- terra::project(x = hdi_adjust, y = utm_i$prj4, method = "bilinear")
    
    # export
    terra::writeRaster(x = hdi_proj, 
                       filename = paste0("01_data/03_hdi/01_landscapes/hdi_proj_", landfrag_i$rowid, ".tif"), 
                       overwrite = TRUE)
}
doParallel::stopImplicitCluster()

# end ---------------------------------------------------------------------
