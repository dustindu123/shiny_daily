options(shiny.sanitize.errors = FALSE)
library(shiny)
library(shinydashboard)
library(DT)

default=read.table("default.txt",header = TRUE,sep="",fileEncoding="UTF-8") ###正确


shinyServer(function(input,output){

  selectedData <- reactive({
  default[as.Date(as.character(default$audday)) >= min(input$dates) & as.Date(as.character(default$audday)) <= max(input$dates)&default$current_default_days>=input$num,]
  })

output$rate = renderDataTable({
df=selectedData()
df=df[,1:9]
names(df)=c("uid","listingid","借款期限","借款本金","成交日期","bin","当前期数","逾期天数","应还本金")
datatable(df,caption = 'app大额当前逾期人群')
})
  
  })