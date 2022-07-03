# Header ----
#
# Name:        Config_Trading.R
#
# Title:       Configure project workspace
#
# Version:     1.0
# Date:        2019-Jan-25
# Author:      Brad Horn
# License:     GPL (>=2)
#
# Description: Script for all project configurations
#
# Details:     The script will load required libraries, set project file paths,
#              source custom functions, set workspace options, configure devices
#              and load API authentication keys if needed. The script is essential
#              for large projects, collaboration and repeatable results across
#              machines and over time.
#
# Dev.Notes:   config.R needs to be sourced as the start of all scripts.  Any API
#              authentication keys are user specific and need to be updated for each
#              project collaborator.
#
#              The config file will remove all data objects from memory at the start
#              of any session so all data is controled by source code.  This serves
#              to eliminate all resutls linked to manually created data, thereby
#              ensuring repeateability.
#
# Depends      The R programming language (3.5) and all listed libraries.
#              Configuration does not rely on custom functions.  Custom functions, if
#              any, are project specific and can be found in the project lib directory
#
# References:  see package description files and vignettes as needed.
##-------------------------------------------------------------------------------------------##

# 0.Memory Management ----
# clear all environment data, but not function objects, and reset memory
#rm(list = setdiff(ls(), lsf.str()))
#gc(reset = TRUE)

# 1.Libraries ----
# Load tidyverse and core quatitative fiancial resources
suppressMessages(library(tidyquant))           # package of packages
suppressMessages(library(pillar))              # tidy data and tibble print formats

# Load RStudio enhancements
suppressMessages(library(rstudioapi))          # access RStudio API

# Data I/O
suppressMessages(library(openxlsx))            # interface for MS Excel
suppressMessages(library(Quandl))              # API wrapper for Quandl.com

# Programming
suppressMessages(library(magrittr))            # pipe operators
suppressMessages(library(purrr))               # functional programming tools
suppressMessages(library(purrrlyr))            # intersection of purrr and dplyr

# Data modeling
suppressMessages(library(broom))               # convert model output to tidy tibbles
suppressMessages(library(modelr))              # model functions that work with a pipe
suppressMessages(library(nlme))                # linear and non-linear mixed effect models
suppressMessages(library(forecast))            # forecasting for timeseries and linear models

# Data tables and reporting
suppressMessages(library(xtable))              # export data tables to LaTex or HTML
suppressMessages(library(knitr))               # dynamic report generation in R
suppressMessages(library(rmarkdown))           # dyanmic docuemnts in R

# Data visualization
suppressMessages(library(gridExtra))           # Misc graphics functions
suppressMessages(library(ggthemes))            # plot themese for ggplot
suppressMessages(library(GGally))              # extension of ggplot
suppressMessages(library(scales))              # scale and color functions for ggplot
suppressMessages(library(RColorBrewer))        # colour ramps
suppressMessages(library(viridis))             # gradient colours

# Resolve conflicts
combine <- dplyr::combine
collapse <- dplyr::collapse
extract <- tidyr::extract
discard <- purrr::discard
set_names <- purrr::set_names
getResponse <- forecast::getResponse
##-------------------------------------------------------------------------------------------##

# 2.Project Paths ----
cache.path <- file.path(getwd(), "cache/")
config.path <- file.path(getwd(), "config/")
data.path <- file.path(getwd(), "data/")
image.path <- file.path(getwd(), "image/")
lib.path <- file.path(getwd(), "lib/")
report.path <- file.path(getwd(), "reports/")
source.path <- file.path(getwd(), "src/")
#archive <- "/mnt/timecapsule/BXH/"
##-------------------------------------------------------------------------------------------##

# 3.Source custom Functions ----
# see referenced file headers for details
# source("~/0-RProjects/0-first/src/Theme.BXH.R")
##-------------------------------------------------------------------------------------------##

# 4.Configure Project Workspace ----
# options
options(prompt = "R> ")
options(width = 95)
options(digits = 5, scipen = 4)
options(tibble.print_max = 25)
options(tibble.print_min = 15)
options(tibble.width = NULL)
options(pillar.bold = TRUE)
options(pillar.subtle = FALSE)
options(pillar.sigfig = 4)
options(stringsAsFactors = FALSE)
options(papersize = "a4")
options(repos = "https://cran.rstudio.com")
Sys.setenv(TZ = "Asia/Qatar")
Sys.setenv(R_HISTSIZE = '100000')
##-------------------------------------------------------------------------------------------##

# 5.Configure Graphic Devices ----
# store basic plot parameters (op = old.parameters)
op <- par(no.readonly = TRUE)
# customize plot parameters for mapping
par(mai = c(1.02, 0.82, 0.82, 1.02), mar = c(5.1, 4.1, 4.1, 5.1))

# create custom plot themes for data analysis
theme.Dat <- theme_gdocs() +
     theme(plot.title = element_text(size = 15, color = "black", face = "bold", hjust = 0),
           plot.subtitle = element_text(size = 11, hjust = 0),
           plot.caption = element_text(size = 9, hjust = 0, vjust = 0, colour = "grey50"),
           axis.title.y = element_text(face = "bold", color = "gray30"),
           axis.title.x = element_text(face = "bold", color = "gray30", vjust = -0.25),
           axis.text.y = element_text(size = 9, color = "grey15"),
           axis.text.x = element_text(size = 9, color = "grey15", angle = -90, vjust = 0.5),
           panel.background = element_rect(fill = "grey95", colour = "grey75"),
           panel.border = element_rect(colour = "grey75"),
           panel.grid.major.y = element_line(colour = "white"),
           panel.grid.minor.y = element_line(colour = "white"),
           panel.grid.major.x = element_line(colour = "white"),
           panel.grid.minor.x = element_line(colour = "white"),
           strip.background = element_rect(fill = "white", colour = "grey75"),
           strip.text.y = element_text(face = "bold"),
           axis.line = element_line(colour = "grey75"))
##-------------------------------------------------------------------------------------------##