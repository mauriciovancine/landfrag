# LandFrag: a dataset to investigate the effects of forest loss and fragmentation on biodiversity

## Repository Structure

- **data/**: Contains all datasets used in the project.
  - **00_landfrag_metadata/**: Raw data files directly obtained from the sources, including study information, species abundances, composition, and traits.
  - **01_landfrag_forest_files/**: raster files (*.tif) for all 121 studies.
  - **02_limits/**: geospatial files related to UTM (Universal Transverse Mercator) zones and EPSG (European Petroleum Survey Group) codes.
  - **README_datasets.md**: Detailed information about the three previous datasets.

- **code/**: Contains all the scripts and notebooks used to process data and generate results.
  - **scripts/**: Rscript to run the code to extract the landscape variables.
  - **README_code.md**: Information on how to run the code and dependencies.

- **figures/**: Maps generated with the coordinates from the studies.

- **metrics/**: Contains files related to the landscape metrics extracted from all studies.

- **LICENSE**: License information for the repository.

- **landfrag.Rproj**: R project file for easy project management in RStudio.


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




