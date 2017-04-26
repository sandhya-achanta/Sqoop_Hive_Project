--create user_total table to load data
CREATE TABLE IF NOT EXISTS user_total (time_ran timestamp,total_users int,users_added int);
--report query
select a.ts,a.total,case when (a.total-b.difflastrun) is null then 0 else (a.total-b.difflastrun) end 
from (SELECT from_unixtime(unix_timestamp()) as ts,count(*) as total from user) a,
(select sum(total_users) as difflastrun from user_total 
where time_ran > from_unixtime(unix_timestamp()))b;
-- report query using insert statement
insert into user_total
select a.ts,a.total,case when (a.total-b.difflastrun) is null then 0 else (a.total-b.difflastrun) end 
from (SELECT from_unixtime(unix_timestamp()) as ts,count(*) as total from user) a,
(select sum(total_users) as difflastrun from user_total 
where time_ran > from_unixtime(unix_timestamp()))b;
-- write a shell script to run job when we required( need to check with robert)