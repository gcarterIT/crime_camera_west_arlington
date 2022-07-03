# load libraries
library(gridExtra)  # arrange multiplot in a page grid
library(DBI)        # connects to a DBMS
library(odbc)       # provides interface to ODBC drivers
library(config)     # manages environment specific config values
library(janitor)    # examine and clean dirty data
library(dplyr)      # grammar of data manipulation
library(plyr)       # implement split-apply-combine pattern
library(corrplot) # create correlation matrix
library(here)     # ease referencing of project work files
library(skimr)


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
crime_locations <- DBI::dbGetQuery(con, 'SELECT top 10 
                        Latitude,
                        Longitude
                      FROM 
                        dbo.crime_data_draft1')


head(crime_locations)


skim(crime_locations)