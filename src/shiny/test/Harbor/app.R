# add harbor boundary area to map

# add packages
library(shiny)
library(leaflet)


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Harbor boundaries"),


        # Show a map
        mainPanel(
           leafletOutput("harbor", width = '800px', height  = '600px')
        )
    
)

# 
server <- function(input, output) {
  
  output$harbor  <- renderLeaflet({
    
    harbor <- leaflet()
    harbor <- addTiles(harbor)
    harbor <- setView(harbor, lng = -2.096, lat = 57.176, zoom = 9)
    harbor <- addRectangles(harbor, lng1 = -2.096, lat1 = 57.176, lng2 = -1.978, lat2 = 57.101, weight = 1, group = "boundary" )
    harbor <- addRectangles(harbor, lng1 = -1.795, lat1 = 57.512, lng2 = -1.735, lat2 = 57.472, weight = 1, group = "boundary" )
        harbor <- addLayersControl(harbor, overlayGroups = "boundary", options = layersControlOptions(collapsed = FALSE))
    
    
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
