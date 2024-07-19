#' ---
#' title: landfrag - landscape metrics
#' author: 
#' date: 2024-07-18
#' ---

# prepare r ---------------------------------------------------------------

# packages
library(tidyverse)
library(geodata)
library(sf)
library(terra)
library(SpatialKDE)
library(ggsci)
library(tmap)
library(parallelly)
library(doParallel)
library(foreach)
library(future)
library(furrr)

# import data -------------------------------------------------------------

# landfrag studies
landfrag_studies <- readr::read_csv("data/00_landfrag_metadata/landfrag_studies_jun2024_final_version.csv")
landfrag_studies

# landfrag 
landfrag_abundances <- readr::read_csv("data/00_landfrag_metadata/landfrag_abundances_jun2024_final_version.csv")
landfrag_abundances

# download countries
countries <- geodata::world(resolution = 1, path = "data/02_limits/") %>%  
    sf::st_as_sf() %>% 
    sf::st_make_valid() %>% 
    dplyr::select(-GID_0) %>% 
    dplyr::rename(country_gadm = NAME_0)
countries

# utm
utm <- sf::st_read("data/02_limits/utm_zones_epsg.shp")
utm

# landfrag spatial
landfrag_studies_sf <- landfrag_studies %>% 
    dplyr::mutate(lon = longitude,
                  lat = latitude) %>% 
    sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)
landfrag_studies_sf

# prepare data --------------------------------------------------------------

# countries
landfrag_studies <- sf::st_join(landfrag_studies_sf, countries) %>% 
    sf::st_drop_geometry()
landfrag_studies

# region
landfrag_studies <- landfrag_studies %>% 
    dplyr::mutate(region = case_when(latitude >= -23.5 & latitude <= 23.5 ~ "tropical",
                                     TRUE ~ "temperate"))
landfrag_studies

# information ------------------------------------------------------------

# studies
nrow(landfrag_studies)
nrow(dplyr::count(landfrag_studies, refshort))
range(landfrag_studies[landfrag_studies$year_of_publication == "yes", ]$year_of_sample, na.rm = TRUE)
dplyr::mutate(dplyr::count(landfrag_studies, climate), per = n/sum(n)*100)
dplyr::mutate(dplyr::count(landfrag_studies, continent), per = n/sum(n)*100)
dplyr::mutate(dplyr::count(landfrag_studies, sphere_fragment), per = n/sum(n)*100)
dplyr::mutate(dplyr::count(landfrag_studies, biome), per = n/sum(n)*100)
dplyr::mutate(dplyr::count(landfrag_studies, taxa), per = n/sum(n)*100)
dplyr::mutate(dplyr::count(landfrag_studies, patch_type), per = n/sum(n)*100)

# abundances
nrow(dplyr::count(landfrag_abundances, scientific_name))
sum(landfrag_abundances$abundance)

# kernel ------------------------------------------------------------------

# reproject
robin <- "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

landfrag_studies_sf_robin <- landfrag_studies_sf %>% 
    dplyr::distinct(longitude, latitude) %>% 
    sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>% 
    sf::st_transform(crs = robin)
landfrag_studies_sf_robin

countries_robin <- ct <- rnaturalearth::ne_countries(scale = 110, returnclass = "sf") %>% 
    sf::st_transform(crs = robin) %>% 
    dplyr::filter(continent != "Antarctica") %>% 
    dplyr::select(geometry)
countries_robin

tm_shape(countries_robin) +
    tm_polygons() +
    tm_shape(landfrag_studies_sf_robin) +
    tm_dots()

# grid
load(url("https://github.com/valentinitnelav/RandomScripts/blob/master/NaturalEarth.RData?raw=true"))

countries_box_robin <- NE_box %>% 
    sf::st_as_sf() %>% 
    sf::st_transform(crs = robin) %>% 
    sf::st_crop(st_buffer(countries_robin, 25e4))
countries_box_robin
plot(countries_box_robin$geometry)

graticules_box_robin <- NE_graticules %>% 
    sf::st_as_sf() %>% 
    sf::st_transform(crs = robin) %>% 
    sf::st_crop(st_buffer(countries_robin, 25e4))
graticules_box_robin
plot(graticules_box_robin$geometry)

# cell size and band width
cell_size <- 1e5
band_width <- 1e6

# raster
countries_robin_raster <- countries_box_robin %>% 
    SpatialKDE::create_raster(cell_size = cell_size, side_offset = band_width)
