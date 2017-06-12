#create directory to create password file
cd /home/cloudera/
echo -n "cloudera"> password
hadoop fs -mkdir /user/cloudera/sqoop_passwordfile
hadoop fs -put  /home/cloudera/password  /user/cloudera/sqoop_passwordfile

#create database in Hive
hive -e "create database user_active_dump"
#create hive table user_upload_dump
hive -e "CREATE TABLE IF NOT EXISTS user_active_dump.user_upload_dump(id int, filename STRING, ts int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' "


#create a sqoop delta job to do ingetion of activelog table --hive-table user_active_dump.activitylog

 
sqoop job --create activity_log  -- import --connect jdbc:mysql://localhost/user_active_log --username root  --password-file   /user/cloudera/sqoop_passwordfile/password  --table activitylog --check-column id  --incremental append --last-value 0 --hive-import  --hive-table user_active_dump.activitylog  --driver com.mysql.jdbc.Driver
