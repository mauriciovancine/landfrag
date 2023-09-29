#' ---
#' title: fragsad - download hdi
#' author: mauricio vancine
#' date: 2023-09-25
#' ---

# prepare r ---------------------------------------------------------------

# packages
library(tidyverse)
library(rvest)
library(parallelly)
library(foreach)
library(doParallel)

# options
options(timeout = 1e6)

# download hdi -------------------------------------------------------

# urls
urls <- "https://zenodo.org/record/4972425" %>% 
    rvest::read_html() %>% 
    rvest::html_nodes("a") %>% 
    rvest::html_attr("href") %>% 
    stringr::str_subset("download=1") %>% 
    stringr::str_unique()
urls

destfiles <- basename(urls) %>% 
    stringr::str_replace_all("[?download=1]", "")
destfiles

# download
doParallel::registerDoParallel(parallelly::availableCores(omit = 2))
foreach::foreach(i=1:length(urls)) %dopar% {
    
    download.file(urls[i], paste0("01_data/03_idh/", basenames[i]), mode = "wb")
    
}
doParallel::stopImplicitCluster()

# end ---------------------------------------------------------------------