#create directory to create password file
cd /home/cloudera/
echo -n "cloudera"> password
hadoop fs -mkdir /user/cloudera/sqoop_passwordfile
hadoop fs -put  /home/cloudera/password  /user/cloudera/sqoop_passwordfile

#create database in Hive
hive -e "create database user_active_dump"
#create hive table user_upload_dump
hive -e "'CREATE TABLE IF NOT EXISTS user_upload_dump(
    user_id int, 
    filename STRING, ts int)
    ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
TBLPROPERTIES ("skip.header.line.count"="1"); "

#creating user_report table
hive -e "CREATE TABLE IF NOT EXISTS user_active_dump.user_report (user_id int,total_inserts int,total_updates int,
total_deletes int,last_activity_type STRING,is_active BOOLEAN,upload_count int);"

#creating user_tota table
hive -e "CREATE TABLE IF NOT EXISTS user_active_dump.user_total (time_ran timestamp,total_users int,users_added int);"

#create a sqoop delta job to do ingetion of activelog table --hive-table user_active_dump.activitylog
sqoop job --create activity_log  -- import --connect jdbc:mysql://localhost/user_active_log --username root  --password-file   /user/cloudera/sqoop_passwordfile/password  --table activitylog --check-column id  --incremental append --last-value 0 --hive-import  --hive-table user_active_dump.activitylog  --driver com.mysql.jdbc.Driver
