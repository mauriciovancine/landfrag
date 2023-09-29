#' ---
#' title: fragsad - download gadm
#' author: mauricio vancine
#' date: 2023-09-25
#' ---

# prepare r ---------------------------------------------------------------

# options
options(timeout = 1e6)


# download ----------------------------------------------------------------

# download
download.file(url = "https://geodata.ucdavis.edu/gadm/gadm4.1/gadm_410-levels.zip",
              destfile = "01_data/04_limits/gadm_410-levels.zip", mode = "wb")

# unzip
unzip(zipfile = "01_data/04_limits/gadm_410-levels.zip", exdir = "01_data/04_limits")

# end ---------------------------------------------------------------------