countries_robin_raster

# kde
landfrag_studies_sf_raster_kde <- landfrag_studies_sf_robin %>%
    dplyr::select(geometry) %>% 
    SpatialKDE::kde(band_width = band_width, 
                    kernel = "quartic", 
                    grid = countries_robin_raster)
landfrag_studies_sf_raster_kde
plot(landfrag_studies_sf_raster_kde)

landfrag_studies_sf_raster_kde_crop <- landfrag_studies_sf_raster_kde %>% 
    terra::rast() %>% 
    terra::crop(terra::vect(countries_robin), mask = TRUE)
landfrag_studies_sf_raster_kde_crop
plot(landfrag_studies_sf_raster_kde_crop, col = viridis::turbo(n = 100))
lines(countries_robin, col = "white")

# maps ----
landfrag_unique <- landfrag_studies %>% 
    dplyr::distinct(taxa, refshort, .keep_all = TRUE) %>% 
    # dplyr::mutate(taxa = case_when(taxa == "Amphibia & Squamata" ~ "Amphibians & Squamates",
    #                                taxa == "Arachnida" | taxa == "Mollusca" ~ "Arachnids & Molluscs",
    #                                taxa == "Aves" ~ "Birds",
    #                                taxa == "Insecta" ~ "Insects",
    #                                taxa == "Mammalia" ~ "Mammals",
    #                                taxa == "Plantae" ~ "Plants",)) %>% 
    sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326)
landfrag_unique

map_landfrag <- tm_shape(countries_robin, bbox = countries_box_robin) +
    tm_fill() +
    tm_shape(countries_robin) +
    tm_borders(col = "white") +
    tm_shape(countries_box_robin) +
    tm_borders() +
    tm_shape(graticules_box_robin) +
    tm_lines(lwd = .15, lty = 2) +
    tm_shape(landfrag_unique) +
    tm_dots(size = .7, 
            shape = 21,
            col = NA,
            fill = "taxa", 
            fill.scale = tm_scale_categorical(values = ggsci::pal_bmj()(7)),
            fill_alpha = .3,
            fill.legend = tm_legend(title = "",  frame = FALSE, text.size = .85,
                                    position = tm_pos_in(pos.h = .07, pos.v = .5))) +
    tm_layout(frame = FALSE)
tmap::tmap_save(map_landfrag, "figures/map_landfrag.png", 
                width = 23, height = 10, units = "cm", dpi = 300)


map_landfrag_kernel <- tm_shape(landfrag_studies_sf_raster_kde_crop, bbox = countries_box_robin) +
    tm_raster(col = "layer", col.scale = tm_scale_continuous(n = 10, 
                                                             values = rev(RColorBrewer::brewer.pal(name = "Spectral", n = 10))),
              col_alpha = 1,
              col.legend = tm_legend(title = "Kernel",  frame = FALSE, text.size = .45,
                                     position = tm_pos_in(pos.h = .12, pos.v = .6))) +
    tm_shape(countries_robin) +
    tm_borders(col = "gray") +
    tm_shape(countries_box_robin) +
    tm_borders() +
    tm_shape(graticules_box_robin) +
    tm_lines(lwd = .15, lty = 2) +
    tm_shape(landfrag_unique) +
    tm_dots(alpha = .5) +
    tm_layout(frame = FALSE)
tmap::tmap_save(map_landfrag_kernel, "figures/map_landfrag_kernel.png", 
                width = 23, height = 10, units = "cm", dpi = 300)

# metrics -------------------------------------------

# download and unzip data
# https://zenodo.org/records/12206838

# files
files <- dir(path = "data/01_LandFrag_forest_files/raw", pattern = ".tif$", recursive = TRUE, full.names = TRUE)
files

# prepare data
for(i in files){
    
    name_raw <- stringr::str_split(i, "[/]", simplify = TRUE)
    name1 <- stringr::str_replace_all(stringr::str_to_lower(name_raw[, 4]), "-", "_")
    name2 <- paste0(paste0(stringr::str_split(name_raw[, 5], "_", simplify = TRUE)[, 1:2], collapse = "_"), "_forest.tif")
    name <- paste0(name1, "_", name2)
    
    file.copy(from = i, to = paste0("data/01_LandFrag_forest_files/", "landfrag_landscape_", name))
    
}

