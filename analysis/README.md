This directory contains the raw data exports from Zooniverse (in `/analysis/data`), as well as the R code we used to process and analyze the results.

This code has been packaged using [packrat](https://rstudio.github.io/packrat/), so all package dependencies are included under `/analysis/packrat`.
Simply starting an interactive R session in `/analysis/` should trigger the bootstrapped installation of packrat, followed by all necessary dependencies.

The processing code itself is contained in `/analysis/mutual_muses_final.Rmd`, an [R Markdown document](https://rmarkdown.rstudio.com/).
Building this file will reproduce the steps for loading and parsing the raw Zooniverse exports into data frames, tokenizing the transcription text, and calculating transcription agreement in order to select the best transcription for each document.

This analysis code will reproduce the table in `/data/analyzed_transcriptions.csv`. 
It also generates a few descriptive plots such as at transcriptions per user, rate of transcription over the course of the project, etc.
