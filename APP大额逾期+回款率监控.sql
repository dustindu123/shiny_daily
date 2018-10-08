/*大额逾期 监控中间表*/
drop table appzc.wanqiu_dae_suc_vintage_monitor;
create table appzc.wanqiu_dae_suc_vintage_monitor
  as
select 
      user_id,listing_id,lv.months,principal,auditing_date,bin_value
     ,case when strright(strleft(mmv.mark,6),2)='wb' then '微粒贷' 
       when strright(strleft(mmv.mark,6),2)='fd' then '公积金'
       when strright(strleft(mmv.mark,6),2)='tb' then '淘宝'
       when strright(strleft(mmv.mark,6),2)='bb' then '网银'
       else 'no_mode'
       end as mode
     ,first_chuo_usertype
     ,case when bb.has_jiebei>0 or gxb.jiebei_amt>0 then 1 else 0 end as jiebei
     ,case when bb.has_jiebei>0 or gxb.jiebei_amt>0 or bb.has_webank>0 then 1 else 0 end as jiebei_webank
     ,isnull(bb.has_webank,0) as has_webank
     ,dx.linetype
     ,isnull(duedate_1_op_pess	     ,0)  default_amount_1_1    /*   5+悲观逾期金额          */
     ,isnull(duedate_2_op_pess	     ,0)  default_amount_1_2    /*   5+悲观逾期金额          */
     ,isnull(duedate_3_op_pess	     ,0)  default_amount_1_3    /*   5+悲观逾期金额          */
     ,isnull(duedate_4_op_pess	     ,0)  default_amount_1_4    /*   5+悲观逾期金额          */
     ,isnull(duedate_5_op_pess	     ,0)  default_amount_1_5    /*   5+悲观逾期金额          */
     ,isnull(duedate_10_op_pess	     ,0)  default_amount_1_10   /*   10+悲观逾期金额         */
     ,isnull(duedate_30_op_pess30	 ,0)  default_amount_1_30   /*   30+悲观逾期金额         */
     ,isnull(duedate_1m_30_op_pess30 ,0)  default_amount_2_30   /*   2期30+悲观逾期金额      */
     ,isnull(duedate_2m_30_op_pess30 ,0)  default_amount_3_30   /*   3期30+悲观逾期金额      */
     ,isnull(duedate_3m_30_op_pess30 ,0)  default_amount_4_30   /*   4期30+悲观逾期金额      */
     ,isnull(duedate_4m_30_op_pess30 ,0)  default_amount_5_30   /*   5期30+悲观逾期金额      */
     ,isnull(duedate_5m_30_op_pess30 ,0)  default_amount_6_30   /*   6期30+悲观逾期金额      */
     ,isnull(duedate_6m_30_op_pess30 ,0)  default_amount_7_30   /*   7期30+悲观逾期金额      */
     ,isnull(duedate_7m_30_op_pess30 ,0)  default_amount_8_30   /*   8期30+悲观逾期金额      */
     ,isnull(duedate_8m_30_op_pess30 ,0)  default_amount_9_30   /*   9期30+悲观逾期金额      */
     ,isnull(duedate_9m_30_op_pess30 ,0)  default_amount_10_30  /*   11期30+悲观逾期金额      */
     ,isnull(duedate_10m_30_op_pess30,0)  default_amount_11_30  /*   11期30+悲观逾期金额      */
	 ,isnull(duedate_11m_30_op_pess30,0)  default_amount_12_30  /*   12期30+悲观逾期金额      */
	,case when adddate(add_months(auditing_date,1),1)<current_timestamp()   then 1 else 0 end as 'is_1_1'    /*   可看5+          */
	,case when adddate(add_months(auditing_date,1),2)<current_timestamp()   then 1 else 0 end as 'is_1_2'    /*   可看5+          */
	,case when adddate(add_months(auditing_date,1),3)<current_timestamp()   then 1 else 0 end as 'is_1_3'    /*   可看5+          */
	,case when adddate(add_months(auditing_date,1),4)<current_timestamp()   then 1 else 0 end as 'is_1_4'    /*   可看5+          */
	,case when adddate(add_months(auditing_date,1),5)<current_timestamp()   then 1 else 0 end as 'is_1_5'    /*   可看5+          */
    ,case when adddate(add_months(auditing_date,1),10)<current_timestamp()  then 1 else 0 end as 'is_1_10'   /*   可看10+         */
    ,case when adddate(add_months(auditing_date,1),30)<current_timestamp()  then 1 else 0 end as 'is_1_30'   /*   可看30+         */
	,case when adddate(add_months(auditing_date,2),30)<current_timestamp()  then 1 else 0 end as 'is_2_30'   /*   可看2期30+    */
	,case when adddate(add_months(auditing_date,3),30)<current_timestamp()  then 1 else 0 end as 'is_3_30'   /*   可看3期30+    */
	,case when adddate(add_months(auditing_date,4),30)<current_timestamp()  then 1 else 0 end as 'is_4_30'   /*   可看4期30+    */
	,case when adddate(add_months(auditing_date,5),30)<current_timestamp()  then 1 else 0 end as 'is_5_30'   /*   可看5期30+    */
	,case when adddate(add_months(auditing_date,6),30)<current_timestamp()  then 1 else 0 end as 'is_6_30'   /*   可看6期30+    */
	,case when adddate(add_months(auditing_date,7),30)<current_timestamp()  then 1 else 0 end as 'is_7_30'   /*   可看7期30+    */
	,case when adddate(add_months(auditing_date,8),30)<current_timestamp()  then 1 else 0 end as 'is_8_30'   /*   可看8期30+    */
	,case when adddate(add_months(auditing_date,9),30)<current_timestamp()  then 1 else 0 end as 'is_9_30'   /*   可看9期30+    */
	,case when adddate(add_months(auditing_date,10),30)<current_timestamp() then 1 else 0 end as 'is_10_30'  /*   可看11期30     */
	,case when adddate(add_months(auditing_date,11),30)<current_timestamp() then 1 else 0 end as 'is_11_30'  /*   可看11期30     */
	,case when adddate(add_months(auditing_date,12),30)<current_timestamp() then 1 else 0 end as 'is_12_30'  /*   可看12期30     */
    ,mmv.credit_bin
    ,mmv.mark
    ,row_number()over(partition by user_id order by listing_id) num
