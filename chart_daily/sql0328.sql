/*
#############################
##edited by duxin,2018-03-28#
#############################

###sql */
drop table if exists appzc.dx_flowmonitor_basicinfo;
create table appzc.dx_flowmonitor_basicinfo
as
select *
from (
select 
    userid,
    inserttime ,
    credit_bin,
    substring(inserttime,1,10) as firstchuo, 
    age,
    /*gender, */
    edu_cert,
    case when edu_cert='1' then '研究生' /* 研究生*/
         when edu_cert='2' then '本科' /* 本科*/
         when edu_cert='3' then '专科' /* 专科*/
         else '无学历' end as edu, 
    ROW_NUMBER()over(partition by mmv.userid order by mmv.inserttime asc) as flag
    
from ods.mobilemodelvariable mmv
where listingid=-1
and months=5 
and realname_renren_match in (3002,3003,3004) /* switch业务线*/
)dx1
where flag=1;

/* 基本信息展示*/
drop table if exists appzc.dx_flowmonitor_basicinfo1;
create table appzc.dx_flowmonitor_basicinfo1
as
select distinct *
from (
select 
a.*,
/*cmstr_idnm_pro as id_pro,
cmstr_idnm_city as id_city,
cmstr_pho_pro as pho_pro,
cmstr_pho_cit as pho_city,*/
cmstr_pho_pro as pho_pro,
c.`level` as citylevel_pho 
/*d.`level` as citylevel_id */

from appzc.dx_flowmonitor_basicinfo a

left join [shuffle] edw.common_user_daily b
on a.userid=b.user_id
and b.dt=strleft(cast(date_add(now(),-1) as string),10)

left join [shuffle] appzc.citylevel  c 
on b.cmstr_pho_cit=c.city

/*left join [shuffle] appzc.citylevel  d
on b.cmstr_idnm_city=d.city */
) dx2 ;

/*是否戳额*/
drop table if exists appzc.fxn_user_type_1;
create table appzc.fxn_user_type_1
as 
select userid,min(inserttime) as inserttime 
from ods.mobilemodelvariable 
where listingid=-1 
group by userid;

drop table if exists appzc.fxn_user_type_1_1;
create table appzc.fxn_user_type_1_1
as 
select *
from appzc.fxn_user_type_1 a 
where userid in (select userid from appzc.dx_flowmonitor_basicinfo1);

/*是否有额*/
drop table if exists appzc.fxn_user_type_2;
create table appzc.fxn_user_type_2
as 
select userid ,min(inserttime) as inserttime
from
(

    select userid,min(inserttime) as inserttime
    from ods.mobilemodelvariable
    where listingid=-1 and credit_amount>0
    group by userid 

    union all

    select borrowerid as userid,min(a.inserttime) as inserttime
    from ods.droolscreditlimitlog a 
    left join ods.listing b on a.listingid=b.listingid
    where a.creditLimit>0
    group by borrowerid

    union all 

    select userid,min(inserttime) as inserttime
    from ods.qudao_log_tb
    where cast(split_part( regexp_extract(droolsoutput,'.*creditLimit"": ""(.*),.*',1),'""',1) as int)>0
    group by userid 

) t 
group by userid ;


drop table if exists appzc.fxn_user_type_2_1;
create table appzc.fxn_user_type_2_1
as 
select *
from appzc.fxn_user_type_2 a 
where userid in (select userid from appzc.dx_flowmonitor_basicinfo1);

/*是否发额*/
drop table if exists appzc.fxn_user_type_3;
create table appzc.fxn_user_type_3
as 
select borrowerid as userid,min(inserttime) as inserttime from ods.listing group by borrowerid ;

drop table if exists appzc.fxn_user_type_3_1;
create table appzc.fxn_user_type_3_1
as 
select *
from appzc.fxn_user_type_3 a 
where userid in (select userid from appzc.dx_flowmonitor_basicinfo1);

