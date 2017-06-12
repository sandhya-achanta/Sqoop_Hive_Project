        #!/bin/sh
cd /home/cloudera/user_upload_dump_dir
for file in  $(find . -type f -name "user_upload_dump.*")
do
  echo "Processing $file file..."
  # take action on each file. 
  cd /home/cloudera/
  #create directory to be process
  mkdir /home/cloudera/user_upload_dump_WorkInProgress
  #create directory to stage processed file 
  mkdir /home/cloudera/user_upload_dump_loadedfiles
  cd /home/cloudera/user_upload_dump_dir
  #move each file to user_upload_dump_WorkInProgress
  mv  $file  /home/cloudera/user_upload_dump_WorkInProgress
  #remove special character ":" before saving file to hadoop
  cd /home/cloudera/user_upload_dump_WorkInProgress
  mv $file ${file//:};
  #remove directory if exists
  hadoop dfs -rmr /user/cloudera/user_upload_dump_WorkInProgress
  #copy file Directory to HDFS
  hadoop fs -put /home/cloudera/user_upload_dump_WorkInProgress
  #hadoop fs -cat  /user/cloudera/user_upload_dump_WorkInProgress/$file
  hive -e "load data  inpath '/user/cloudera/user_upload_dump_WorkInProgress' into  table user_active_dump.user_upload_dump;"
  #move prcoessed files to  user_upload_dump_loadedfiles
  mv /home/cloudera/user_upload_dump_WorkInProgress/*  /home/cloudera/user_upload_dump_loadedfile
  #remove file from user_upload_dump_WorkInProgress directory incase it failed to move. 
  rm -r /home/cloudera/user_upload_dump_WorkInProgress
done
hadoop dfs -rmr /user/cloudera/user
sqoop  import --connect jdbc:mysql://localhost/user_active_log --username root --password-file  /user/cloudera/sqoop_passwordfile/password  \
--table user --hive-import --hive-overwrite\
  --hive-table user_active_dump.user --driver com.mysql.jdbc.Driver
#execute sqoop job
sqoop job -exec activity_log


# autoating user_report table
  hive -d --database user_active_dump
hive -e "insert OVERWRITE TABLE user_active_dump.user_report
SELECT user.id as user_id, 
CASE WHEN s1.totinserts > 0 then s1.totinserts else 0 END as total_inserts,
CASE WHEN s2.totupdates > 0 then s2.totupdates else 0 END as total_updates,
CASE WHEN s3.totdeletes > 0 then s3.totdeletes else 0 END as total_deletes,
CASE WHEN s4.type is not null then s4.type END as last_activity_type,
CASE WHEN s5.active > 0 then true  else false END as is_active,
CASE WHEN s6.upload_count > 0 then s6.upload_count else 0 END as upload_count
FROM user_active_dump.user 
                  left outer JOIN
                (SELECT  user_id,count(*) as totinserts
                 FROM  user_active_dump.activitylog where type = 'INSERT'
                 GROUP BY user_id) S1 
ON S1.user_id = user.id 
left outer JOIN
                (SELECT  user_id,count(*) as totupdates
                 FROM  user_active_dump.activitylog where type = 'UPDATE'
                 GROUP BY user_id) S2 
ON S2.user_id = user.id
left outer JOIN
                (SELECT  user_id,count(*) as totdeletes
                 FROM  user_active_dump.activitylog where  type = 'DELETE'
                 GROUP BY user_id) S3 
ON S3.user_id = user.id 
left outer JOIN (select t1.user_id as user_id ,type from user_active_dump.activitylog t1
join (
  select user_id, max(timestamp) maxModified from user_active_dump.activitylog
  group by user_id
) s
on t1.user_id  = s.user_id and t1.timestamp = s.maxModified) S4 
ON S4.user_id = user.id
left outer JOIN (SELECT user_id,count(*) as active  FROM  user_active_dump.activitylog  WHERE timestamp between ( unix_timestamp() -2*24*60*60) and unix_timestamp() group by user_id)S5 
ON S5.user_id = user.id
left outer JOIN (select user_id,count(*) as upload_count from user_active_dump.user_upload_dump group by user_id) S6
ON S6.user_id = user.id;"

   # User Total Automation
hive -d --database user_active_dump
hive -e "use user_active_dump;insert into user_total
select a.ts,a.total,case when (a.total-b.difflastrun) is null then 0 else (a.total-b.difflastrun) end 
from (SELECT from_unixtime(unix_timestamp()) as ts,count(*) as total from user) a,
(select sum(total_users) as difflastrun from user_total 
where time_ran > from_unixtime(unix_timestamp()))b;"

                                                                                                                                                                                                         1,1           Top
