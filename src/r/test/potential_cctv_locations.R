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

# get locations where there were 100 or more crimes during recorded histor/////y

crime_locations_100 <- crime_locations %>%
  group_by(Latitude, Longitude) %>%
  dplyr::summarize(count = n()) %>%
  filter(count >= 100)

head(crime_locations_100, 50)

w <- crime_locations_100

head(w,5)
# now find how many crime locations are within a 256' distance from each of these points



# for each crime, calculate its distance from the cctv
# result will be in meters
crime_locations$dist_from_ctr_meters <- geosphere::distHaversine(
  p1 = crime_locations[ , c("Longitude", "Latitude")],
  p2 = c(-76.7043, 39.3575)  )


crime_locations %>%
  filter(dist_from_ctr_meters)

# find all those inside of cctv range
crime_locations %>%
  filter(dist_from_ctr_meters <= 0.0485)



for(i in 1:nrow(data2)) {       # for-loop over rows
  data2[i, ] <- data2[i, ] - 100
}






x <- crime_locations

nrow(x)

head(x, 5)

x <- x %>%
  mutate(dist = 0) %>%
  mutate(cent_lat = 0) %>%
  mutate(cent_lng = 0 )

head(x, 5)

#--Latitude	Longitude	(No column name)
#--39.3575	-76.7043	370


for(i in 1:nrow(x)) {       # for-loop over rows
  x[i,c('cent_lat')] <- 39.3575
  x[i,c('cent_lng')] <- -76.7043
  x[i,c('dist')] <- 100
}

#--Latitude	Longitude	(No column name)
#--39.3575	-76.7043	370

for(i in 1:nrow(x)) {       # for-loop over rows
  x[i,c('cent_lat')] <- 39.3575
  x[i,c('cent_lng')] <- -76.7043

  x[i,c('dist')] <- geosphere::distHaversine(
    p1 = x[i, c("Longitude", "Latitude")],
    p2 = c(-76.7043, 39.3575)  )
}



x$dist <- geosphere::distHaversine(
  p1 = x[ , c("Longitude", "Latitude")],
  p2 = c(-76.7043, 39.3575)  )


head(x)




# \/\/\/\/\/\/\/\/\/ TRASH



































































































































































































































































skim(crime_locations)

x <- crime_locations


# for each crime, calculate its distance from the cctv
# result will be in meters
x$dist_from_ctr_meters <- geosphere::distHaversine(
  p1 = x[ , c("Longitude", "Latitude")],
  p2 = c(-76.68489829, 39.33866714)  )

head(x,5)

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
 