from
  ods.listing as l
inner join
  ddm.listing_vintage as lv
on
  l.listingid=lv.listing_id
left join
  ods.mobilemodelvariable as mmv
on
  l.listingid=mmv.listingid
  and mmv.par_dt>='2018-04'
left join
  appzc.dx_datatable_chuo as dx
on
  dx.userid=l.borrowerid
left join
  appzc.yqqsuperapp_bb_webank_jiebei as bb
on
  l.borrowerid=bb.userid
left join
  appzc.yqqsuperapp_gxb_jiebei as gxb
on
  l.borrowerid=gxb.userid
where
  l.listtype=100 
  and l.sublisttype=3
  and l.creationdate>'2018-04-01'
;


/*vintage-分客群*/
select first_chuo_usertype,substr(auditing_date,1,7) as suc_months
       ,cast( sum(case when is_1_1=1   then default_amount_1_1   else 0 end)*100/ sum(case when is_1_1=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_1    /*   vintage_金额逾期率1+          */
       ,cast( sum(case when is_1_5=1   then default_amount_1_5   else 0 end)*100/ sum(case when is_1_5=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_5    /*   vintage_金额逾期率5+          */
     ,cast( sum(case when is_1_10=1  then default_amount_1_10  else 0 end)*100/ sum(case when is_1_10=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_10   /*   vintage_金额逾期率10+         */
     ,cast( sum(case when is_1_30=1  then default_amount_1_30  else 0 end)*100/ sum(case when is_1_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_30   /*   vintage_金额逾期率30+         */
     ,cast( sum(case when is_2_30=1  then default_amount_2_30  else 0 end)*100/ sum(case when is_2_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_2_30   /*   vintage_金额逾期率2期30+    */
     ,cast( sum(case when is_3_30=1  then default_amount_3_30  else 0 end)*100/ sum(case when is_3_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_3_30   /*   vintage_金额逾期率3期30+    */
     ,cast( sum(case when is_4_30=1  then default_amount_4_30  else 0 end)*100/ sum(case when is_4_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_4_30   /*   vintage_金额逾期率4期30+    */
     ,cast( sum(case when is_5_30=1  then default_amount_5_30  else 0 end)*100/ sum(case when is_5_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_5_30   /*   vintage_金额逾期率5期30+    */
     ,cast( sum(case when is_6_30=1  then default_amount_6_30  else 0 end)*100/ sum(case when is_6_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_6_30   /*   vintage_金额逾期率6期30+    */
     ,cast( sum(case when is_7_30=1  then default_amount_7_30  else 0 end)*100/ sum(case when is_7_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_7_30   /*   vintage_金额逾期率7期30+    */
     ,cast( sum(case when is_8_30=1  then default_amount_8_30  else 0 end)*100/ sum(case when is_8_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_8_30   /*   vintage_金额逾期率8期30+    */
     ,cast( sum(case when is_9_30=1  then default_amount_9_30  else 0 end)*100/ sum(case when is_9_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_9_30   /*   vintage_金额逾期率9期30+    */
     ,cast( sum(case when is_10_30=1 then default_amount_10_30 else 0 end)*100/ sum(case when is_10_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_10_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_11_30=1 then default_amount_11_30 else 0 end)*100/ sum(case when is_11_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_11_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_12_30=1 then default_amount_12_30 else 0 end)*100/ sum(case when is_12_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_12_30  /*   vintage_金额逾期率12期30     */
from appzc.wanqiu_dae_suc_vintage_monitor  
where first_chuo_usertype is not null
group by substr(auditing_date,1,7),first_chuo_usertype
order by substr(auditing_date,1,7),first_chuo_usertype
;


/*vintage-分模式*/
select mode,substr(auditing_date,1,7) as suc_months
       ,cast( sum(case when is_1_1=1   then default_amount_1_1   else 0 end)*100/ sum(case when is_1_1=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_1    /*   vintage_金额逾期率1+          */
       ,cast( sum(case when is_1_5=1   then default_amount_1_5   else 0 end)*100/ sum(case when is_1_5=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_5    /*   vintage_金额逾期率5+          */
     ,cast( sum(case when is_1_10=1  then default_amount_1_10  else 0 end)*100/ sum(case when is_1_10=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_10   /*   vintage_金额逾期率10+         */
     ,cast( sum(case when is_1_30=1  then default_amount_1_30  else 0 end)*100/ sum(case when is_1_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_30   /*   vintage_金额逾期率30+         */
     ,cast( sum(case when is_2_30=1  then default_amount_2_30  else 0 end)*100/ sum(case when is_2_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_2_30   /*   vintage_金额逾期率2期30+    */
     ,cast( sum(case when is_3_30=1  then default_amount_3_30  else 0 end)*100/ sum(case when is_3_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_3_30   /*   vintage_金额逾期率3期30+    */
     ,cast( sum(case when is_4_30=1  then default_amount_4_30  else 0 end)*100/ sum(case when is_4_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_4_30   /*   vintage_金额逾期率4期30+    */
     ,cast( sum(case when is_5_30=1  then default_amount_5_30  else 0 end)*100/ sum(case when is_5_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_5_30   /*   vintage_金额逾期率5期30+    */
     ,cast( sum(case when is_6_30=1  then default_amount_6_30  else 0 end)*100/ sum(case when is_6_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_6_30   /*   vintage_金额逾期率6期30+    */
     ,cast( sum(case when is_7_30=1  then default_amount_7_30  else 0 end)*100/ sum(case when is_7_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_7_30   /*   vintage_金额逾期率7期30+    */
     ,cast( sum(case when is_8_30=1  then default_amount_8_30  else 0 end)*100/ sum(case when is_8_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_8_30   /*   vintage_金额逾期率8期30+    */
     ,cast( sum(case when is_9_30=1  then default_amount_9_30  else 0 end)*100/ sum(case when is_9_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_9_30   /*   vintage_金额逾期率9期30+    */
     ,cast( sum(case when is_10_30=1 then default_amount_10_30 else 0 end)*100/ sum(case when is_10_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_10_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_11_30=1 then default_amount_11_30 else 0 end)*100/ sum(case when is_11_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_11_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_12_30=1 then default_amount_12_30 else 0 end)*100/ sum(case when is_12_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_12_30  /*   vintage_金额逾期率12期30     */
from appzc.wanqiu_dae_suc_vintage_monitor 
where mode<>'no_mode' 
group by substr(auditing_date,1,7),mode 
order by substr(auditing_date,1,7),mode
;


/*vintage-分渠道*/
select linetype,substr(auditing_date,1,7) as suc_months
       ,cast( sum(case when is_1_1=1   then default_amount_1_1   else 0 end)*100/ sum(case when is_1_1=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_1    /*   vintage_金额逾期率1+          */
       ,cast( sum(case when is_1_5=1   then default_amount_1_5   else 0 end)*100/ sum(case when is_1_5=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_5    /*   vintage_金额逾期率5+          */
     ,cast( sum(case when is_1_10=1  then default_amount_1_10  else 0 end)*100/ sum(case when is_1_10=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_10   /*   vintage_金额逾期率10+         */
     ,cast( sum(case when is_1_30=1  then default_amount_1_30  else 0 end)*100/ sum(case when is_1_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_30   /*   vintage_金额逾期率30+         */
     ,cast( sum(case when is_2_30=1  then default_amount_2_30  else 0 end)*100/ sum(case when is_2_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_2_30   /*   vintage_金额逾期率2期30+    */
     ,cast( sum(case when is_3_30=1  then default_amount_3_30  else 0 end)*100/ sum(case when is_3_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_3_30   /*   vintage_金额逾期率3期30+    */
     ,cast( sum(case when is_4_30=1  then default_amount_4_30  else 0 end)*100/ sum(case when is_4_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_4_30   /*   vintage_金额逾期率4期30+    */
     ,cast( sum(case when is_5_30=1  then default_amount_5_30  else 0 end)*100/ sum(case when is_5_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_5_30   /*   vintage_金额逾期率5期30+    */
     ,cast( sum(case when is_6_30=1  then default_amount_6_30  else 0 end)*100/ sum(case when is_6_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_6_30   /*   vintage_金额逾期率6期30+    */
     ,cast( sum(case when is_7_30=1  then default_amount_7_30  else 0 end)*100/ sum(case when is_7_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_7_30   /*   vintage_金额逾期率7期30+    */
     ,cast( sum(case when is_8_30=1  then default_amount_8_30  else 0 end)*100/ sum(case when is_8_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_8_30   /*   vintage_金额逾期率8期30+    */
     ,cast( sum(case when is_9_30=1  then default_amount_9_30  else 0 end)*100/ sum(case when is_9_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_9_30   /*   vintage_金额逾期率9期30+    */
     ,cast( sum(case when is_10_30=1 then default_amount_10_30 else 0 end)*100/ sum(case when is_10_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_10_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_11_30=1 then default_amount_11_30 else 0 end)*100/ sum(case when is_11_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_11_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_12_30=1 then default_amount_12_30 else 0 end)*100/ sum(case when is_12_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_12_30  /*   vintage_金额逾期率12期30     */
from appzc.wanqiu_dae_suc_vintage_monitor
where linetype is not null  
group by substr(auditing_date,1,7),linetype
order by substr(auditing_date,1,7),linetype
;


/*vintage-有借呗*/
select jiebei,substr(auditing_date,1,7) as suc_months
       ,cast( sum(case when is_1_1=1   then default_amount_1_1   else 0 end)*100/ sum(case when is_1_1=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_1    /*   vintage_金额逾期率1+          */
       ,cast( sum(case when is_1_5=1   then default_amount_1_5   else 0 end)*100/ sum(case when is_1_5=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_5    /*   vintage_金额逾期率5+          */
     ,cast( sum(case when is_1_10=1  then default_amount_1_10  else 0 end)*100/ sum(case when is_1_10=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_10   /*   vintage_金额逾期率10+         */
     ,cast( sum(case when is_1_30=1  then default_amount_1_30  else 0 end)*100/ sum(case when is_1_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_30   /*   vintage_金额逾期率30+         */
     ,cast( sum(case when is_2_30=1  then default_amount_2_30  else 0 end)*100/ sum(case when is_2_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_2_30   /*   vintage_金额逾期率2期30+    */
     ,cast( sum(case when is_3_30=1  then default_amount_3_30  else 0 end)*100/ sum(case when is_3_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_3_30   /*   vintage_金额逾期率3期30+    */
     ,cast( sum(case when is_4_30=1  then default_amount_4_30  else 0 end)*100/ sum(case when is_4_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_4_30   /*   vintage_金额逾期率4期30+    */
     ,cast( sum(case when is_5_30=1  then default_amount_5_30  else 0 end)*100/ sum(case when is_5_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_5_30   /*   vintage_金额逾期率5期30+    */
     ,cast( sum(case when is_6_30=1  then default_amount_6_30  else 0 end)*100/ sum(case when is_6_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_6_30   /*   vintage_金额逾期率6期30+    */
     ,cast( sum(case when is_7_30=1  then default_amount_7_30  else 0 end)*100/ sum(case when is_7_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_7_30   /*   vintage_金额逾期率7期30+    */
     ,cast( sum(case when is_8_30=1  then default_amount_8_30  else 0 end)*100/ sum(case when is_8_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_8_30   /*   vintage_金额逾期率8期30+    */
     ,cast( sum(case when is_9_30=1  then default_amount_9_30  else 0 end)*100/ sum(case when is_9_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_9_30   /*   vintage_金额逾期率9期30+    */
     ,cast( sum(case when is_10_30=1 then default_amount_10_30 else 0 end)*100/ sum(case when is_10_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_10_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_11_30=1 then default_amount_11_30 else 0 end)*100/ sum(case when is_11_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_11_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_12_30=1 then default_amount_12_30 else 0 end)*100/ sum(case when is_12_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_12_30  /*   vintage_金额逾期率12期30     */
from appzc.wanqiu_dae_suc_vintage_monitor 
group by substr(auditing_date,1,7),jiebei
order by substr(auditing_date,1,7),jiebei
;


/*vintage-有微粒贷*/
select has_webank,substr(auditing_date,1,7) as suc_months
       ,cast( sum(case when is_1_1=1   then default_amount_1_1   else 0 end)*100/ sum(case when is_1_1=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_1    /*   vintage_金额逾期率1+          */
       ,cast( sum(case when is_1_5=1   then default_amount_1_5   else 0 end)*100/ sum(case when is_1_5=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_5    /*   vintage_金额逾期率5+          */
     ,cast( sum(case when is_1_10=1  then default_amount_1_10  else 0 end)*100/ sum(case when is_1_10=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_10   /*   vintage_金额逾期率10+         */
     ,cast( sum(case when is_1_30=1  then default_amount_1_30  else 0 end)*100/ sum(case when is_1_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_30   /*   vintage_金额逾期率30+         */
     ,cast( sum(case when is_2_30=1  then default_amount_2_30  else 0 end)*100/ sum(case when is_2_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_2_30   /*   vintage_金额逾期率2期30+    */
     ,cast( sum(case when is_3_30=1  then default_amount_3_30  else 0 end)*100/ sum(case when is_3_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_3_30   /*   vintage_金额逾期率3期30+    */
     ,cast( sum(case when is_4_30=1  then default_amount_4_30  else 0 end)*100/ sum(case when is_4_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_4_30   /*   vintage_金额逾期率4期30+    */
     ,cast( sum(case when is_5_30=1  then default_amount_5_30  else 0 end)*100/ sum(case when is_5_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_5_30   /*   vintage_金额逾期率5期30+    */
     ,cast( sum(case when is_6_30=1  then default_amount_6_30  else 0 end)*100/ sum(case when is_6_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_6_30   /*   vintage_金额逾期率6期30+    */
     ,cast( sum(case when is_7_30=1  then default_amount_7_30  else 0 end)*100/ sum(case when is_7_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_7_30   /*   vintage_金额逾期率7期30+    */
     ,cast( sum(case when is_8_30=1  then default_amount_8_30  else 0 end)*100/ sum(case when is_8_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_8_30   /*   vintage_金额逾期率8期30+    */
     ,cast( sum(case when is_9_30=1  then default_amount_9_30  else 0 end)*100/ sum(case when is_9_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_9_30   /*   vintage_金额逾期率9期30+    */
     ,cast( sum(case when is_10_30=1 then default_amount_10_30 else 0 end)*100/ sum(case when is_10_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_10_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_11_30=1 then default_amount_11_30 else 0 end)*100/ sum(case when is_11_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_11_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_12_30=1 then default_amount_12_30 else 0 end)*100/ sum(case when is_12_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_12_30  /*   vintage_金额逾期率12期30     */
from appzc.wanqiu_dae_suc_vintage_monitor 
group by substr(auditing_date,1,7),has_webank
order by substr(auditing_date,1,7),has_webank
;


/*vintage-有借呗/微粒贷*/
select jiebei_webank,substr(auditing_date,1,7) as suc_months
       ,cast( sum(case when is_1_1=1   then default_amount_1_1   else 0 end)*100/ sum(case when is_1_1=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_1    /*   vintage_金额逾期率1+          */
       ,cast( sum(case when is_1_5=1   then default_amount_1_5   else 0 end)*100/ sum(case when is_1_5=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_5    /*   vintage_金额逾期率5+          */
     ,cast( sum(case when is_1_10=1  then default_amount_1_10  else 0 end)*100/ sum(case when is_1_10=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_10   /*   vintage_金额逾期率10+         */
     ,cast( sum(case when is_1_30=1  then default_amount_1_30  else 0 end)*100/ sum(case when is_1_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_30   /*   vintage_金额逾期率30+         */
     ,cast( sum(case when is_2_30=1  then default_amount_2_30  else 0 end)*100/ sum(case when is_2_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_2_30   /*   vintage_金额逾期率2期30+    */
     ,cast( sum(case when is_3_30=1  then default_amount_3_30  else 0 end)*100/ sum(case when is_3_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_3_30   /*   vintage_金额逾期率3期30+    */
     ,cast( sum(case when is_4_30=1  then default_amount_4_30  else 0 end)*100/ sum(case when is_4_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_4_30   /*   vintage_金额逾期率4期30+    */
     ,cast( sum(case when is_5_30=1  then default_amount_5_30  else 0 end)*100/ sum(case when is_5_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_5_30   /*   vintage_金额逾期率5期30+    */
     ,cast( sum(case when is_6_30=1  then default_amount_6_30  else 0 end)*100/ sum(case when is_6_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_6_30   /*   vintage_金额逾期率6期30+    */
     ,cast( sum(case when is_7_30=1  then default_amount_7_30  else 0 end)*100/ sum(case when is_7_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_7_30   /*   vintage_金额逾期率7期30+    */
     ,cast( sum(case when is_8_30=1  then default_amount_8_30  else 0 end)*100/ sum(case when is_8_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_8_30   /*   vintage_金额逾期率8期30+    */
     ,cast( sum(case when is_9_30=1  then default_amount_9_30  else 0 end)*100/ sum(case when is_9_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_9_30   /*   vintage_金额逾期率9期30+    */
     ,cast( sum(case when is_10_30=1 then default_amount_10_30 else 0 end)*100/ sum(case when is_10_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_10_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_11_30=1 then default_amount_11_30 else 0 end)*100/ sum(case when is_11_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_11_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_12_30=1 then default_amount_12_30 else 0 end)*100/ sum(case when is_12_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_12_30  /*   vintage_金额逾期率12期30     */
from appzc.wanqiu_dae_suc_vintage_monitor 
group by substr(auditing_date,1,7),jiebei_webank
order by substr(auditing_date,1,7),jiebei_webank
;


/*金额回款率*/
select
  suc_months,
  (default_amount_ratio_1_1-default_amount_ratio_1_5)/default_amount_ratio_1_1 as '1-5back',
  (default_amount_ratio_1_1-default_amount_ratio_1_10)/default_amount_ratio_1_1 as '1-10back',
  (default_amount_ratio_1_1-default_amount_ratio_1_30)/default_amount_ratio_1_1 as '1-30back',
  (default_amount_ratio_1_5-default_amount_ratio_1_10)/default_amount_ratio_1_5 as '5-10back',
  (default_amount_ratio_1_5-default_amount_ratio_1_30)/default_amount_ratio_1_5 as '5-30back',
  (default_amount_ratio_1_10-default_amount_ratio_1_30)/default_amount_ratio_1_10 as '10-30back'
from
(
select substr(auditing_date,1,7) as suc_months
       ,cast( sum(case when is_1_1=1   then default_amount_1_1   else 0 end)*100/ sum(case when is_1_1=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_1    /*   vintage_金额逾期率1+          */
       ,cast( sum(case when is_1_5=1   then default_amount_1_5   else 0 end)*100/ sum(case when is_1_5=1   then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_5    /*   vintage_金额逾期率5+          */
     ,cast( sum(case when is_1_10=1  then default_amount_1_10  else 0 end)*100/ sum(case when is_1_10=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_10   /*   vintage_金额逾期率10+         */
     ,cast( sum(case when is_1_30=1  then default_amount_1_30  else 0 end)*100/ sum(case when is_1_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_1_30   /*   vintage_金额逾期率30+         */
     ,cast( sum(case when is_2_30=1  then default_amount_2_30  else 0 end)*100/ sum(case when is_2_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_2_30   /*   vintage_金额逾期率2期30+    */
     ,cast( sum(case when is_3_30=1  then default_amount_3_30  else 0 end)*100/ sum(case when is_3_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_3_30   /*   vintage_金额逾期率3期30+    */
     ,cast( sum(case when is_4_30=1  then default_amount_4_30  else 0 end)*100/ sum(case when is_4_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_4_30   /*   vintage_金额逾期率4期30+    */
     ,cast( sum(case when is_5_30=1  then default_amount_5_30  else 0 end)*100/ sum(case when is_5_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_5_30   /*   vintage_金额逾期率5期30+    */
     ,cast( sum(case when is_6_30=1  then default_amount_6_30  else 0 end)*100/ sum(case when is_6_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_6_30   /*   vintage_金额逾期率6期30+    */
     ,cast( sum(case when is_7_30=1  then default_amount_7_30  else 0 end)*100/ sum(case when is_7_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_7_30   /*   vintage_金额逾期率7期30+    */
     ,cast( sum(case when is_8_30=1  then default_amount_8_30  else 0 end)*100/ sum(case when is_8_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_8_30   /*   vintage_金额逾期率8期30+    */
     ,cast( sum(case when is_9_30=1  then default_amount_9_30  else 0 end)*100/ sum(case when is_9_30=1  then principal else 0 end) as decimal(38,2)) default_amount_ratio_9_30   /*   vintage_金额逾期率9期30+    */
     ,cast( sum(case when is_10_30=1 then default_amount_10_30 else 0 end)*100/ sum(case when is_10_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_10_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_11_30=1 then default_amount_11_30 else 0 end)*100/ sum(case when is_11_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_11_30  /*   vintage_金额逾期率11期30     */
     ,cast( sum(case when is_12_30=1 then default_amount_12_30 else 0 end)*100/ sum(case when is_12_30=1 then principal else 0 end) as decimal(38,2)) default_amount_ratio_12_30  /*   vintage_金额逾期率12期30     */
from appzc.wanqiu_dae_suc_vintage_monitor  
where first_chuo_usertype is not null
group by substr(auditing_date,1,7)
) as a
order by suc_months
;


/*标回款率*/
select
  suc_months,
  (default_lid_ratio_1_1-default_lid_ratio_1_5)/default_lid_ratio_1_1 as '1-5back',
  (default_lid_ratio_1_1-default_lid_ratio_1_10)/default_lid_ratio_1_1 as '1-10back',
  (default_lid_ratio_1_1-default_lid_ratio_1_30)/default_lid_ratio_1_1 as '1-30back',
  (default_lid_ratio_1_5-default_lid_ratio_1_10)/default_lid_ratio_1_5 as '5-10back',
  (default_lid_ratio_1_5-default_lid_ratio_1_30)/default_lid_ratio_1_5 as '5-30back',
  (default_lid_ratio_1_10-default_lid_ratio_1_30)/default_lid_ratio_1_10 as '10-30back'
from
(
select substr(auditing_date,1,7) as suc_months
     ,cast( sum(case when is_1_1=1   and default_amount_1_1   >0 then 1 else 0 end)*100/ sum(case when is_1_1=1   then 1 else 0 end) as decimal(38,2)) default_lid_ratio_1_1
     ,cast( sum(case when is_1_5=1   and default_amount_1_5   >0 then 1 else 0 end)*100/ sum(case when is_1_5=1   then 1 else 0 end) as decimal(38,2)) default_lid_ratio_1_5
     ,cast( sum(case when is_1_10=1  and default_amount_1_10  >0 then 1 else 0 end)*100/ sum(case when is_1_10=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_1_10 
     ,cast( sum(case when is_1_30=1  and default_amount_1_30  >0 then 1 else 0 end)*100/ sum(case when is_1_30=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_1_30
     ,cast( sum(case when is_2_30=1  and default_amount_2_30  >0 then 1 else 0 end)*100/ sum(case when is_2_30=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_2_30
     ,cast( sum(case when is_3_30=1  and default_amount_3_30  >0 then 1 else 0 end)*100/ sum(case when is_3_30=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_3_30
     ,cast( sum(case when is_4_30=1  and default_amount_4_30  >0 then 1 else 0 end)*100/ sum(case when is_4_30=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_4_30
     ,cast( sum(case when is_5_30=1  and default_amount_5_30  >0 then 1 else 0 end)*100/ sum(case when is_5_30=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_5_30
     ,cast( sum(case when is_6_30=1  and default_amount_6_30  >0 then 1 else 0 end)*100/ sum(case when is_6_30=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_6_30
     ,cast( sum(case when is_7_30=1  and default_amount_7_30  >0 then 1 else 0 end)*100/ sum(case when is_7_30=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_7_30
     ,cast( sum(case when is_8_30=1  and default_amount_8_30  >0 then 1 else 0 end)*100/ sum(case when is_8_30=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_8_30
     ,cast( sum(case when is_9_30=1  and default_amount_9_30  >0 then 1 else 0 end)*100/ sum(case when is_9_30=1  then 1 else 0 end) as decimal(38,2)) default_lid_ratio_9_30
     ,cast( sum(case when is_10_30=1 and default_amount_10_30 >0 then 1 else 0 end)*100/ sum(case when is_10_30=1 then 1 else 0 end) as decimal(38,2)) default_lid_ratio_10_30
     ,cast( sum(case when is_11_30=1 and default_amount_11_30 >0 then 1 else 0 end)*100/ sum(case when is_11_30=1 then 1 else 0 end) as decimal(38,2)) default_lid_ratio_11_30
     ,cast( sum(case when is_12_30=1 and default_amount_12_30 >0 then 1 else 0 end)*100/ sum(case when is_12_30=1 then 1 else 0 end) as decimal(38,2)) default_lid_ratio_12_30
from appzc.wanqiu_dae_suc_vintage_monitor  
where first_chuo_usertype is not null
group by substr(auditing_date,1,7)
) as a
order by suc_months
;