### data ----
# landfrag landscapes
landfrag_landscapes <- dir(path = "data/01_LandFrag_forest_files", pattern = ".tif$", full.names = TRUE)
landfrag_landscapes

### confer ----
confer <- NULL
for(i in unique(landfrag_studies$refshort)){
    
    # info
    print(paste0("Landscape ", i))
    
    # point
    point <- dplyr::filter(landfrag_studies_sf, refshort == i)
    
    # point name
    point_name <- unique(stringr::str_replace_all(stringr::str_to_lower(point$refshort), "-", "_"))
    
    # landscape
    landscape_name <- stringr::str_subset(landfrag_landscapes, point_name)
    
    if(length(landscape_name) == 0){
        
        point$data_forest <- "no_data_yet"
        
    } else{
        
        # mosaic
        if(length(landscape_name) == 1){
            
            landscape <- terra::rast(landscape_name)
            e <- terra::extract(landscape, point, ID = FALSE)
            
        } else{
            
            landscape <- terra::mosaic(terra::sprc(landscape_name), fun = "max")
            e <- terra::extract(landscape, point, ID = FALSE)
            
        }
        
        # add data
        point$data_forest <- e$Forest
        
    }
    
    # combine
    confer <- rbind(confer, point)
    
}
confer

confer_id <- dplyr::filter(confer, is.na(data_forest))[, 1:2]
confer_id

