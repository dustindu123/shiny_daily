# ui.R

##rsconnect::setAccountInfo(name='flowmonitordustin', token='F85B9DCD0C7EF69CCCE006389C540131', secret='5pitClbpqfWzsWdcA4K7OnJZnP5lJZUKWBLXDIv8')
library(shiny)
library(shinydashboard)
library(rCharts)
library(REmap)
dashboardPage(
 dashboardHeader(title="流量监控"),##标题
 dashboardSidebar(
    #selectInput("xcol","X Variable",names(iris)),
    #selectInput("ycol","Y Variable",names(iris),selected="Sepal.Width"),
    #numericInput("clusters","Cluster count",3,min=2,max=9),
    #a(img(src="logo.png",height=60,width=200),
    #href="https://www.hellobi.com/event/137",target="black")
     sidebarMenu(
      menuItem("基本信息", tabName = "基本信息", icon = icon("dashboard")),
      menuItem("模型类评分", tabName = "模型类评分", icon = icon("dashboard")),
      menuItem("收入&资产", tabName = "收入&资产", icon = icon("dashboard"))
    )
),
 dashboardBody(
tabItems(
      # First tab content
      tabItem(tabName = "基本信息",
        fluidRow(
          box(
            title = "距今天数",
            sliderInput("slider", "Number of observations:", 1, 30, 15),
            h3("注:"),
            h4("通过对各维度的不同取值赋权,形成该维度下的得分,最终以左图形式呈现")
          ),
          box(plotOutput("spider1")),
          box(showOutput("threeseven1","highcharts")),       
          box(showOutput("plot1","highcharts")),       
          box(showOutput("plot2","highcharts")),
          box(showOutput("plot3","highcharts")),
          box(showOutput("plot4","highcharts"))          
        )
      ),

      # Second tab content
      tabItem(tabName = "模型类评分",             
        fluidRow(
          box(
            title = "距今天数",
            sliderInput("slider1", "Number of observations:", 1, 30, 15),
            h3("注:"),
            h4("通过对各维度的不同取值赋权,形成该维度下的得分,最终以左图形式呈现")
          ),
          box(plotOutput("spider2")),
          box(showOutput("threeseven2","highcharts")),       
          box(showOutput("plot5","highcharts")),       
          box(showOutput("plot6","highcharts")),
          box(showOutput("plot7","highcharts")),
          box(showOutput("plot8","highcharts"))          
        )
     ),
     
     # Third tab content
      tabItem(tabName = "收入&资产",             
        fluidRow(

          box(showOutput("plot9","highcharts")),       
          box(showOutput("plot10","highcharts")),
          box(showOutput("plot11","highcharts")),
          box(showOutput("plot12","highcharts"))          

        )
     )

  )
 )
)
