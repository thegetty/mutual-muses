# Mutual Muses results

[![Project Status: Inactive – The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](http://www.repostatus.org/badges/latest/inactive.svg)](http://www.repostatus.org/#inactive)

### Table of contents 

- [Introduction](#introduction)
- [Repository structure](#repository-structure)
  - [analysis/](#analysis)
  - [docs/](#docs)
  - [bookdown/](#bookdown)
  - [data/](#data)
- [Files](#files)
- [License](#license)
- [Maintenance](#maintenance)
- [Acknowledgements](#acknowledgements)

## Introduction

Mutual Muses is a crowdsourced transcription project undertaken by the [Digital Art History program](http://www.getty.edu/research/scholars/digital_art_history/index.html) at the Getty Research Institute in 2017. The project crowdsourced transcriptions of correspondence from the archives of art critic [Lawrence Alloway (1926-1990)](http://primo.getty.edu/GRI:GETTY_ALMA21135991340001551) and feminist artist [Sylvia Sleigh (ca. 1916-2010)](http://primo.getty.edu/GRI:GETTY_ALMA21136007870001551), which are held at the Getty Research Institute. These letters reveal the intimate early stages of their respective careers and intertwined personal lives in postwar England from 1948-1953. The results of this project include transcription data for 2,376 documents from these archives, as well as code used for processing and analyzing the data results and producing file outputs. 

## Repository structure 

### analysis/

This directory contains the R code we used to process and analyze the results.

### docs/

This directory contains code that we used to generate a barebones [Jekyll] site for looking at page images and comparing their associated transcriptions. The site can be seen at <https://thegetty.github.io/mutual-muses>.

[Jekyll]: https://jekyllrb.com

### bookdown/

This directory contains code for producing the PDF compilations of edited transcriptions and page images contained in the pdf/ directory.

### data/

This directory contains the raw data exports from Zooniverse, as well as processed data from the analysis stage with documentation on data collection and processing and data dictionaries for processed data.

This directory also contains detailed data dictionaries, discussion of methodology, and usage guidelines for the data.

## Files 

We have generated PDF files with images and corresponding to selected transcriptions for each year of correspondence. 

* [1948](https://getty.box.com/shared/static/hsdgjn50k08850aue4w3rsxt6hj9hjqp.pdf) 
* [1949](https://getty.box.com/shared/static/iw2xfj7zyvy3edf0dyyikd0ao91qtbdm.pdf) 
* [1950](https://getty.box.com/shared/static/cutm2p9pec2j4tkuwu5z9mv2g24kfcc9.pdf) 
* [1951](https://getty.box.com/shared/static/ge0ki5jike4desvvteyfz5gjc7vbcg1f.pdf) 
* [1952](https://getty.box.com/shared/static/kit6gcdmaa1yx3lvn6whr9eq5n12g9rp.pdf) 
* [1953](https://getty.box.com/shared/static/1hjt1ob4w63if5f6ovq762ysw6bjvks9.pdf) 

A 1.8 GB zip file containing image files of the correspondence used for this project is available [here](https://getty.box.com/shared/static/429y88z56v4q7ebced8n8g0031b5kl2z.zip).

You do not need a Box account to access the files. 

Individual sheet images can also be browsed on the [Getty Research Institute’s collections database](http://hdl.handle.net/10020/alloway_sleigh).

## License 

The Getty Research Institute makes the data and code available under the least restrictive open license possible; however, note that each directory has its own license. The J. Paul Getty Trust also owns the copyright to the Lawrence Alloway and Sylvia Sleigh papers, including digital images of the correspondence. These images are not included under any open license, but may be downloaded for personal, non-commercial use.


## Maintenance 

Please note that these data and related tools were created as part of the Mutual Muses project, which concluded in April 2018, and therefore will not be updated or actively maintained. We also cannot accept pull requests for the data and code in this repository. 

## Acknowledgements

The Getty Research Institute would like to thank all of the volunteers who contributed transcriptions to the Mutual Muses project. This community-driven project would not have been possible without the commitment and time generously given by our volunteers. See the CONTRIBUTORS.md file for details.

This publication uses data generated via the [Zooniverse](http://www.zooniverse.org) platform (http://www.zooniverse.org), development of which is funded by generous support, including a Global Impact Award from Google, and by a grant from the Alfred P. Sloan Foundation. Zooniverse is an open-source, "citizen science" platform that facilitates collaboration between volunteers and researchers working on data collection research projects. 