### metrics ----
doParallel::registerDoParallel(parallelly::availableCores(omit = 2))
foreach::foreach(i = landfrag_studies$id) %do% {
    
    # info
    print(paste0("Landscape ", i))
    
    # point
    point <- dplyr::slice(landfrag_studies_sf, i)
    
    # point name
    point_name <- stringr::str_replace_all(stringr::str_to_lower(point$refshort), "-", "_")
    
    # point utm
    point_utm <- sf::st_transform(point, crs = utm[point,]$epsg_code)
    
    # landscape
    landscape_name <- stringr::str_subset(landfrag_landscapes, point_name)
    
    # mosaic
    if(length(landscape_name) == 1){
        
        landscape <- terra::rast(landscape_name)
        
    } else{
        
        landscape <- terra::mosaic(terra::sprc(landscape_name), fun = "max")
        
    }
    
    # crop
    landscape <- landscape_utm_buffer <- terra::crop(landscape, terra::buffer(terra::vect(point), 2500))
    
    # landscape utm
    landscape_utm <- terra::project(landscape, point_utm, method = "near")
    
    # metrics
    metrics_i <- NULL
    
    #### buffers ----
    for(j in seq(200, 2000, 200)){
        
        # info
        print(paste0("Buffer ", j, " m"))
        
        # buffer
        point_buffer <- sf::st_buffer(point_utm, dist = j)
        
        # crop and mask
        landscape_utm_buffer <- terra::crop(landscape_utm, point_buffer, mask = TRUE)
        
        # values
        landscape_utm_buffer_val <- landscape_utm_buffer %>% 
            terra::freq() %>%
            tibble::as_tibble() %>% 
            dplyr::filter(value == 1)
        
        #### 1. area mn ----
        if(nrow(landscape_utm_buffer_val) == 1){
            am <- landscapemetrics::lsm_c_area_mn(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(area_mn = value) %>% 
                dplyr::select(area_mn)
            
        } else{
            am <- tibble::tibble(area_mn = 0)
        }
        
        #### 2. percentage of landscape ----
        if(nrow(landscape_utm_buffer_val) == 1){
            pl <- landscapemetrics::lsm_c_pland(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(pland = value) %>%
                dplyr::select(pland)
            
        } else{
            ha <- tibble::tibble(pland = 0)
        }
        
        #### 3. number of patches ----
        if(nrow(landscape_utm_buffer_val) == 1){
            np <- landscapemetrics::lsm_c_np(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(np = value) %>% 
                dplyr::select(np)
            
        } else{
            np <- tibble::tibble(np = 0)
        }
        
        #### 4. patch density ----
        if(nrow(landscape_utm_buffer_val) == 1){
            pd <- landscapemetrics::lsm_c_pd(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(pd = value) %>%
                dplyr::select(pd)
            
        } else{
            pd <- tibble::tibble(pd = 0)
        }
        
        #### 5. euclidean nearest-neighbor distance ----
        if(np$np > 1){
            enn <- landscapemetrics::lsm_c_enn_mn(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(enn_mn = value) %>%
                dplyr::select(enn_mn)
            
        } else{
            enn <- tibble::tibble(enn_mn = 0)
        }
        
        #### 6. aggregation index ----
        if(np$np > 1){
            ai <- landscapemetrics::lsm_c_ai(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(ai = value) %>%
                dplyr::select(ai)
            
        } else{
            ai <- tibble::tibble(ai = 0)
        }
        
        #### 7. edge density ----
        if(nrow(landscape_utm_buffer_val) == 1){
            ed <- landscapemetrics::lsm_c_ed(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(ed = value) %>%
                dplyr::select(ed)
            
        } else{
            ed <- tibble::tibble(ed = 0)
        }
        
        #### 8. largest patch index ----
        if(nrow(landscape_utm_buffer_val) == 1){
            lpi <- landscapemetrics::lsm_c_lpi(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(lpi = value) %>%
                dplyr::select(lpi)
            
        } else{
            lpi <- tibble::tibble(lpi = 0)
        }
        
        #### 9. perimeter-area ratio ----
        if(nrow(landscape_utm_buffer_val) == 1){
            para <- landscapemetrics::lsm_c_para_mn(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(para_mn = value) %>%
                dplyr::select(para_mn)
            
        } else{
            para <- tibble::tibble(para_mn = 0)
        }
        
        #### 10. contiguity index ----
        if(np$np > 1){
            contig <- landscapemetrics::lsm_c_contig_mn(landscape_utm_buffer) %>% 
                dplyr::filter(class == 1) %>% 
                dplyr::mutate(contig_mn = value) %>%
                dplyr::select(contig_mn)
            
        } else{
            contig <- tibble::tibble(contig_mn = 0)
        }
        
        # combine j 
        metrics_j <- dplyr::bind_cols(am, pl, np, pd, enn, ai, ed, lpi, para, contig) %>%
            dplyr::mutate(across(everything(), ~ round(.x, 4))) %>% 
            dplyr::mutate(id = landfrag_studies$id[i], buffer = j, .before = 1)
        
        # combine i
        metrics_i <- dplyr::bind_rows(metrics_i, metrics_j)
        
    }
    
    
    # map
    point_buffer <- purrr::map_dfr(c(seq(200, 2000, 200), 2500), ~sf::st_buffer(point_utm, .x))
    landscape_utm_buffer <- terra::crop(landscape_utm, point_buffer[10,])
    landscape_utm_ext <- terra::crop(landscape_utm, point_buffer[11,])
    
    map_land <- tm_shape(landscape_utm_ext) +
        tm_raster(col = "Forest", 
                  col.scale = tm_scale_categorical(values = c("gray90", "forestgreen")),
                  col.legend = tm_legend(show = FALSE)) +
        tm_shape(point_utm) +
        tm_bubbles() +
        tm_shape(point_buffer[-11, ]) +
        tm_borders(col = "red") +
        tm_title(text = paste0("id", unique(metrics_i$id), "_", sub("_forest.tif", "", sub("landfrag_landscape_", "", basename(landscape_name)))))
    
    #### export ----
    id <- unique(metrics_i$id)
    readr::write_csv(metrics_i, paste0("metrics/", 
                                       ifelse(id < 10, paste0("000", id),
                                              ifelse(id < 100, paste0("00", id),
                                                     ifelse(id < 1000, paste0("0", id), id))), "_", point_name, ".csv"))
    
    tmap::tmap_save(map_land, paste0("maps/", 
                                     ifelse(id < 10, paste0("000", id),
                                            ifelse(id < 100, paste0("00", id),
                                                   ifelse(id < 1000, paste0("0", id), id))), "_", point_name, ".png"))
    
}
doParallel::stopImplicitCluster()

## combine ----

# list metrics files
metrics_files <- dir(path = "metrics", pattern = ".csv", full.names = TRUE)
metrics_files

# import
metrics <- NULL
for(i in metrics_files){
    print(i)    
    metrics_i <- readr::read_csv(i, col_types = cols())
    metrics <- dplyr::bind_rows(metrics, metrics_i)
}
metrics

# join data ---------------------------------------------------------------

# join data
landfrag_studies_metrics <- dplyr::left_join(landfrag_studies, metrics)
landfrag_studies_metrics

# export ------------------------------------------------------------------

# export
readr::write_csv(landfrag_studies_metrics, "data/00_landfrag_metadata/landfrag_studies_jun2024_metrics.csv")

# end ---------------------------------------------------------------------