# add crime_cam boundary area to map

# add packages
library(shiny)
library(leaflet)


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
    
    crime_cam <- leaflet()
    crime_cam <- addTiles(crime_cam)
    crime_cam <- setView(crime_cam, lng = -76.68489829, lat = 39.33866714, zoom = 20)
    #crime_cam <- addRectangles(crime_cam, lng1 = -2.096, lat1 = 57.176, lng2 = -1.978, lat2 = 57.101, weight = 1, group = "boundary" )
    #crime_cam <- addRectangles(crime_cam, lng1 = -1.795, lat1 = 57.512, lng2 = -1.735, lat2 = 57.472, weight = 1, group = "boundary" )
    #crime_cam <- addLayersControl(crime_cam, overlayGroups = "boundary", options = layersControlOptions(collapsed = FALSE))
    # 256' = 78.0288 meters
    
    crime_cam <-  addCircles(crime_cam, 
               lng = -76.68489829, 
               lat = 39.33866714, 
               weight = 1,
               radius = 78.0288, group = "crime")
    
    crime_cam <- addMarkers(crime_cam, lng = -76.68489829, lat = 39.33866714, group = "cime")
    
    crime_cam <- addLayersControl(crime_cam, overlayGroups = "crime", options = layersControlOptions(collapsed = FALSE))
    
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
