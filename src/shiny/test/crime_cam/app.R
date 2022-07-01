# add harbor boundary area to map

# add  packages
library(shiny)
library(leaflet)


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Crime Cam"),
  
  
  # Show a map
  mainPanel(
    leafletOutput("crime_cam", width = '800px', height  = '600px')
  )
  
)

# 
server <- function(input, output) {
  
  output$crime_cam  <- renderLeaflet({
    
    crime_cam <- leaflet()
    crime_Cam <- addTiles(crime_cam)
    
    crime_cam <- setView(crime_cam, lng = -2.096, lat = 57.176, zoom = 9)
        #crime_cam <- setView(crime_cam, lng = 39.33, lat = -76.68, zoom = 9)
    
    #harbor <- setView(harbor, lng = 39.33866714, lat = -76.68489829, zoom = 9)
    
    #crime_cam <- addRectangles(crime_cam, lng1 = -2.096, lat1 = 57.176, lng2 = -1.978, lat2 = 57.101, weight = 1, group = "boundary" )
    #crime_cam <- addRectangles(crime_cam, lng1 = -1.795, lat1 = 57.512, lng2 = -1.735, lat2 = 57.472, weight = 1, group = "boundary" )
    #crime_Cam <- addLayersControl(crime_cam, overlayGroups = "boundary", options = layersControlOptions(collapsed = FALSE))
    
    
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
