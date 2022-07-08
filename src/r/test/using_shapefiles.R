
# https://www.youtube.com/watch?v=07UB1lfHV-o



## Demo - Shape files and R Leaflet
## Add shapes to R leaflet map using addPolygons() functions
## Draw the boundaries on world map. Required geometry will come from shape files and then we will use them for maping


## Source of shape file
# http://thematicmapping.org/downloads/world_borders.php


## Set working directory ## 
## Download the shape files to working directory ##
download.file("http://thematicmapping.org/downloads/TM_WORLD_BORDERS_SIMPL-0.3.zip" , destfile="TM_WORLD_BORDERS_SIMPL-0.3.zip")
## Unzip them ##
unzip("TM_WORLD_BORDERS_SIMPL-0.3.zip")

## OR ## You can directly connect to download link and download to a temp folder as well ##

## Load Required Packages## 
library(leaflet)
library(rgdal) # R 'Geospatial' Data Abstraction Library. Install package if not already installed.
library(here)

## Load the shape file to a Spatial Polygon Data Frame (SPDF) using the readOGR() function
myspdf = readOGR(dsn=getwd(), layer="TM_WORLD_BORDERS_SIMPL-0.3")
head(myspdf)
summary(myspdf)

# using the slot data
head(myspdf@data)

## Create map object and add tiles and polygon layers to it
leaflet(data=myspdf) %>% 
  addTiles() %>% 
  setView(lat=10, lng=0 , zoom=2) %>% 
  addPolygons(fillColor = "green",
              highlight = highlightOptions(weight = 5,
                                           color = "red",
                                           fillOpacity = 0.7,
                                           bringToFront = TRUE),
              label=~NAME)

# ========================================================================================


# demo
m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  setView(lng = -76.68489829,  lat = 39.33866714, zoom = 15) %>%
  addMarkers(lng=-76.68489829, lat = 39.33866714, popup="The birthplace of R")
m  # Print the 


# add shape file 
myspdf = readOGR(here("data","raw_data", "Arrests_shapefile_asof_20210602"), "Arrests")
head(myspdf)
summary(myspdf)


m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  setView(lng = -76.68489829,  lat = 39.33866714, zoom = 15) %>%
  addMarkers(lng=-76.68489829, lat = 39.33866714, popup="The birthplace of R") %>%
  addPolygons(data   = myspdf,
              color  = "660000",
              weight = 5)
m  # Print the 

# FAILS!!

#-----------------------------------------------------------


# try another shapefile

# add shape file 
myspdf = readOGR(here("data","raw_data", "tl_2019_24510_faces"), "tl_2019_24510_faces")
head(myspdf)
summary(myspdf)


m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  setView(lng = -76.68489829,  lat = 39.33866714, zoom = 15) %>%
  addMarkers(lng=-76.68489829, lat = 39.33866714, popup="The birthplace of R") %>%
  addPolygons(data   = myspdf,
              color  = "660000",
              weight = 5)
m  # Print the 


#-----------------------------------------------------------


# try yet another shapefile

# add shape file 
myspdf = readOGR(here("data","raw_data", "tl_2021_24_cousub"), "tl_2021_24_cousub")
head(myspdf)
summary(myspdf)


m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  setView(lng = -76.68489829,  lat = 39.33866714, zoom = 15) %>%
  addMarkers(lng=-76.68489829, lat = 39.33866714, popup="The birthplace of R") %>%
  addPolygons(data   = myspdf,
              color  = "660000",
              weight = 5)
m  # Print the 

# this is a shapefile of maryland

# -------------------------------------------------------------------------------

# try yet (3) another shapefile

# add shape file 
myspdf = readOGR(here("data","raw_data", "BACIparcels0622"), "BACIMDPV")
head(myspdf)
summary(myspdf)


m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  setView(lng = -76.68489829,  lat = 39.33866714, zoom = 15) %>%
  addMarkers(lng=-76.68489829, lat = 39.33866714, popup="The birthplace of R") %>%
  addPolygons(data   = myspdf,
              color  = "660000",
              weight = 5)
m  # Print the 



# -------------------------------------------------------------------------------

# try yet (4) another shapefile

# add shape file 
myspdf = readOGR(here("data","raw_data", "nhood90"), "nhood90")
head(myspdf)
summary(myspdf)


m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  setView(lng = -76.68489829,  lat = 39.33866714, zoom = 15) %>%
  addMarkers(lng=-76.68489829, lat = 39.33866714, popup="The birthplace of R") %>%
  addPolygons(data   = myspdf,
              color  = "FFF0000",
              opacity = 5,
              weight = 5)
m  # Print the 