/*是否成交*/
drop table if exists appzc.fxn_user_type_4;
create table appzc.fxn_user_type_4
as
select borrowerid as userid,min(inserttime) as inserttime 
from ods.listing where statusid in (4,12) group by borrowerid ;

drop table if exists appzc.fxn_user_type_4_1;
create table appzc.fxn_user_type_4_1
as 
select *
from appzc.fxn_user_type_4 a 
where userid in (select userid from appzc.dx_flowmonitor_basicinfo1);


drop table if exists appzc.dx_flowmonitor_basicinfo2;
create table appzc.dx_flowmonitor_basicinfo2
as 
select 
dx.userid,
dx.firstchuo,
dx.inserttime,
dx.credit_bin,
age,
edu,
citylevel_pho,
pho_pro,
case when chengjiao=1 then '已成交'
     when fabiao=1 and chengjiao=0 then '发标未成交'
     when youe=1 and fabiao=0 then '有额未发标'
     when chuoe=0 and fabiao=0 then '全新'
     when chuoe=1 and youe=0 then '戳额无额度' 
     else '其他' end as usertype /* 后期需要修改*/
from (

select a.*, 
  case when b.userid is not null then 1 else 0 end as chuoe,
  case when c.userid is not null then 1 else 0 end as youe,
  case when d.userid is not null then 1 else 0 end as fabiao,
  case when e.userid is not null then 1 else 0 end as chengjiao       
from appzc.dx_flowmonitor_basicinfo1 a 
left join appzc.fxn_user_type_1_1 b on a.inserttime>b.inserttime and a.userid=b.userid 
left join appzc.fxn_user_type_2_1 c on a.inserttime>c.inserttime and a.userid=c.userid 
left join appzc.fxn_user_type_3_1 d on a.inserttime>d.inserttime and a.userid=d.userid 
left join appzc.fxn_user_type_4_1 e on a.inserttime>e.inserttime and a.userid=e.userid 
 ) dx;

/* 模型类评分*/

drop table if exists appzc.dx_flowmonitor_basicinfo3;
create table appzc.dx_flowmonitor_basicinfo3
as 
select * 
from (
select 
a.*,
cast(b.score as decimal(38,2)) as jdcredit_score,
c.credit_score as umeng_score,
d.risk_score,
row_number()over(partition by a.userid order by b.inserttime desc, c.inserttime desc, d.inserttime desc) fl

from 
appzc.dx_flowmonitor_basicinfo2 a
    left join ods.jdcredit_score b on a.userid=b.userid and a.inserttime>b.inserttime
    left join ods.umeng_newscoreinfos c on a.userid=c.userid and a.inserttime>c.inserttime
    left join ods.social_score_info d on a.userid=d.userid  and a.inserttime>d.inserttime ) dx
where fl=1;
/* 资产*/
--税前收入
drop table if exists appzc.dx_flowmonitor_basicinfo4;
create table appzc.dx_flowmonitor_basicinfo4
as 
select * 
from 
(
select  a.*, 
        case when b.`result` is null or `result` in ('-1','-2','-3') then 'missing'
             when b.`result`='0' then '0-0'
             when b.`result` in ('a','b') then '0-02k'
             when b.`result` in ('c','d','e') then '02k-05k'
             when b.`result` in ('f','g','h') then '05k-08k'
             when b.`result` in ('i','j','k','l','m','n','o') then '08k-15k'
             when b.`result` in ('p','q','r','s','t','u','v','w','x','y') then '15k-30k'
             else '30k+'
             end as pretax ,
        cast(h.salaryincomeamountaverage6m as decimal(38,2)) as wangyin,
        cast(w.fundbasenumber as decimal(38,2))  as gjj,
        case when ys.userid is not null then 1 else 0 end as iscar,
        case when ly.userid is not null then 1 else 0 end as ishouse,
        row_number() over(partition by a.userid order by b.inserttime desc,h.inserttime desc,w.inserttime desc) fl1
from appzc.dx_flowmonitor_basicinfo3 a 

left join ods.pretax_income_level b 
on a.userid=b.userid and a.inserttime>b.inserttime

left join ods.bankbill_report_debitcard_details h 
on a.userid=h.userid and a.inserttime>h.inserttime

left join (
select
ppduserid as userid,
inserttime,
case when base_number=0 or base_number is null then (monthly_total_income/200)/0.085 else base_number/100 end as fundbasenumber
from ods.fund_userinfo )w
on a.userid=w.userid and a.inserttime>w.inserttime

left join 
(select distinct userid
from (
select userid 
from ods.rhzx_user_loanotherdetails  
where purpose='3' 

union all
 
select userid
from ods.CRD_CD_LN 
where type_dw like '%汽车%') c ) ys
on a.userid=ys.userid 

left join 
(select distinct userid
from (
select userid 
from ods.rhzx_user_loanhouse


union all
 
select userid
from ods.CRD_CD_LN 
where type_dw like '%房%') d ) ly
on a.userid=ly.userid 


) t 
where fl1=1 ;

