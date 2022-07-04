library(shiny)
library(leaflet)

ui <- fluidPage(
  sliderInput(inputId = "slider", 
              label = "values",
              min = 0,
              max = 100,
              value = 0,
              step = 1),
  leafletOutput("my_leaf")
)

server <- function(input, output, session){
  set.seed(123456)
  df <- data.frame(latitude = sample(seq(-38.5, -37.5, by = 0.01), 100),
                   longitude = sample(seq(144.0, 145.0, by = 0.01), 100),
                   value = seq(1,100))
  
  ## create static element
  output$my_leaf <- renderLeaflet({
    
    leaflet() %>%
      #addProviderTiles('Hydda.Full') %>%
      setView(lat = -37.8, lng = 144.8, zoom = 8)
    
  })
  
  ## filter data
  df_filtered <- reactive({
    df[df$value >= input$slider, ]
  })
  
  ## respond to the filtered data
  observe({
    
    leafletProxy(mapId = "my_leaf", data = df_filtered()) %>%
      clearMarkers() %>%   ## clear previous markers
      addMarkers()
  })
  
}

shinyApp(ui, server)