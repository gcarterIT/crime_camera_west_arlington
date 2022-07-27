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
library(lubridate)  # Wrangle date data
library(leafpop)   # add tables to leaflet popups


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
                                          *
                                        FROM 
                                          dbo.crime_1mile_square2')


glimpse(crime_locations)










summary(crime_locations)





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
 
 
 
 str(crimes_inside_range)
 
 # find how many locations have overlapping crimes
 crimes_inside_range %>%
   group_by(Latitude,Longitude) %>%
   dplyr::summarize(count_distinct = n())
 
 
 crimes_inside_range %>%
   count(Latitude,Longitude)
 
 df1 %>% 
   group_by(State) %>% 
   dplyr::summarise(count_sales = n())
 
 
 # FOR OVERLAPPING LOCATIONS CREATE A POPUP THAT LIST ALL THE
 # CRIMES ATTHAT LOCATION WITH DESCRIPTION, DATE OF CRIME, ETC
 #
 # I NEED TO CREATE A SINGLE LOCATION MARKER FOR EACH DUPLICATED
 # MARKER AND CREATE A POPUP THAT EXTRACT CRIMES FOR THAT LOCATION
 # THEN LIST THOSE CRIME IN THE POPUP
 
 
 # lets try leafpop
 
 
 # cctv range
 # crimes_inside_range
 leaflet(data = crimes_inside_range) %>% addTiles() %>%
   addMarkers(~Longitude, ~Latitude) %>%
   addMarkers(lng = -76.68489829, 
              lat = 39.33866714,
              popup = popupTable(crimes_inside_range)) %>%
   
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
 
 
# we will use 5/18/2021 as the date of installation

# if we're going to do a before/after, its probably best to make the 
#    before/after periods equal
#    after:  5/18/2021 to 7/18/2022 (14 months)
#    before: 3/17/2020 to 5/17/2021 

# crimes in range before install, over 1 year 
crimes_inside_range %>%
  filter(CrimeDateTime >= "2020/03/17" & 
         CrimeDateTime < "2021/05/18")


