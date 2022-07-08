# load libraries
library(gridExtra)  # arrange multiplot in a page grid
library(DBI)        # connects to a DBMS
library(odbc)       # provides interface to ODBC drivers
library(config)     # manages environment specific config values
library(janitor)    # examine and clean dirty data
library(dplyr)      # grammar of data manipulation
library(plyr)       # implement split-apply-combine pattern
library(corrplot)   # create correlation matrix
library(here)       # ease referencing of project work files
library(skimr)      # get summary statistics
library(geosphere)  # perform geo math
library(leaflet)    # interactive maps
library(reader)     # read/write files
library(here)       # find working directory

## Connect to Database(s)
# Credit: https://predictivehacks.com/how-to-connect-r-with-sql/
# establish db connection
# its done this way so password is not floating around in the environment 
#    for use by other processes
con <- dbConnect(
  odbc(),
  Driver   = config::get("crime_camera")$driver,
  Server   = config::get("crime_camera")$server,
  UID      = config::get("crime_camera")$uid,
  PWD      = config::get("crime_camera")$pwd,
  Port     = config::get("crime_camera")$port,
  Database = config::get("crime_camera")$database
)


# test connection
# limit this to 
#   the west arlington area
#   only the necessary columns    
crime_locations <- DBI::dbGetQuery(con, 'SELECT
                        RowID,
                        Description,
                        Latitude,
                        Longitude
                      FROM 
                        dbo.[crime_gwynn_oak_landing_1mi_border]')


head(crime_locations, 5)
nrow(crime_locations)
# [1] 39070


# get locations where there were 100 or more crimes during recorded history

crime_locations_100 <- crime_locations %>%
  group_by(Latitude, Longitude) %>%
  dplyr::summarize(count = n()) %>%
  filter(count >= 100)

crime_locations_100 %>%
  arrange(count)
# 19 locations having more than 100 crimes
#  ranging from 101 to 307 crimes
# we'll consider these our 'centroids'


# create a dataframe that save save coordinates of
#   points within a 256' from the centroids
potential_locations <- data.frame(RowID       = integer(),
                                  Description = character(),
                                  Latitude    = double(),
                                  Longitude   = double(),
                                  dist        = double(),
                                  cent_lat    = double(),
                                  cent_lng    = double())
# potential_locations


# start routine duration timer
startTime <- Sys.time()
# loop through all the centroids
#   and find/save points within 256'
#   of a centroid
for(j in 1:nrow(crime_locations_100)) {
  # for each centroid make a temp copy of all crime locations
  #    with add'l columns to save coordinates of THIS centroid
  #    and the distance of eqch from THIS centroid
  temp_table <- crime_locations
  # add columns
  temp_table <- temp_table %>%
    mutate(dist = 0) %>%
    mutate(cent_lat = 0) %>%
    mutate(cent_lng = 0 )

  # for each rec in the temp table...
  for(i in 1:nrow(temp_table)) {     
    # ... save the coordinates of THIS centroid...
    temp_table[i,c('cent_lat')] <- crime_locations_100[j,c('Latitude')]
    temp_table[i,c('cent_lng')] <- crime_locations_100[j,c('Longitude')]
    # ... save the distance of this rec's coordinates from the centroid
    temp_table[i,c('dist')] <- geosphere::distHaversine(
      p1 = temp_table[i, c("Longitude", "Latitude")],
      p2 = crime_locations_100[j, c("Longitude", "Latitude")]  )
  }

  # nrow(temp_table)
  # head(temp_table, 5)
  # 1609.344 meters = 1 mile
  # .305 meters = 1 foot
  # 256 ft * .305 meters/foot = 78.08 meters
  
  # remove rows that are outside range and
  # remove those locations = centroid
  
  # extract all records outside the range of THIS centroid
  # - include ground zero crimes (crimes lovated at THIS centroid)
  temp_table <- temp_table %>%
    filter(dist < (256 * .305))
  
  # nrow(temp_table)
  # head(temp_table, 5)
  
  # head(potential_locations, 5)
  
  # add these recs to our repository of potential locations
  potential_locations <- rbind(potential_locations, temp_table)
  
}
# end routine duration timer
endTime <- Sys.time()
# calculate duration
# prints recorded time
print(endTime - startTime)
# 7/7/22 - Time difference of 1.216862 hours

# nrow(potential_locations)
# 7/7/22 - 5611
# head(potential_locations, 5)

# export to disk
readr::write_csv(potential_locations,here("data","test_data","potential_locations_with_20220708.csv"))

# import from disk
potential_locations <- readr::read_csv(here("data","test_data","potential_locations_with_ground_zero.csv"))

# map potenital locations
leaflet(data = potential_locations) %>%
  addTiles()  %>% # base map
  addMarkers(~Longitude, 
             ~Latitude, 
             #popup = ~as.character(Latitude + Longitude),
             
             popup = paste("RowID", potential_locations$RowID, "<br>", 
                           "Lat",   potential_locations$Latitude, "<br>",
                           "Lng",   potential_locations$Longitude),
             label = ~as.character(Latitude))
  

# count crimes at centroid locations

potential_locations %>%
  group_by(cent_lat) %>%
  dplyr::summarize(count = n())

print(potential_locations$cent_lat)

print(crime_locations_100$Latitude)




## \/\/\/\/\/\/\/\/ debug start

z <- geosphere::distHaversine(
  p1 = c(-76.6837, 39.3397),
  p2 = c(-76.68489829, 39.33866714)  )

z
# 154.4774 meters

w <- z / 1609.34 # miles
w
# [1] 0.09598803 miles


a <- w * 5280
a
# [1] 506.8168 feet


## /\/\/\/\/\/\/\/\ debug end

# meters to miles
x$dist_from_ctr_miles = x$dist_from_ctr_meters / 1609.34

head(x,5)

nrow(x)
# [1] 7937


# the cctv has a range of 256 ft ~ blocks
# 256 ft = .0485 mi



# find all those outside of cctv range
crimes_outside_range <- x %>%
  filter(dist_from_ctr_miles > 0.0485)

nrow(crimes_outside_range)
# [1] 7839



# find all those inside of cctv range
crimes_inside_range <- x %>%
  filter(dist_from_ctr_miles <= 0.0485)

nrow(crimes_inside_range)
# [1] 98


# ===================================

# find all ctimes witihn 256 wide ring outside of cctv range (256')

# calc cctv range + 256' beyond range
extended_area <- 2 * 0.0485
# 0.097

# find all those inside of cctv range
crimes_inside_extd_range <- x %>%
  filter(dist_from_ctr_miles <= extended_area)

nrow(crimes_inside_extd_range)
# [1] 348


# from crime_inside_extd_range remove within cctv range


 y <- subset(crimes_inside_extd_range,
       !(
         (Longitude%in%crimes_inside_range$Longitude) & 
         ( Latitude%in%crimes_inside_range$Latitude)
         )
       )
 
 nrow(y)
# 236
 

 # crime donut
 leaflet(data = y) %>% addTiles() %>%
   addMarkers(~Longitude, 
              ~Latitude, 
              #popup = ~as.character(Latitude + Longitude),
              
              popup = paste("RowID", y$RowID, "<br>", 
                            "Lat", y$Latitude, "<br>",
                            "Lng", y$Longitude),
              label = ~as.character(Latitude)) %>%
   addMarkers(-76.68489829, lat = 39.33866714) %>%
   addCircles(              lng = -76.68489829, 
                            lat = 39.33866714, 
                            weight = 1,
                            # radius = 256 ft * .3048 meters/foot                            
                            radius = 78.0288, group = "crime") %>%
   addCircles(              lng = -76.68489829, 
                            lat = 39.33866714, 
                            weight = 1,
                            # double distance from center
                            # 78.0288 * 2
                            radius = 156.0576, 
                            fillColor = "green",
                            fillOpacity = .05,                             
                            group = "crime") %>%
    setView(lng = -76.68489829, lat = 39.33866714, zoom = 17)
 
 
 
 # cctv range
 # crimes_inside_range
 leaflet(data = crimes_inside_range) %>% addTiles() %>%
   addMarkers(~Longitude, ~Latitude) %>%
   addMarkers(-76.68489829, lat = 39.33866714) %>%
   addCircles(              lng = -76.68489829, 
                            lat = 39.33866714, 
                            weight = 1,
                            # radius = 256 ft * .3048 meters/foot
                            radius = 78.0288, group = "crime") %>%
   addCircles(              lng = -76.68489829, 
                            lat = 39.33866714, 
                            weight = 1,
                            # double distance from center
                            # 78.0288 * 2
                            radius = 156.0576, 
                            fillColor = "green",
                            fillOpacity = .05,                             
                            group = "crime") %>%
   setView(lng = -76.68489829, lat = 39.33866714, zoom = 17)
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 # demo
 m <- leaflet() %>%
   addTiles() %>%  # Add default OpenStreetMap map tiles
   addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
 m  # Print the 
 