/* 多头*/
drop table if exists appzc.dx_flowmonitor_basicinfo5;
create table appzc.dx_flowmonitor_basicinfo5
as 

select 
a.*,
b.final_score,
P2P_3m+small_loan_id_3m as td_3m,
P2P_1m+small_loan_id_1m as td_1m,


row_number() over(partition by a.userid order by b.inserttime desc,c.inserttime desc,w.inserttime desc) fl2

from appzc.dx_flowmonitor_basicinfo4 a

left join [shuffle] ods.tongdun_data b 
on a.userid=b.userid 
and a.inserttime>b.inserttime
left join [shuffle] 
(
select 
     userid
    ,to_date(inserttime) inserttime
    
    ,max(case when ruleid='3244586' then nvl(p2p_net_loan_idcard,0) else 0 end ) P2P_3m    
    ,max(case when ruleid='3244584' then nvl(p2p_net_loan_idcard,0) else 0 end ) P2P_1m
        
    ,max(case when ruleid='3244586' then nvl(small_loan_idcard,0) else 0 end ) small_loan_id_3m
    ,max(case when ruleid='3244584' then nvl(small_loan_idcard,0) else 0 end ) small_loan_id_1m
    from edw.tongdun_ruledetail
group by userid,inserttime
) c 
on a.userid=c.userid 
and a.inserttime>c.inserttime

left join [shuffle] 
(
select userid,max(month_between_3) as month_between_3,max(month_between_6) as month_between_6,max(month_between_1) as month_between_1
from 
(

select userid,sum(month_between_3) as month_between_3,sum(month_between_6) as month_between_6, sum(month_between_1) as month_between_1, count(*) as total
from 
(

    select userid,batchno, 
           case when month_between<=3 then 1 
                else 0 end as month_between_3,
           case when month_between<=6 then 1 
                else 0 end as month_between_6,
           case when month_between<=1 then 1 
                else 0 end as month_between_1,
          
           dense_rank()over(partition by userid order by batchno desc) flag

          from  
          (select t1.*,report_create_time,
           int_months_between(concat(substr(report_create_time,1,4),'-',substr(report_create_time,6,2),'-',substr(report_create_time,9,2)), concat(substr(Query_Date,1,4),'-',substr(Query_Date,6,2),'-',substr(Query_Date,9,2))) as month_between 
            from 
            ods.CRD_QR_RECORDDTLINFO t1               
            left join
            (select distinct batchno,report_create_time from ods.crd_hd_report) t2 
             on t1.batchno=t2.batchno
             where Query_Reason not like '%本人%' or Query_Reason not like '%个人%'  or Query_Reason not like '%贷后%'
               
               ) t )dx
where flag=1
group by userid 

union all

select userid ,sum(month_between_3) as month_between_3,sum(month_between_6) as month_between_6 ,sum(month_between_1) as month_between_1,count(*) as total
from 
(
    select userid,token,
           case when month_between<=3 then 1 
                else 0 end as month_between_3,
           case when month_between<=6 then 1 
                else 0 end as month_between_6,
           case when month_between<=1 then 1 
                else 0 end as month_between_1,
                     
           dense_rank() over(partition by userid order by token desc) flag 
           
 
    from (
    select 
    distinct userid,t1.token,
    orders,`date`,person, note,strleft(inserttime,10) insertdate,
    int_months_between(reportdate,strleft(`date`,10)) as month_between 
    from ods.rhzx_user_inquirydetails t1
    left join 
    (select distinct token,strleft(reportdate,10) as reportdate from ods.rhzx_user_information) t2 
    on t1.token=t2.token
    where `type`=1
    
    )b ) dx 
where flag=1 
group by userid  ) d 
group by userid )dx
on a.userid=dx.userid

















