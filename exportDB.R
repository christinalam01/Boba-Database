install.packages("RPostgreSQL") 
library(RPostgreSQL) 
library(RSQLite)
library(DBI)
postgre_con <- dbConnect(RPostgres::Postgres(),
                         dbname = 'postgres', 
                         host = '127.0.0.1', 
                         port = 5432, 
                         user = 'postgres',
                         password = 'Dance!5678') 

# create object to represent all tables in the database
tables <- dbGetQuery(postgre_con, "SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname='public';")

# use rsqlite package to prepare a .db file
sqlite_conn <- dbConnect(RSQLite::SQLite(), dbname = "boba.db")

for (table_name in tables$tablename) {
  message(sprintf("Copying table: %s", table_name))
  # read data from postgresql
  query <- sprintf("SELECT * FROM %s", table_name)
  data <- dbGetQuery(postgre_con, query)
  
  # write data to sqlite
  dbWriteTable(sqlite_conn, table_name, data, overwrite = TRUE, row.names = FALSE)
}

dbDisconnect(postgre_con)
dbDisconnect(sqlite_conn)