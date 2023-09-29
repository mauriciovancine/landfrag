#' ---
#' title: landfrag - import landfrag
#' author: mauricio vancine
#' date: 2023-09-25
#' ---

# prepare r ---------------------------------------------------------------

# packages
library(tidyverse)
library(geodata)
library(sf)
library(terra)
library(SpatialKDE)
library(tmap)

# options
sf::sf_use_s2(FALSE)

# import data -------------------------------------------------------------

# landfrag
landfrag <- readr::read_csv("01_data/00_landfrag/landfrag_v02.csv") %>% 
    dplyr::relocate(longitude, .before = latitude) %>% 
    dplyr::mutate(refshort_site_plot_comb = paste0(refshort, "_", site_plot_comb), .after = site_plot_comb) %>% 
    dplyr::mutate(country = case_when(country == "Argentinia" ~ "Argentina", TRUE ~ country)) %>% 
    dplyr::mutate(year = as.numeric(str_extract_all(refshort, "(\\d)+")), .after = refshort)
landfrag

# landfrag spatial
landfrag_sf <- landfrag %>% 
    dplyr::mutate(lon = longitude,
                  lat = latitude) %>% 
    sf::st_as_sf(coords = c("lon", "lat"), crs = 4326)
landfrag_sf

# countries
countries <- sf::st_read(dsn = "01_data/04_limits/gadm_410-levels.gpkg",
                        layer = "ADM_0") %>% 
    dplyr::rename(country_gadm = COUNTRY,
                  gid0 = GID_0)
countries

# spatial_join
landfrag_sf_countries <- sf::st_join(landfrag_sf, countries)
landfrag_sf_countries

landfrag_sf_countries_list_na <- landfrag_sf_countries %>% 
    sf::st_drop_geometry() %>% 
    dplyr::select(country, country_gadm, gid0) %>% 
    dplyr::distinct()
landfrag_sf_countries_list_na

landfrag_sf_countries_list <- tidyr::drop_na(landfrag_sf_countries_list_na)
landfrag_sf_countries_list

landfrag_sf_countries_na <- landfrag_sf_countries %>% 
    dplyr::filter(is.na(country_gadm)) %>% 
    dplyr::select(-c(country_gadm, gid0)) %>% 
    dplyr::left_join(landfrag_sf_countries_list)
landfrag_sf_countries_na

landfrag_sf_countries <- landfrag_sf_countries %>% 
    dplyr::filter(!is.na(country_gadm)) %>% 
    dplyr::bind_rows(landfrag_sf_countries_na)
landfrag_sf_countries

# region
landfrag_sf_countries <- landfrag_sf_countries %>% 
    dplyr::mutate(region = case_when(latitude >= -23.5 & latitude <= 23.5 ~ "tropical",
                                     TRUE ~ "temperate"))
landfrag_sf_countries

# export
landfrag_sf_countries %>% 
    sf::st_drop_geometry() %>% 
    readr::write_csv("01_data/00_landfrag/landfrag_v02_countries.csv")

landfrag_sf_countries %>% 
    sf::st_write("01_data/00_landfrag/landfrag_v02_countries.gpkg", 
                 delete_dsn = TRUE)

countries %>% 
    sf::st_write("01_data/00_landfrag/countries.gpkg",
                 delete_dsn = TRUE)

# information ----
landfrag_sf_countries_info_continents <- landfrag_sf_countries %>% 
    sf::st_drop_geometry() %>% 
    dplyr::distinct(refshort, .keep_all = TRUE) %>% 
    dplyr::count(continent) %>% 
    dplyr::mutate(per = n/sum(n) * 100)
landfrag_sf_countries_info_continents

landfrag_sf_countries_info_continents_countries <- landfrag_sf_countries %>% 
    sf::st_drop_geometry() %>% 
    dplyr::distinct(refshort, .keep_all = TRUE) %>% 
    dplyr::count(country, country_gadm)
landfrag_sf_countries_info_continents_countries

landfrag_sf_countries_info_regions <- landfrag_sf_countries %>% 
    sf::st_drop_geometry() %>%
    dplyr::distinct(refshort, .keep_all = TRUE) %>% 
    dplyr::count(region) %>% 
    dplyr::mutate(per = n/sum(n) * 100)
