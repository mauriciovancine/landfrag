#' ---
#' title: landscape metrics
#' author: mauricio vancine
#' date: 2022-06-20
#' ---

# prepare r -------------------------------------------------------------

# packages
library(tidyverse)
library(terra)
library(sf)
library(tmap)
library(landscapemetrics)
library(landscapetools)
library(parallelly)
library(doParallel)
library(foreach)
library(future)
library(furrr)

# metrics -----------------------------------------------------------------

# landfrag
landfrag <- sf::st_read("01_data/00_landfrag/landfrag_v02_countries.gpkg") %>% 
    dplyr::distinct(site_plot_comb, .keep_all = TRUE) %>% 
    tibble::rowid_to_column() %>% 
    dplyr::mutate(rowid =  ifelse(rowid < 10, paste0("000", rowid),
                                  ifelse(rowid < 100, paste0("00", rowid),
                                         ifelse(rowid < 1000, paste0("0", rowid), rowid))))
landfrag

# for
doParallel::registerDoParallel(parallelly::availableCores(omit = 2))
foreach::foreach(i=1:nrow(landfrag)) %do% {
    
    # info
    print(paste0("Landscape ", i))
    
    # point
    point <- sf::st_read(paste0("01_data/00_landfrag/00_points/landfrag_proj_", landfrag$rowid[i], ".gpkg"), quiet = TRUE)
    
    # raster
    glclu <- raster::raster(paste0("01_data/02_glclu/01_landscapes/glclu_adjust_binary_proj_", landfrag$rowid[i], ".tif"))

    # buffers
    foreach::foreach(j=c(100, 500, 1000, 2000)) %dopar% {
        
        # info
        print(paste0("Buffer ", j, " m"))
        
        # buffer
        point_buffer <- sf::st_buffer(point, dist = j)
        
        # crop and mask
        glclu_buffer <- glclu %>%
            raster::crop(point_buffer) %>% 
            raster::mask(point_buffer)
        
        # values
        glclu_buffer_val <- glclu_buffer %>% 
            raster::freq() %>%
            tibble::as_tibble() %>% 
            dplyr::filter(value == 1)
        
        # 1. number of patches ----
        if(nrow(glclu_buffer_val) == 1){
            np <- landscapemetrics::lsm_c_np(glclu_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(number_patches = value) %>% 
                dplyr::select(number_patches)
            
        } else{
            np <- tibble::tibble(number_patches = 0)
        }
        
        # 2. percentage of landscape ----
        if(nrow(glclu_buffer_val) == 1){
            pl <- landscapemetrics::lsm_c_pland(glclu_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(habitat_percentage = value) %>%
                dplyr::select(habitat_percentage)
            
        } else{
            pl <- tibble::tibble(habitat_percentage = 0)
        }
        
        # 3. patch density ----
        if(nrow(glclu_buffer_val) == 1){
            pd <- landscapemetrics::lsm_c_pd(glclu_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(patch_density = value) %>%
                dplyr::select(patch_density)
            
        } else{
            pd <- tibble::tibble(patch_density = 0)
        }
        
        # 4. edge density ----
        if(nrow(glclu_buffer_val) == 1){
            ed <- landscapemetrics::lsm_c_ed(glclu_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(edge_density = value) %>%
                dplyr::select(edge_density)
            
        } else{
            ed <- tibble::tibble(edge_density = 0)
        }
        
        # 5. euclidean nearest-neighbor distance ----
        if(np$number_patches > 1){
            enn <- landscapemetrics::lsm_c_enn_mn(glclu_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(enn_md = value) %>%
                dplyr::select(enn_md)
            
        } else{
            enn <- tibble::tibble(enn_md = 0)
        }
        
        # export ----
        dplyr::bind_cols(np, pl, pd, ed, enn) %>%
            dplyr::mutate(across(everything(), ~ round(.x, 2))) %>% 
            dplyr::mutate(rowid = landfrag$rowid[i], buffer = j, .before = 1) %>% 
            readr::write_csv(paste0("02_metrics/00_raw/metrics_rowid", landfrag$rowid[i], "_buf", ifelse(j < 1000, paste0("0", j), j), ".csv"))
        
    }
    
}
doParallel::stopImplicitCluster()

# combine -----------------------------------------------------------------

# list metrics files
metrics_files <- dir(path = "02_metrics/00_raw", pattern = ".csv", full.names = TRUE)
metrics_files

# import
future::plan(multisession, workers = parallelly::availableCores(omit = 2))
metrics <- furrr::future_map_dfr(metrics_files, read_csv, col_types = c("c", "d", "d", "d", "d", "d", "d"))
metrics

# join
landfrag <- dplyr::left_join(landfrag, metrics)
landfrag

# export
readr::write_csv(metrics, "02_metrics/metrics.csv")
readr::write_csv(sf::st_drop_geometry(landfrag), "01_data/00_landfrag/landfrag_v02_countries_metrics.csv")
sf::st_write(landfrag, "01_data/00_landfrag/landfrag_v02_countries_metrics.gpkg")

# end ---------------------------------------------------------------------