# add crime_cam boundary area to map

# add packages
library(shiny)
library(leaflet)
library(DBI)        # connects to a DBMS
library(odbc)       # provides interface to ODBC drivers
library(config)     # manages environment specific config values

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
                        dbo.crime_1mile_square')

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Crime Camera"),
  
  
  # Show a map
  mainPanel(
    leafletOutput("crime_cam", width = '800px', height  = '600px')
  )
  
)

# 
server <- function(input, output) {
  
  output$crime_cam  <- renderLeaflet({
    
    crime_cam <- leaflet(data = crime_locations)
    crime_cam <- addTiles(crime_cam)
    crime_cam <- addMarkers(crime_locations, ~Longitude, ~Latitude)
    
    crime_cam <- setView(crime_cam, lng = -76.68489829, lat = 39.33866714, zoom = 17)
    
    #crime_cam <- setView(data = crime_cam, lng = ~Longitude, lat = ~Latitude, zoom = 17)
    
    
    
    #crime_cam <- addRectangles(crime_cam, lng1 = -2.096, lat1 = 57.176, lng2 = -1.978, lat2 = 57.101, weight = 1, group = "boundary" )
    #crime_cam <- addRectangles(crime_cam, lng1 = -1.795, lat1 = 57.512, lng2 = -1.735, lat2 = 57.472, weight = 1, group = "boundary" )
    #crime_cam <- addLayersControl(crime_cam, overlayGroups = "boundary", options = layersControlOptions(collapsed = FALSE))
    # 256' = 78.0288 meters
    
    crime_cam <-  addCircles(crime_cam, 
               lng = -76.68489829, 
               lat = 39.33866714, 
               weight = 1,
               radius = 78.0288, group = "crime")
    
    crime_cam <-  addCircles(crime_cam, 
                             lng = -76.68489829, 
                             lat = 39.33866714, 
                             weight = 1,
                             radius = 150, 
                             fillColor = "green",
                             fillOpacity = .05,                             
                             group = "crime")
    
    crime_cam <-  addCircles(crime_cam, 
                             lng = -76.68489829, 
                             lat = 39.33866714, 
                             weight = 1,
                             radius = 220, 
                             fillColor = "red",
                             fillOpacity = .05,
                             group = "crime")
    
    # locate cctv
    crime_cam <- addMarkers(crime_cam, lng = -76.68489829, lat = 39.33866714, group = "cime")
    
    
    # mark off area (square) of interest
    crime_cam <- addMarkers(crime_cam, lng = -76.694313, lat = 39.345848, group = "cime2")
    crime_cam <- addMarkers(crime_cam, lng = -76.675429, lat = 39.345848, group = "cime2")
    crime_cam <- addMarkers(crime_cam, lng = -76.694313, lat = 39.331448, group = "cime2")
    crime_cam <- addMarkers(crime_cam, lng = -76.675429, lat = 39.331448, group = "cime2")
    
    
    
    
  #  crime_cam <- addLayersControl(crime_cam, overlayGroups = "crime", options = layersControlOptions(collapsed = FALSE))
    
  #  crime_cam <- addLayersControl(crime_cam, overlayGroups = "cime2", options = layersControlOptions(collapsed = FALSE))
    
    crime_cam <- addLayersControl(crime_cam, overlayGroups = c("crime"), options = layersControlOptions(collapsed = FALSE))
    
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
