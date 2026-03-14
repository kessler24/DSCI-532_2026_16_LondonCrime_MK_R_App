library(shiny)
library(bslib)
library(dplyr)
library(plotly)
 

crime_data <- read.csv("data/raw/LondonCrimeData.csv")
 

BOROUGHS <- sort(c(
  'Barking and Dagenham', 'Waltham Forest', 'Tower Hamlets', 'Sutton',
  'Southwark', 'Richmond upon Thames', 'Redbridge', 'Newham', 'Merton',
  'Lewisham', 'Lambeth', 'Kingston upon Thames', 'Kensington and Chelsea',
  'Islington', 'Hounslow', 'Wandsworth', 'Hillingdon', 'Harrow', 'Haringey',
  'Hammersmith and Fulham', 'Hackney', 'Greenwich', 'Enfield', 'Ealing',
  'Croydon', 'City of London', 'Camden', 'Bromley', 'Brent', 'Bexley',
  'Barnet', 'Havering', 'Westminster'
))
 

ui <- page_navbar(
  title = "Crime in London",
  nav_panel(
    "Dashboard",
    tags$style("
      .bslib-value-box { min-height: 120px !important; }
      .bslib-card { min-height: 500px; }
    "),
    layout_sidebar(
      sidebar = sidebar(
        sliderInput(
          "year_range",
          "Year Range",
          min = 2008, max = 2016,
          value = c(2008, 2016),
          sep = ""
        ),
        selectizeInput(
          "borough_1",
          "Select Borough 1:",
          choices  = BOROUGHS,
          selected = "Croydon",
          multiple = FALSE
        ),
        selectizeInput(
          "borough_2",
          "Select Borough 2:",
          choices  = BOROUGHS,
          selected = "City of London",
          multiple = FALSE
        ),
        actionButton("reset_filter", "Restore Defaults"),
        open = "desktop"
      ),

      layout_columns(
        value_box(
          title = textOutput("borough_label_1"),
          value = textOutput("crime_rate_1"),
          p("crimes per month on average"),
          textOutput("year_label_1")
        ),
        value_box(
          title = textOutput("borough_label_2"),
          value = textOutput("crime_rate_2"),
          p("crimes per month on average"),
          textOutput("year_label_2")
        ),
        value_box(
          title = "London (All Boroughs)",
          value = textOutput("crime_rate_london"),
          p("crimes per month on average"),
          textOutput("year_label_london")
        ),
        fill = FALSE
      ),
      card(plotlyOutput("borough_trend"), full_screen = TRUE)
    ),
  )
)
 
server <- function(input, output, session) {
 
  # Reactive calculations to filter data
  
  year_label <- reactive({
    start <- input$year_range[1]
    end   <- input$year_range[2]
    if (start == end) as.character(start) else paste(start, "-", end)
  })
 
  calc_crime_rate <- function(df_reactive) {
    df <- df_reactive()
    if (nrow(df) == 0) return("No Data")
    monthly_crimes <- df |>
      group_by(year, month) |>
      summarise(n = n(), .groups = "drop")
    as.character(round(mean(monthly_crimes$n)))
  }
  
  # Create filtered data
 
  filtered_data_1 <- reactive({
    crime_data |>
      filter(year >= input$year_range[1], year <= input$year_range[2], borough == input$borough_1)
  })
 
  filtered_data_2 <- reactive({
    crime_data |>
      filter(year >= input$year_range[1], year <= input$year_range[2], borough == input$borough_2)
  })
 
  filtered_data_london <- reactive({
    crime_data |>
      filter(year >= input$year_range[1], year <= input$year_range[2])
  })
 
  filtered_data_both <- reactive({
    crime_data |>
      filter(
        year    >= input$year_range[1],
        year    <= input$year_range[2],
        borough %in% c(input$borough_1, input$borough_2)
      )
  })
 
  # Year and Borough Labels
 
  output$year_label_1 <- renderText({ year_label() })
  output$year_label_2 <- renderText({ year_label() })
  output$year_label_london <- renderText({ year_label() })
 
  output$borough_label_1 <- renderText({ input$borough_1 })
  output$borough_label_2 <- renderText({ input$borough_2 })
 
  # Average Crime Rate
 
  output$crime_rate_1      <- renderText({ calc_crime_rate(filtered_data_1) })
  output$crime_rate_2      <- renderText({ calc_crime_rate(filtered_data_2) })
  output$crime_rate_london <- renderText({ calc_crime_rate(filtered_data_london) })
  
  # Plot
 
  output$borough_trend <- renderPlotly({
    df <- filtered_data_both()
    if (nrow(df) == 0) return(plot_ly() |> layout(title = "No data — select boroughs"))
    
    df_grouped <- df |>
      group_by(borough, major_category) |>
      summarise(count = n(), .groups = "drop")
    
    crime_order <- df_grouped |>
      group_by(major_category) |>
      summarise(total = sum(count), .groups = "drop") |>
      arrange(total) |>
      pull(major_category)
    
    df_grouped <- df_grouped |>
      mutate(major_category = factor(major_category, levels = crime_order))
    
    plot_ly(
      df_grouped,
      x     = ~borough,
      y     = ~count,
      color = ~major_category,
      type  = "bar"
    ) |>
      layout(
        barmode = "stack",
        title   = "Amount of Crime by Borough",
        xaxis   = list(title = "Borough"),
        yaxis   = list(title = "Number of Crimes"),
        legend  = list(title = list(text = "Crime Type"))
      )
  })
 
  # Reset button
 
  observeEvent(input$reset_filter, {
    updateSliderInput(session,    "year_range", value    = c(2008, 2016))
    updateSelectizeInput(session, "borough_1",  selected = "Croydon")
    updateSelectizeInput(session, "borough_2",  selected = "City of London")
  })
}
 
shinyApp(ui, server)
 

