options(shiny.sanitize.errors = FALSE)
library(shiny)
library(shinydashboard)
library(DT)

default=read.table("default.txt",header = TRUE,sep=",",fileEncoding="UTF-8") ###正确


shinyServer(function(input,output){

  selectedData <- reactive({
  default[as.Date(as.character(default$audday)) >= min(input$dates) & as.Date(as.character(default$audday)) <= max(input$dates)&default$current_default_days>=input$num,]
  })

output$rate = renderDataTable({
df=selectedData()
df=df[,c(1:9,18)]
names(df)=c("uid","listingid","借款期限","借款本金","成交日期","bin","当前期数","逾期天数","应还本金","网址")
datatable(df,caption = sprintf("app大额当前逾期人群_更新至 %s",unique(selectedData()$upd)),escape = FALSE)
  })
  
   })