# 10 MB allowed in the full version 
options(shiny.maxRequestSize = 10*1024^2)
options(shiny.sanitize.errors = TRUE)

library(shiny)
library(rmarkdown)
library(data.table)
library(readr)
library(shinydisconnect)

source("chooser.R")
source("Functions.R")