#################################################################################
source("D:/source/impala_connect.R")
basic <- dbGetQuery(con, 
"select  * 
from appzc.dx_flowmonitor_basicinfo4 
where adddate(firstchuo,31)>=current_timestamp() 
order by firstchuo desc"
)

#basic$citylevel_pho=as.numeric(basic$citylevel_pho)
#basic$citylevel_pho[is.na(basic$citylevel_pho)]=6

##basicinfo 数据处理
dealbasic=function(data){
data$fl=NULL
data$fl1=NULL
data$age_bin=cut(data$age,breaks=c(0,22,30,40,45,55,100)) ##年龄分段
#data$ppdbin=cut(data$credit_bin,breaks=c())
###对城市进行处理
data$citylevel_pho=as.numeric(data$citylevel_pho)
data$citylevel_pho[is.na(data$citylevel_pho)]=6
data$citylevel_bin=ifelse(data$citylevel_pho<6,sprintf("%i线",data$citylevel_pho),"6线及以下")

###准备雷达图数据
data$edu_score=ifelse(data$edu=="研究生",2,
    ifelse(data$edu=="本科",1,
    ifelse(data$edu=="专科",0,-1)))
data$city_score=ifelse(data$citylevel_pho==1,2,
    ifelse(data$citylevel_pho==2,1,
    ifelse(data$citylevel_pho %in% c(3,4),0,-1)))
data$usertype_score=
    ifelse(data$usertype=="全新",2,
    ifelse(data$usertype=="有额未发标",1,
    ifelse(data$usertype=="已成交" ,0,
    ifelse(data$usertype %in% c("戳额无额度","发标未成交"),-1,-2))))

data$bin_score=ifelse(data$credit_bin==1,2,
    ifelse(data$credit_bin %in% c(2,3),1,
    ifelse(data$credit_bin>3&data$credit_bin<=5,0,
    ifelse(data$credit_bin>5&data$credit_bin<=8,-1,-2))))
data$tc_score=ifelse(data$risk_score>0&data$risk_score<=20,2,
    ifelse(data$risk_score>20&data$risk_score<=40,1,
    ifelse(data$risk_score>40&data$risk_score<=60,0,
    ifelse(data$risk_score>60&data$risk_score<=80,-1,-2))))
data$um_score=ifelse(data$umeng_score>700&data$umeng_score<=850,2,
    ifelse(data$umeng_score>600&data$umeng_score<=700,1,
    ifelse(data$umeng_score>500&data$umeng_score<=600,0,
    ifelse(data$umeng_score>400&data$umeng_score<=500,-1,-2))))
data$jd_score=ifelse(data$jdcredit_score>700&data$jdcredit_score<=850,2,
    ifelse(data$jdcredit_score>650&data$jdcredit_score<=700,1,
    ifelse(data$jdcredit_score>620&data$jdcredit_score<=650,0,
    ifelse(data$jdcredit_score>550&data$jdcredit_score<=620,-1,-2))))

return(data)
}
basic=dealbasic(basic)
write.table(basic,"D:/shiny_forgithub123/basic.txt",quote=FALSE,row.names=FALSE,fileEncoding = "UTF-8") ##地址可更改   