# crimes in range after install, over 1 year 
crimes_inside_range %>%
  filter(CrimeDateTime >= "2021/05/18" & 
           CrimeDateTime < "2022/07/18")


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
 
 
 
 str(crimes_inside_range)
 
 
 
 
 
 
 # ------------------ 7/14/2022 ------------------------------------
 
  crime_locations <- DBI::dbGetQuery(con, 
                      'SELECT
                        RowID,
                        Latitude,
                        Longitude,
                        CrimeDateTime,
                        CrimeCode,
                        Location,
                        Description,
                        Inside_Outside,
                        WEAPON,
                        Gender,
                        Age,
                        Race,
                        Ethnicity,
                        District,
                        Neighborhood,
                        GeoLocation,
                        Premise,
                        Total_Incidents,
                        TYPE,
                        NAME,
                        CLASS,
                        VIOLENT_CR
                        VIO_PROP_CFS
                      FROM 
                        dbo.crime_1mile_square3')
 
   # collect all crimes prior and subsequent to install of cctv
 
 nrow(crime_locations)
 # [1] 7937
 
 
 colnames(crime_locations)
 
 
 skim(crime_locations)
 # -- Data Summary ------------------------
 #   Values         
 # Name                       crime_locations
 # Number of rows             7937           
 # Number of columns          22             
 # _______________________                   
 # Column type frequency:                    
 #   character                19             
 # numeric                  3              
 # ________________________                  
 # Group variables            None           
 # 
 # -- Variable type: character -------------------------------------------------------------
 #   skim_variable   n_missing complete_rate min max empty n_unique whitespace
 # 1 CrimeDateTime           0        1       27  27     0     7319          0
 # 2 CrimeCode               0        1        2   4     0       68          0
 # 3 Location               26        0.997   12  31     0      426          0
 # 4 Description             0        1        4  20     0       14          0
 # 5 Inside_Outside       1030        0.870    1   7     0        4          0
 # 6 WEAPON               4707        0.407    5   7     0        4          0
 # 7 Gender               1046        0.868    1   6     0        7          0
 # 8 Age                  1368        0.828    1   3     0      100          0
 # 9 Race                   46        0.994    5  32     0        5          0
 # 10 Ethnicity            7822        0.0145   7  22     0        4          0
 # 11 District                0        1        9   9     0        1          0
 # 12 Neighborhood            0        1        8  20     0       12          0
 # 13 GeoLocation             0        1       15  18     0     1655          0
 # 14 Premise              1035        0.870    3  20     0       95          0
 # 15 Total_Incidents         0        1        1   1     0        1          0
 # 16 TYPE                    0        1        4   4     0        1          0
 # 17 NAME                    0        1        6  26     0       67          0
 # 18 CLASS                   0        1        6   6     0        2          0
 # 19 VIO_PROP_CFS            0        1        4  14     0       10          0
 # 
 # -- Variable type: numeric ---------------------------------------------------------------
 #   skim_variable n_missing complete_rate     mean           sd    p0      p25      p50
 # 1 RowID                 0             1 253689.  154730.       80   116747   248374  
 # 2 Latitude              0             1     39.3      0.00422  39.3     39.3     39.3
 # 3 Longitude             0             1    -76.7      0.00478 -76.7    -76.7    -76.7
 # p75     p100 hist 
 # 1 391660   524267   <U+2587><U+2587><U+2586><U+2586><U+2587>
 #   2     39.3     39.3 <U+2583><U+2585><U+2585><U+2586><U+2587>
 #   3    -76.7    -76.7 <U+2582><U+2585><U+2587><U+2587><U+2586>
 #   > 
 # 
 
 # convert CrimeDateTime from chr to datetime object
 # ex: 2020-06-03 07:37:00.0000000
crime_locations$CrimeDateTime <- ymd_hms(crime_locations$CrimeDateTime) 

 skim(crime_locations)
 
 
 # install date
 # before install
 crime_locations
 
 
 
 # demo
 m <- leaflet() %>%
   addTiles() %>%  # Add default OpenStreetMap map tiles
   addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
 m  # Print the 
 
 
 
 # we use this date as the date of installation: 5/18/2021
 
 
# ============================================================================
# ============================================================================
 
 
 
# ----------   7/27/22 ----------------------------------------------
 
 crimes <- DBI::dbGetQuery(con, 
                          'SELECT
                              RowID,
                              Latitude,
                              Longitude,
                              CrimeDateTime,
                              CrimeCode,
                              Location,
                              Description,
                              Inside_Outside,
                              WEAPON,
                              Gender,
                              Age,
                              Race,
                              Ethnicity,
                              District,
                              Neighborhood,
                              GeoLocation,
                              Premise,
                              Total_Incidents,
                              TYPE,
                              NAME,
                              CLASS,
                              VIOLENT_CR
                              VIO_PROP_CFS
                            FROM 
                              dbo.crime_1mile_square3')
 
# check data types
glimpse(crimes)
 
#  Rows: 7,937
#  Columns: 22
#    $ RowID           <int> 76800, 77261, 321997, 349744, 381882, 455005, 463517, 481585, 487670, 415293, 42068~
#    $ Latitude        <dbl> 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39~
#    $ Longitude       <dbl> -76.6940, -76.6940, -76.6940, -76.6940, -76.6940, -76.6940, -76.6940, -76.6940, -76~
#    $ CrimeDateTime   <chr> "2020-06-03 07:37:00.0000000", "2020-06-03 07:37:00.0000000", "2015-04-11 19:00:00.~
#    $ CrimeCode       <chr> "4E", "4E", "7A", "6D", "3K", "5D", "3AF", "5A", "5A", "5A", "5A", "5A", "5A", "5A"~
#    $ Location        <chr> "3600 HILLSDALE RD", "3600 HILLSDALE RD", "3600 HILLSDALE RD", "3600 HILLSDALE RD",~
#    $ Description     <chr> "COMMON ASSAULT", "COMMON ASSAULT", "AUTO THEFT", "LARCENY FROM AUTO", "ROBBERY - R~
#    $ Inside_Outside  <chr> NA, NA, "O", "O", "I", "O", "O", "I", "I", "I", "I", "I", "I", "I", "O", "I", NA, N~
#    $ WEAPON          <chr> "HANDS", "HANDS", NA, NA, NA, NA, "FIREARM", NA, NA, NA, NA, NA, NA, NA, "FIREARM",~
#    $ Gender          <chr> "M", NA, "F", "F", "F", "M", "M", "M", "M", "F", "F", "F", "F", "M", "M", "F", "F",~
#    $ Age             <chr> "59", "25", "41", "59", "43", "58", "43", "56", "58", "50", "50", "50", "50", "53",~
#    $ Race            <chr> "BLACK_OR_AFRICAN_AMERICAN", "UNKNOWN", "BLACK_OR_AFRICAN_AMERICAN", "BLACK_OR_AFRI~
#    $ Ethnicity       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
#    $ District        <chr> "NORTHWEST", "NORTHWEST", "NORTHWEST", "NORTHWEST", "NORTHWEST", "NORTHWEST", "NORT~
#    $ Neighborhood    <chr> "HOWARD PARK", "HOWARD PARK", "HOWARD PARK", "HOWARD PARK", "HOWARD PARK", "HOWARD ~
#    $ GeoLocation     <chr> "(39.3315,-76.694)", "(39.3315,-76.694)", "(39.3315,-76.694)", "(39.3315,-76.694)",~
#    $ Premise         <chr> NA, NA, "STREET              ", "PARKING LOT-OUTSIDE ", "ROW/TOWNHOUSE-OCC", "SHED/~
#    $ Total_Incidents <chr> "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1"~
#    $ TYPE            <chr> "CTYP", "CTYP", "CTYP", "CTYP", "CTYP", "CTYP", "CTYP", "CTYP", "CTYP", "CTYP", "CT~
#    $ NAME            <chr> "COMMON ASSAULT", "COMMON ASSAULT", "STOLEN AUTO         ", "LARCENY- FROM AUTO  ",~
#    $ CLASS           <chr> "PART 2", "PART 2", "PART 1", "PART 1", "PART 1", "PART 1", "PART 1", "PART 1", "PA~
#    $ VIO_PROP_CFS    <chr> "COMMON ASSAULT", "COMMON ASSAULT", "AUTO THEFT", "LARCENY", "ROBBERY", "BURGLARY",~
#    > 

# convert all chrs to factors by mutating across all chr variables and
#   performing as_factor [unclass()?]
crimes <- as.data.frame(unclass(crimes),  
                       stringsAsFactors = TRUE)

# convert CrimeDateTime from factor to datetime object
# ex: 2020-06-03 07:37:00.0000000
crimes$CrimeDateTime <- ymd_hms(crimes$CrimeDateTime) 


# recheck data types
glimpse(crimes)


# Rows: 7,937
# Columns: 22
# $ RowID           <int> 76800, 77261, 321997, 349744, 381882, 455005, 463517, 481585, 487670, 415293, 42068~
#   $ Latitude        <dbl> 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39.3315, 39~
#   $ Longitude       <dbl> -76.6940, -76.6940, -76.6940, -76.6940, -76.6940, -76.6940, -76.6940, -76.6940, -76~
#   $ CrimeDateTime   <dttm> 2020-06-03 07:37:00, 2020-06-03 07:37:00, 2015-04-11 19:00:00, 2014-08-12 21:00:00~
#   $ CrimeCode       <fct> 4E, 4E, 7A, 6D, 3K, 5D, 3AF, 5A, 5A, 5A, 5A, 5A, 5A, 5A, 3CF, 4C, 6D, 3B, 3AK, 7A, ~
#   $ Location        <fct> 3600 HILLSDALE RD, 3600 HILLSDALE RD, 3600 HILLSDALE RD, 3600 HILLSDALE RD, 3600 HI~
#   $ Description     <fct> COMMON ASSAULT, COMMON ASSAULT, AUTO THEFT, LARCENY FROM AUTO, ROBBERY - RESIDENCE,~
#   $ Inside_Outside  <fct> NA, NA, O, O, I, O, O, I, I, I, I, I, I, I, O, I, NA, NA, O, O, I, I, I, NA, NA, I,~
#   $ WEAPON          <fct> HANDS, HANDS, NA, NA, NA, NA, FIREARM, NA, NA, NA, NA, NA, NA, NA, FIREARM, OTHER, ~
#   $ Gender          <fct> "M", NA, "F", "F", "F", "M", "M", "M", "M", "F", "F", "F", "F", "M", "M", "F", "F",~
#   $ Age             <fct> 59, 25, 41, 59, 43, 58, 43, 56, 58, 50, 50, 50, 50, 53, 59, 10, 50, 31, 25, 24, NA,~
#   $ Race            <fct> BLACK_OR_AFRICAN_AMERICAN, UNKNOWN, BLACK_OR_AFRICAN_AMERICAN, BLACK_OR_AFRICAN_AME~
#   $ Ethnicity       <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,~
#   $ District        <fct> NORTHWEST, NORTHWEST, NORTHWEST, NORTHWEST, NORTHWEST, NORTHWEST, NORTHWEST, NORTHW~
#   $ Neighborhood    <fct> HOWARD PARK, HOWARD PARK, HOWARD PARK, HOWARD PARK, HOWARD PARK, HOWARD PARK, HOWAR~
#   $ GeoLocation     <fct> "(39.3315,-76.694)", "(39.3315,-76.694)", "(39.3315,-76.694)", "(39.3315,-76.694)",~
#   $ Premise         <fct> NA, NA, STREET              , PARKING LOT-OUTSIDE , ROW/TOWNHOUSE-OCC, SHED/GARAGE,~
#   $ Total_Incidents <fct> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,~
#   $ TYPE            <fct> CTYP, CTYP, CTYP, CTYP, CTYP, CTYP, CTYP, CTYP, CTYP, CTYP, CTYP, CTYP, CTYP, CTYP,~
#   $ NAME            <fct> COMMON ASSAULT, COMMON ASSAULT, STOLEN AUTO         , LARCENY- FROM AUTO  , ROBB RE~
#   $ CLASS           <fct> PART 2, PART 2, PART 1, PART 1, PART 1, PART 1, PART 1, PART 1, PART 1, PART 1, PAR~
#   $ VIO_PROP_CFS    <fct> COMMON ASSAULT, COMMON ASSAULT, AUTO THEFT, LARCENY, ROBBERY, BURGLARY, ROBBERY, BU~
#   > 

# add column to indicate distance from cctv
# -----------------------------------------

# for each crime, calculate its distance from the cctv
# result will be in meters
crimes$dist_from_ctr_meters <- geosphere::distHaversine(
  p1 = crimes[ , c("Longitude", "Latitude")],
  p2 = c(-76.68489829, 39.33866714)  )

# check
head(crimes,5)

# RowID Latitude Longitude       CrimeDateTime CrimeCode          Location         Description
# 1  76800  39.3315   -76.694 2020-06-03 07:37:00        4E 3600 HILLSDALE RD      COMMON ASSAULT
# 2  77261  39.3315   -76.694 2020-06-03 07:37:00        4E 3600 HILLSDALE RD      COMMON ASSAULT
# 3 321997  39.3315   -76.694 2015-04-11 19:00:00        7A 3600 HILLSDALE RD          AUTO THEFT
# 4 349744  39.3315   -76.694 2014-08-12 21:00:00        6D 3600 HILLSDALE RD   LARCENY FROM AUTO
# 5 381882  39.3315   -76.694 2013-11-03 07:30:00        3K 3600 HILLSDALE RD ROBBERY - RESIDENCE
# Inside_Outside WEAPON Gender Age                      Race Ethnicity  District Neighborhood
# 1           <NA>  HANDS      M  59 BLACK_OR_AFRICAN_AMERICAN      <NA> NORTHWEST  HOWARD PARK
# 2           <NA>  HANDS   <NA>  25                   UNKNOWN      <NA> NORTHWEST  HOWARD PARK
# 3              O   <NA>      F  41 BLACK_OR_AFRICAN_AMERICAN      <NA> NORTHWEST  HOWARD PARK
# 4              O   <NA>      F  59 BLACK_OR_AFRICAN_AMERICAN      <NA> NORTHWEST  HOWARD PARK
# 5              I   <NA>      F  43 BLACK_OR_AFRICAN_AMERICAN      <NA> NORTHWEST  HOWARD PARK
# GeoLocation              Premise Total_Incidents TYPE                 NAME  CLASS   VIO_PROP_CFS
# 1 (39.3315,-76.694)                 <NA>               1 CTYP       COMMON ASSAULT PART 2 COMMON ASSAULT
# 2 (39.3315,-76.694)                 <NA>               1 CTYP       COMMON ASSAULT PART 2 COMMON ASSAULT
# 3 (39.3315,-76.694) STREET                             1 CTYP STOLEN AUTO          PART 1     AUTO THEFT
# 4 (39.3315,-76.694) PARKING LOT-OUTSIDE                1 CTYP LARCENY- FROM AUTO   PART 1        LARCENY
# 5 (39.3315,-76.694)    ROW/TOWNHOUSE-OCC               1 CTYP  ROBB RESIDENCE (UA) PART 1        ROBBERY
# dist_from_ctr_meters
# 1             1118.336
# 2             1118.336
# 3             1118.336
# 4             1118.336
# 5             1118.336
# > 


# convert meters to miles
crimes$dist_from_ctr_miles = crimes$dist_from_ctr_meters / 1609.34

# check
head(crimes,5)

# check
nrow(crimes)
# [1] 7937

# the cctv has a range of 256 ft ~ blocks
# 256 ft = .0485 mi

# find all those outside of cctv range
crimes_outside_range <- crimes %>%
  filter(dist_from_ctr_miles > 0.0485)

nrow(crimes_outside_range)
# [1] 7839


# find all those inside of cctv range
crimes_inside_range <- crimes %>%
  filter(dist_from_ctr_miles <= 0.0485)

nrow(crimes_inside_range)
# [1] 98


# find all ctimes witihn 256 wide ring outside of cctv range (256')

# calc cctv range + 256' beyond range
extended_area <- 2 * 0.0485
# 0.097

# find all those inside of cctv range
crimes_inside_extd_range <- 
  crimes %>%
  filter(dist_from_ctr_miles <= extended_area)

nrow(crimes_inside_extd_range)
# [1] 348

# to get 'donut' of crimes, from crime_inside_extd_range remove those 
#    within cctv range
crime_donut <- subset(crimes_inside_extd_range,
            !(
              (Longitude%in%crimes_inside_range$Longitude) & 
                ( Latitude%in%crimes_inside_range$Latitude)
            )
)

nrow(crime_donut)
# 236


# crime donut
leaflet(data = crime_donut) %>% 
  addTiles() %>%
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
                           # cctv range, center
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
  # mark cctv location
  setView(lng = -76.68489829, lat = 39.33866714, zoom = 17)
