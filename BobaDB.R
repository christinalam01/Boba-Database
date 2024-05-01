library(DBI)
library(shiny)
library(tidyr)
library(dplyr)

# retrieving data
db <- "postgres"
db_host <- "127.0.0.1"
db_port <- "5432"
db_user <- "postgres"
db_pass <- "Dance!5678"

conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = db,
  host = db_host,
  port = db_port,
  user = db_user,
  password = db_pass
)

dbListTables(conn)

menu.df <- dbGetQuery(conn, 'SELECT * FROM "Menu"')
shops.df <- dbGetQuery(conn, 'SELECT * FROM "Shops"')
dbDisconnect(conn)

# join tables
df <- merge(menu.df, shops.df)

# ui for server
ui <- fluidPage(
  titlePanel("Boba Shops"),
  
  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(4,
           selectInput("Shop_Name",
                       "Shop Name:",
                       c("All",
                         unique(as.character(menu.df$Shop_Name))))
    ),
    column(4,
           selectInput("Item_Category",
                       "Item Category:",
                       c("All",
                         unique(as.character(menu.df$Item_Category))))
    ),
    column(4,
           selectInput("Item_Name",
                       "Item Name:",
                       c("All",
                         unique(as.character(menu.df$Item_Name))))
    ),
    column(4,
           selectInput("Item_Size",
                       "Item Size:",
                       c("All",
                         unique(as.character(menu.df$Item_Size))))
    ),
    column(4,
           selectInput("Item_Cost",
                       "Item Cost:",
                       c("All",
                         unique(as.character(sort(menu.df$Item_Cost)))))
    )
  ),
  # Create a new row for the table.
  DT::dataTableOutput("table")
)


server <- function(input, output) {
  data <- reactive({
    # connect to database
    db <- "postgres"
    db_host <- "127.0.0.1"
    db_port <- "5432"
    db_user <- "postgres"
    db_pass <- "Dance!5678"
    
    conn <- dbConnect(
      RPostgres::Postgres(),
      dbname = db,
      host = db_host,
      port = db_port,
      user = db_user,
      password = db_pass
    )
    
    dbListTables(conn)
    
    menu.df <- dbGetQuery(conn, 'SELECT * FROM "Menu"')
    shops.df <- dbGetQuery(conn, 'SELECT * FROM "Shops"')
    
    menu.df <- merge(menu.df, shops.df) %>%
      select(Shop_Name, Item_Category, Item_Name, 
             Item_Size, Item_Cost, Shop_Address)
      
    dbDisconnect(conn)
    data.frame(menu.df)
  })

  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- data()

    if (input$Shop_Name != "All") {
      data <- filter(data, Shop_Name == input$Shop_Name)
    }
    if (input$Item_Category != "All") {
      data <- filter(data, Item_Category == input$Item_Category)
    }
    if (input$Item_Name != "All") {
      data <- filter(data, Item_Name == input$Item_Name)
    }
    if (input$Item_Size != "All") {
      data <- filter(data, Item_Size == input$Item_Size)
    }
    if (input$Item_Cost != "All") {
      data <- filter(data, Item_Cost == input$Item_Cost)
    }
    
    data
  }))
}

shinyApp(ui = ui, server = server)