landfrag_sf_countries_info_regions

landfrag_sf_countries_info_year <- landfrag_sf_countries %>% 
    sf::st_drop_geometry() %>%
    dplyr::pull(year) %>% 
    range()
landfrag_sf_countries_info_year

landfrag_sf_countries_info_forest_fragments <- landfrag_sf_countries %>% 
    sf::st_drop_geometry() %>%
    dplyr::count(sphere_fragment)
landfrag_sf_countries_info_forest_fragments

# kernel ----

# reproject
robin <- "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

landfrag_sf_robin <- landfrag_sf %>% 
    dplyr::distinct(longitude, latitude) %>% 
    sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>% 
    sf::st_transform(crs = robin)
landfrag_sf_robin

countries_robin <- ct <- rnaturalearth::ne_countries(scale = 110, returnclass = "sf") %>% 
    sf::st_transform(crs = robin) %>% 
    dplyr::filter(continent != "Antarctica") %>% 
    dplyr::select(geometry)
countries_robin

plot(countries_robin, col = "gray")
plot(landfrag_sf_robin, col = "red", pch = 20, add = TRUE)

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
landfrag_sf_raster_kde <- landfrag_sf_robin %>%
    dplyr::select(geometry) %>% 
    SpatialKDE::kde(band_width = band_width, 
                    kernel = "quartic", 
                    grid = countries_robin_raster)
landfrag_sf_raster_kde
plot(landfrag_sf_raster_kde)

landfrag_sf_raster_kde_crop <- landfrag_sf_raster_kde %>% 
    terra::rast() %>% 
    terra::crop(terra::vect(countries_robin), mask = TRUE)
landfrag_sf_raster_kde_crop
plot(landfrag_sf_raster_kde_crop, col = viridis::turbo(n = 100))
lines(countries_robin, col = "white")

# maps ----
landfrag_unique <- landfrag %>% 
    dplyr::distinct(taxa, refshort, .keep_all = TRUE) %>% 
    dplyr::mutate(taxa = case_when(taxa == "Amphibia & Squamata" ~ "Amphibians & Squamates",
                                   taxa == "Arachnida" | taxa == "Mollusca" ~ "Arachnids & Molluscs",
                                   taxa == "Aves" ~ "Birds",
                                   taxa == "Insecta" ~ "Insects",
                                   taxa == "Mammalia" ~ "Mammals",
                                   taxa == "Plantae" ~ "Plants",)) %>% 
    sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326)
landfrag_unique

map_landfrag <- tm_shape(countries_robin) +
    tm_fill() +
    tm_shape(countries_robin) +
    tm_borders(col = "white") +
    tm_shape(countries_box_robin) +
    tm_borders() +
    tm_shape(graticules_box_robin) +
    tm_lines(lwd = .15, lty = 2) +
    tm_shape(landfrag_unique) +
    tm_dots(size = .4, alpha = .5, shape = 21, col = "taxa", title = "",
            pal = ggsci::pal_aaas()(12)) +
    tm_layout(frame = FALSE,
              legend.title.size = 2,
              legend.position = c(.05, .15),
              legend.text.size = 1)

tmap::tmap_save(map_landfrag, "04_figures/map_landfrag.png", 
                width = 25, height = 20, units = "cm", dpi = 300)

map_landfrag_kernel <- tm_shape(landfrag_sf_raster_kde_crop) +
    tm_raster(pal = "-Spectral", n = 10, title = "Kernel density", style = "equal") +
    # tm_raster(pal = viridis::turbo(n = 10), n = 10, title = "Kernel density", style = "equal") +
    tm_shape(countries_robin) +
    tm_borders(col = "gray") +
    tm_shape(countries_box_robin) +
    tm_borders() +
    tm_shape(graticules_box_robin) +
    tm_lines(lwd = .15, lty = 2) +
    tm_shape(landfrag_unique) +
    tm_dots(alpha = .5) +
    tm_layout(frame = FALSE,
              legend.position = c(.11, 0),
              legend.title.size = 1.5,
              legend.text.size = .8)

tmap::tmap_save(map_landfrag_kernel, "04_figures/map_landfrag_kernel.png", 
                width = 25, height = 20, units = "cm", dpi = 300)

# end ---------------------------------------------------------------------
