shinyServer(function(input,output){
################################################################
#  cluster <- reactive({
#    kmeans(iris[,1:4],input$clusters)
#  })
#  # 缁樺埗鑱氱被缁撴灉
#  output$plot <- renderPlot({
#    plot(iris[,c(input$xcol,input$ycol)],
#         col=cluster()$cluster)
#    points(cluster()$centers[,c(input$xcol,input$ycol)],
#           col=1:input$clusters,pch="*",cex=4)
#  })
#    set.seed(122)
#  histdata <- rnorm(500)
#  output$plot1 <- renderPlot({
#    data <- histdata[seq_len(input$slider)]
#    hist(data)
###############################################################
#require(devtools)
#install_github('rCharts', 'ramnathv')
#devtools::install_github(‘lchiffon/REmap’)    #开发者/包名
library(reshape2)
library(REmap)
library(rCharts)
library(DBI)
#library(devtools)
library(RJDBC)
library(rJava)
library(highcharter)
#library(stats)
#library(graphics)
#library(grDevices)
#library(utils)
#library(datasets)
#library(methods)
#library(base)
library(bindrcpp)
library(ggradar)
library(scales)
library(data.table)
library(gridExtra)
library(dplyr)
library(xlsx)
library(xlsxjars)
library(ggthemes)
library(ggplot2)
library(shiny)
library(shinydashboard)

##deploy
#rsconnect::deployApp('D:/shiny')

#basic=read.table("basic.txt",header = TRUE,sep="\t",fileEncoding="UTF-16") ###错误：把csv存为utf格式
basic=read.table("basic.txt",header = TRUE,sep="",fileEncoding="UTF-8") ###正确


#####basic function
###三天&七天移动均值函数
threeseven=function(a){
h=c()
hh=c()
for (i in c(1:15)){
h0=mean(a[i:i+6],na.rm = TRUE)
hh0=mean(a[i:i+2],na.rm = TRUE)

h00=cbind(i,h0)
hh00=cbind(i,hh0)

h=rbind(h,h00)
hh=rbind(hh,hh00)
}
hhh=merge(h,hh,"i")
hhh=data.frame(seven=hhh$h0,three=hhh$hh0,ratio=round(hhh$hh0/hhh$h0,4))
return(hhh$ratio)
}
#####################################################################

###########################################################################basicinfo_start########################################################################
##雷达图
 output$spider1 <- renderPlot({
 mm=basic[is.na(basic$edu_score)==FALSE&is.na(basic$city_score)==FALSE&is.na(basic$usertype_score)==FALSE,]    
    mm=mm %>% 
        group_by(firstchuo) %>%
        summarise(edu=sum(edu_score)/n(),city=sum(city_score)/n(),usertype=sum(usertype_score)/n()) %>%
        arrange(desc(firstchuo)) %>% 
        mutate_at(vars(edu:usertype),funs(rescale))
    names(mm)=c("首次戳额日期","学历水平","城市分布","人群分布")    
    rada=ggradar(mm[c(1,1+input$slider),],)
    return(rada)
    })
##3天平均值/七日平均值    
output$threeseven1 <- renderChart2({ 
nn=basic %>% 
    group_by(firstchuo) %>%
    summarise(edu=sum(edu %in% c("研究生","本科"),na.rm=TRUE)/n(),
              city=sum(citylevel_pho %in% c(1,2),na.rm=TRUE)/n(),
              usertype=sum(usertype %in% c("全新","有额未发标"),na.rm=TRUE)/n()) %>% 
    arrange(desc(firstchuo)) 
mer=data.frame(id=nn$firstchuo[1:15],edu=threeseven(nn$edu),city=threeseven(nn$city),usertype=threeseven(nn$usertype))
names(mer)=c("id","高学历占比","一二线城市占比","全新和有额未发标客户占比")
mer=melt(mer,id="id")
plot <- hPlot(value~id, data =mer ,group = "variable",type = "line",title="三日平均值/七日平均值")
return(plot) 
 })
##学历
output$plot1 <- renderChart2({
edu=basic %>% group_by(firstchuo,edu) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = edu,group = "edu",type = "column",title="学历分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
}) 
##年龄
output$plot2 <- renderChart2({
age=basic[is.na(basic$age_bin)==FALSE,]
age=age %>% group_by(firstchuo,age_bin) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = age,
group = "age_bin",
type = "column",title="年龄分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)
})
##人群类型  
output$plot3 <- renderChart2({
usertype=basic %>% group_by(firstchuo,usertype) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = usertype,group = "usertype",type = "column",title="人群类型分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
}) 
##城市等级
output$plot4 <- renderChart2({
citylevel=basic %>% group_by(firstchuo,citylevel_bin) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = citylevel,group = "citylevel_bin",type = "column",title="城市等级分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
}) 
###########################################################################basicinfo_end########################################################################
###########################################################################modelcredit_start########################################################################
##雷达图
 output$spider2 <- renderPlot({
 
 dd=basic[is.na(basic$risk_score)==FALSE&is.na(basic$umeng_score)==FALSE&is.na(basic$jdcredit_score)==FALSE,]    
    dd=dd %>% 
        group_by(firstchuo) %>%
        summarise(bin=sum(bin_score)/n(),tc=sum(tc_score)/n(),um=sum(um_score)/n(),jd=sum(jd_score)/n()) %>%
        arrange(desc(firstchuo)) %>% 
        mutate_at(vars(bin:jd),funs(rescale))
    names(dd)=c("首次戳额日期","bin","腾讯分","友盟分","京东分")    
    rada=ggradar(dd[c(1,1+input$slider1),],)
    return(rada)
    })
##3天平均值/七日平均值    
output$threeseven2 <- renderChart2({ 
xx=basic %>% 
    group_by(firstchuo) %>%
    summarise(bin=sum(credit_bin ==1,na.rm=TRUE)/n(),tc=sum(risk_score <=20,na.rm=TRUE)/n(),um=sum(umeng_score>700,na.rm=TRUE)/n(),jd=sum(jdcredit_score>700,na.rm=TRUE)/n()) %>% 
    arrange(desc(firstchuo)) 
mer=data.frame(id=xx$firstchuo[1:15],bin=threeseven(xx$bin),tc=threeseven(xx$tc),um=threeseven(xx$um),jd=threeseven(xx$jd))
names(mer)=c("id","bin1占比","优质腾讯分占比","优质友盟分占比","优质京东分占比")

mer=melt(mer,id="id")
plot <- hPlot(value~id, data =mer ,group = "variable",type = "line",title="三日平均值/七日平均值")
return(plot) 
 })

##模型bin
output$plot5 <- renderChart2({
basic1=basic
basic1$credit_bin[basic1$credit_bin>=10]="十及以上"
basic1$credit_bin=paste("bin",basic1$credit_bin,sep="")
bin=basic1 %>% group_by(firstchuo,credit_bin) %>% summarise(num=n()) 
#order=c("bin1","bin2","bin3","bin4","bin5","bin6","bin7","bin8","bin9","bin10","bin10+")
#bin$credit_bin=factor(bin$credit_bin,levels=order)
plot <- hPlot(num~firstchuo, data = bin,group = "credit_bin",type = "column",title="模型bin分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
}) 
##腾讯分
output$plot6 <- renderChart2({
tc=basic[is.na(basic$risk_score)==FALSE,]
tc$tcbin=cut(tc$risk_score,breaks=c(0,20,40,60,80,100))
tc=tc %>% group_by(firstchuo,tcbin) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = tc,group = "tcbin",type = "column",title="腾讯分分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
}) 
##友盟分
output$plot7 <- renderChart2({
um=basic[is.na(basic$umeng_score)==FALSE,]
um$umbin=cut(um$umeng_score,breaks=c(300,400,500,600,700,850))
um=um %>% group_by(firstchuo,umbin) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = um,group = "umbin",type = "column",title="友盟分分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
}) 
##京东分
output$plot8 <- renderChart2({
jd=basic[is.na(basic$jdcredit_score)==FALSE,]
jd$jdbin=cut(jd$jdcredit_score,breaks=c(400,550,620,650,700,850))
jd=jd %>% group_by(firstchuo,jdbin) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = jd,group = "jdbin",type = "column",title="京东分分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
}) 
###########################################################################modelcredit_end########################################################################
###########################################################################asset_start########################################################################
##税前收入
output$plot9 <- renderChart2({
pre=basic %>% group_by(firstchuo,pretax) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = pre,group = "pretax",type = "column",title="税前收入分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
})
###有车 
output$plot10 <- renderChart2({
car=basic %>% group_by(firstchuo,iscar) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = car,group = "iscar",type = "column",title="有车人群分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
})
###有房 
output$plot11 <- renderChart2({
house=basic %>% group_by(firstchuo,ishouse) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = house,group = "ishouse",type = "column",title="有房人群分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
})
###有房&有车
output$plot12 <- renderChart2({
basic$housecar=ifelse(basic$iscar==1&basic$ishouse==1,1,0)
housecar=basic %>% group_by(firstchuo,housecar) %>% summarise(num=n()) 
plot <- hPlot(num~firstchuo, data = housecar,group = "housecar",type = "column",title="有房且有车人群分布")
plot$plotOptions(column = list(stacking = "percent"))
return(plot)    
})
###########################################################################asset_end########################################################################











})