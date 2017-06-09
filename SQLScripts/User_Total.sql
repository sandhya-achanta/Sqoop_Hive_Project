  #!/bin/sh
 #User_report Automation
hive -d --database user_active_dump
hive -e "CREATE TABLE IF NOT EXISTS user_active_dump.user_total (time_ran timestamp,total_users int,users_added int);"
hive -e "use user_active_dump;insert into user_total
select a.ts,a.total,case when (a.total-b.difflastrun) is null then 0 else (a.total-b.difflastrun) end 
from (SELECT from_unixtime(unix_timestamp()) as ts,count(*) as total from user) a,
(select sum(total_users) as difflastrun from user_total 
where time_ran > from_unixtime(unix_timestamp()))b;"

