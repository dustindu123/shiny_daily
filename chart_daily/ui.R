options(shiny.sanitize.errors = FALSE)
library(shiny)
library(DT)
#library(praise)

library(shinydashboard)
####
#basic=read.table("basicinfo.txt",header = TRUE,sep="",fileEncoding="UTF-8") ###正确
#basic$firstchuo=as.character(basic$firstchuo)

default=read.table("default.txt",header = TRUE,sep="",fileEncoding="UTF-8") ###正确

####


dashboardPage(
 dashboardHeader(title="日常表格"),##标题
 dashboardSidebar(
    a(img(src="pho.jpg",height=120,width=200),
    href="http://ppdadmin.ppdaicorp.com/home/index",target="black"),
     sidebarMenu(
        menuItem("日常表格", tabName = "日常表格", icon = icon("dashboard"))

        #menuItem("人群画像", tabName = "人群画像", icon = icon("dashboard"),startExpanded = TRUE,
        #menuSubItem("基本信息", tabName = "基本信息"),
        #menuSubItem("模型类评分", tabName = "模型类评分"),
        #menuSubItem("收入", tabName = "收入"),
        #menuSubItem("用户资质", tabName = "用户资质"),
        #menuSubItem("用户负债", tabName = "用户负债"),        
        #menuSubItem("多头", tabName = "多头")
        #menuSubItem("不良", tabName = "不良")
        #),
      
        #menuItem("渠道质量监控", tabName = "渠道质量监控", icon = icon("dashboard"),startExpanded = TRUE,
        #menuSubItem("渠道全流程转化", tabName = "渠道全流程转化"),
        #menuSubItem("APP推广渠道", tabName = "APP推广渠道"),
        #menuSubItem("M站推广渠道", tabName = "M站推广渠道")
        )
    
),
 dashboardBody(
tabItems(
      tabItem("日常表格", 
        fluidRow(
            box(dateRangeInput("dates", h4("成交时间选择"),
               start = "2018-05-02",               
               end = as.character(format(as.Date(max(as.character(default$audday)))),"yyyy-mm-dd"),
               min = "2018-05-02",               
               max = as.character(format(as.Date(max(as.character(default$audday)))),"yyyy-mm-dd"),
               format = "yyyy-mm-dd"),width=12),
            box( numericInput("num", label = h4("逾期天数下限"), value = 1,min=1),width=12),
            box(dataTableOutput("rate"),width=12)
          )
        )
       )

)
)