# Charger les bibliothèques
library(shiny)
library(plotly)
library(sf)
library(rnaturalearth)
library(ggplot2)
library(leaflet)
# Charger les données des événements
setwd('F:/ISE/projet_R/app_shiny/app_shiny')
base <- read.csv("ACLED-Western_Africa.csv")

# Création de l'application Shiny
ui <- fluidPage(
  
  # titre de l'application
  titlePanel("Carte des événements en Afrique de l'Ouest"),
  
  # Sidebar with filters for country, event type, and year
  sidebarLayout(
    sidebarPanel(
      selectInput(
        inputId = "pays",
        label = "Sélectionnez un pays",
        choices = c(unique(base$pays)),
        selected = c(unique(base$pays))[sample(1:length(unique(base$pays)),1)],
        multiple = TRUE
      ),
      selectInput(
        inputId = "evenement",
        label = "Sélectionnez un événement",
        choices = c(unique(base$type)),
        selected = "Protests",
        multiple = TRUE
      ),
      selectInput(
        inputId = "annee",
        label = "Sélectionnez une année",
        choices = c(unique(base$annee)),
        selected = "2023",
        multiple = TRUE
      )
    ),
    
    # Show the interactive map
    mainPanel(
      leafletOutput(outputId = "map", width = "100%", height = "720px")
    )
  )
)

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    # Filtrer les données en fonction des sélections de l'utilisateur
    filtered_data <- subset(base, pays %in% input$pays & type %in% input$evenement & annee %in% input$annee)
    
    # Créer la carte interactive avec leaflet
    leaflet() %>%
      # Ajouter les polygones des pays
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(data = ne_countries(type = "countries", country = input$pays),
                  fillColor = "lightblue", color = "gray", fillOpacity = 0.6,
                  group = "Pays") %>%
      # Ajouter les marqueurs pour chaque événement filtré
      addMarkers(data = filtered_data, lat = ~latitude, lng = ~longitude,
                 popup = ~paste("Pays: ", pays, "<br>",
                                "Type: ", type, "<br>",
                                "Année: ", annee, "<br>",
                                "Latitude: ", latitude, "<br>",
                                "Longitude: ", longitude),
                 clusterOptions = markerClusterOptions())
  })
}

# Lancer l'application Shiny
shinyApp(ui = ui, server = server)





