#' ---
#' title: fragsad - download worldpop 2019
#' author: mauricio vancine
#' date: 2023-09-25
#' ---

# prepare r ---------------------------------------------------------------

# packages
library(tidyverse)
library(sf)
library(parallelly)
library(foreach)
library(doParallel)
library(tmap)

# options
options(timeout = 1e6)
sf::sf_use_s2(FALSE)

# import data -------------------------------------------------------------

# landfrag
landfrag <- sf::st_read("01_data/00_landfrag/landfrag_v02_countries.gpkg")
landfrag

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
    dplyr::filter(n > 1)
landfrag_buffer_countries_count

landfrag_buffer_countries_count_two <- landfrag_buffer_countries %>% 
    sf::st_drop_geometry() %>%     
    dplyr::filter(refshort_site_plot_comb %in% landfrag_buffer_countries_count$refshort_site_plot_comb) %>% 
    tibble::as_tibble()
landfrag_buffer_countries_count_two

# download worldpop -------------------------------------------------------

# urls
urls <- landfrag_buffer_countries %>% 
    dplyr::pull(gid0_buffer) %>% 
    unique() %>% 
    sort() %>% 
    paste0("https://data.worldpop.org/GIS/Population/Global_2000_2020/2019/", ., "/", str_to_lower(.), "_ppp_2019", ".tif")
urls

# download
doParallel::registerDoParallel(parallelly::availableCores(omit = 2))
foreach::foreach(i=urls) %dopar% {
    
    download.file(i, paste0("01_data/02_worldpop/00_raw/", basename(i)), mode = "wb")
    
}
doParallel::stopImplicitCluster()

# end ---------------------------------------------------------------------