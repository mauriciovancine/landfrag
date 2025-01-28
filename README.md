# LandFrag: a dataset to investigate the effects of forest loss and fragmentation on biodiversity

## Abstract

*Motivation*. The accelerated and widespread conversion of once continuous ecosystems into fragmented landscapes has driven ecological research to understand the response of biodiversity to local (fragment size) and landscape (e.g., forest cover and fragmentation) changes. This information has important theoretical and applied implications but is still far from complete. Here, we compiled a comprehensive and updated database that can be useful for assessing species responses to local and landscape drivers across different taxa and multiple scales.

*Main types of variables contained*. We provide information on the abundance and composition of 9,154 species belonging to different taxonomic groups and the functional traits (morphological, trophic, and reproductive traits) of 2,703 species in 1,472 forest fragments. We also provide the spatial location and size (hectares) of each fragment, as well as the composition (percent forest cover) and configuration (fragment density, forest edge density, and mean inter-fragment isolation distance) of the surrounding landscape. These landscape metrics were measured in concentric buffers from the center of each study fragment; the buffer size ranged from a radius of 200 m to 2,000 m, in 100 m increments.

*Spatial location and grain*. The dataset includes forest fragments sampled in 121 studies from all continents except Antarctica. Most datasets (77%) are from tropical regions, 17% from temperate regions, and 6% from subtropical regions, and were principally done in America (56% from South America, 11% from North America) and Asia (11%).

*Time period and grain*. Data were collected between 1994 and 2022, and included spatial information recorded at different spatial scales. 

*Major taxa and level of measurement*. The studied organisms included invertebrates (Arachnida, Insecta, and Gastropoda), vertebrates (Amphibia, Squamata, Aves, and Mammalia), and vascular plants.

*Software format*. The dataset and code are available on Zenodo and GitHub.

## Description

Here, we gathered a global database of the composition and abundance of 9,154 species sampled in 1,472 forest fragments as part of 121 studies of different taxonomic groups in tropical, subtropical, and temperate regions (Fig. 1). For 2,703 of these species, we were also able to compile information on morphological, trophic, habitat, and reproductive traits. We recorded the spatial location of each study fragment, its size (in hectares), and the spatial structure of the landscape surrounding each fragment. We calculated ten landscape variables (Table 1) that have been at the core of important ecological debates (Fahrig et al., 2022; Riva & Fahrig, 2023; Riva et al., 2024). Therefore, this dataset has broad applicability in ecological research, and can potentially be used to address many research questions in fragmented landscapes at all spatial scales, from local to global. Importantly, since the effect of landscape structure on biodiversity can be unnoticed if assessed at the wrong scale (Jackson and Fahrig, 2015), we calculated landscape metrics in circular landscapes of different sizes (from 200 to 2,000 m radius). This multiscale information can be highly valuable to identify the so-called “scale of effect” of each landscape metric on each response (Jackson and Fahrig, 2015) - an emerging topic in landscape ecology that can be used for assessing important hypotheses on spatial scaling issues (Miguet et al., 2016).

## Requirements

- R >= 3.5
- Required packages: tidyverse, geodata, sf, terra, SpatialKDE, ggsci, tmap, parallelly, doParallel, foreach, future, furrr

## Scripts

- 00_script_landfrag.R

## Data

- folder - 00_landfrag_metadata: 
  - landfrag_abundances_jun2024_final_version.csv: species abundances for all studied fragments
  - landfrag_studies_jun2024_final_version.csv: metadata information for all individual studies
  - landfrag_studies_jun2024_metrics.csv: extracted landscape metrics for all studied fragments
- folder - 01_landfrag_forest_files: raster files for all studied fragments
- folder - 02_limits: utm zones

## Data are publicly available but should be referenced by citing the corresponding data paper:

Thiago Gonçalves-Souza, Maurício Humberto Vancine, Nathan J. Sanders, Nick M. Haddad, Lucas Cortinhas, Anne Lene T. O. Aase, Willian Moura de Aguiar, Marcelo Adrian Aizen, Víctor Arroyo-Rodríguez, Arturo Baz, Maíra Benchimol, Enrico Bernard, Tássia Juliana Bertotto, Arthur Angelo Bispo, Juliano A. Bogoni, Gabriel X. Boldorini, Cibele Bragagnolo, Berry Brosi, Aníbal Silva Cantalice, Rodrigo Felipe Rodrigues do Carmo, Eliana Cazeta, Adriano G. Chiarello, Noé U. de la Sancha, Raphael K. Didham, Deborah Faria, Bruno Filgueiras, José Eugênio Côrtes Figueira, Gabriela Albuquerque Galvão, Michel Varajão Garey, Heloise Gibb, Carmelo Gómez-Martínez, Ezequiel González, Reginaldo Augusto Farias de Gusmão, Mickaël Henry, Shayana de Jesus, Thiago Gechel Kloss, Amparo Lázaro, Victor Leandro-Silva, Marcelo G. de Lima, Ingrid da Silva Lima, Ana Carolina B. Lins e Silva, Ralph Mac Nally, Arthur Ramalho Magalhães, Luiz Fernando Silva Magnago, Shiiwua Manu, Eduardo Mariano-Neto, David Nyaga Mugo Mbora, Felipe P.L. Melo, Morris Nzioka Mutua, Selvino Neckel-Oliveira, André Nemésio, André Amaral Nogueira, Patricia Marques do A. Oliveira, Diego G. Pádua, Luan Paes, Aparecida Barbosa de Paiva, Marcelo Passamani, João Carlos Pena, Carlos A. Peres, Bruno X. Pinho, Jean-Marc Pons, Victor Mateus Prasniewski, Jenny Reiniö, Magda dos Santos Rocha, Larissa Rocha-Santos, Maria J. Rodal, Rodolpho Credo Rodrigues, Nathalia V.H. Safar, Renato P. Salomão, Bráulio A. Santos, Mirela N. Santos, Jessie Pereira dos Santos, Sini Savilaakso, Carlos Ernesto Gonçalves Reynaud Schaefer, Maria Amanda Menezes Silva, Fernando R. da Silva, Ricardo J. Silva, Marcelo Simonelli, Alejandra Soto-Werschitz, John O. Stireman III, Danielle Storck-Tonon, Neucir Szinwelski, Marcelo Tabarelli, Camila Palhares Teixeira, Ørjan Totland, Marcio Uehara-Prado, Fernando Zagury Vaz-de-Mello, Heraldo L. Vasconcelos, Simone A. Vieira, Jonathan M. Chase (2025). LandFrag: A dataset to investigate the effects of forest loss and fragmentation on biodiversity. JOURNAL NAME - DOI

Please contact Thiago Gonçalves-Souza with questions.




