/*
#############################
##edited by duxin,2018-03-28#
#############################

###sql */
drop table if exists appzc.dx_dae_suc_current_default;
create table if not exists appzc.dx_dae_suc_current_default
  as
select 
     lv.user_id
     ,lv.listing_id
     ,lv.months
     ,lv.principal
     ,to_date(lv.auditing_date) as audday
     ,lv.bin_value
     ,llt.current_term
     ,llt.current_default_days
     ,llt.owing_principal
     ,isnull(duedate_1_op_pess	     ,0)  default_amount_1_1    /*   5+悲观逾期金额          */
     ,isnull(duedate_5_op_pess	     ,0)  default_amount_1_5    /*   5+悲观逾期金额          */
     ,isnull(duedate_10_op_pess	     ,0)  default_amount_1_10   /*   10+悲观逾期金额         */
     ,isnull(duedate_30_op_pess30	 ,0)  default_amount_1_30   /*   30+悲观逾期金额         */
     ,isnull(duedate_1m_30_op_pess30 ,0)  default_amount_2_30   /*   2期30+悲观逾期金额      */
     ,isnull(duedate_2m_30_op_pess30 ,0)  default_amount_3_30   /*   3期30+悲观逾期金额      */
     ,isnull(duedate_3m_30_op_pess30 ,0)  default_amount_4_30   /*   4期30+悲观逾期金额      */
     ,to_date(current_timestamp()) as upd

from
  ddm.listing_vintage as lv
inner join
  edw.list_loan_total_snp as llt
on
  lv.listing_id=llt.listing_id
  and llt.dt=to_date(current_timestamp())
inner join
  ods.listing as l
on
  l.listingid=lv.listing_id
where
  l.listtype=100 
  and l.sublisttype=3
  and llt.current_default_days>0
;








source("D:/source/impala_connect.R")
df <- dbGetQuery(con, 
"select  * 
from appzc.dx_dae_suc_current_default"
)

df$web=paste0("http://ppdadmin.ppdaicorp.com/user/home?id=",df$user_id,sep="")
df$web=paste0("<a href='",df$web,"'>",df$web,"</a>")
##
write.table(df,"D:/shiny_daily/chart_daily/default.txt",quote=FALSE,sep=",",row.names=FALSE,fileEncoding = "UTF-8") ##地址可更改 
