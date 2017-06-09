--create user_report table to load data
CREATE TABLE IF NOT EXISTS user_report (user_id int,total_inserts int,total_updates int,
total_deletes int,last_activity_type STRING,is_active BOOLEAN,upload_count int);
--insert query to insert data
insert OVERWRITE TABLE   user_report
SELECT user.id as user_id, 
CASE WHEN s1.totinserts > 0 then s1.totinserts else 0 END as total_inserts,
CASE WHEN s2.totupdates > 0 then s2.totupdates else 0 END as total_updates,
CASE WHEN s3.totdeletes > 0 then s3.totdeletes else 0 END as total_deletes,
CASE WHEN s4.type is not null then s4.type END as last_activity_type,
CASE WHEN s5.active > 0 then true  else false END as is_active,
CASE WHEN s6.upload_count > 0 then s6.upload_count else 0 END as upload_count
FROM user 
left outer JOIN
                (SELECT  user_id,count(*) as totinserts
                 FROM  activitylog where type = 'INSERT'
                 GROUP BY user_id) S1 
ON S1.user_id = user.id 
left outer JOIN
                (SELECT  user_id,count(*) as totupdates
                 FROM  activitylog where type = 'UPDATE'
                 GROUP BY user_id) S2 
ON S2.user_id = user.id
left outer JOIN
                (SELECT  user_id,count(*) as totdeletes
                 FROM  activitylog where  type = 'DELETE'
                 GROUP BY user_id) S3 
ON S3.user_id = user.id 
left outer JOIN (select t1.user_id as user_id ,type from activitylog t1
join (
  select user_id, max(timestamp) maxModified from activitylog
  group by user_id
) s
on t1.user_id  = s.user_id and t1.timestamp = s.maxModified) S4 
ON S4.user_id = user.id
left outer JOIN (SELECT user_id,count(*) as active  FROM  activitylog  WHERE timestamp between ( unix_timestamp() -2*24*60*60) and unix_timestamp() group by user_id)S5 
ON S5.user_id = user.id
left outer JOIN (select user_id,count(*) as upload_count from user_upload_dump group by user_id) S6
ON S6.user_id = user.id;
