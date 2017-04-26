#create directory to create password file
cd /home/cloudera/
echo -n "cloudera"> sqoop_password
hadoop fs -mkdir /user/cloudera/sqoop_passwordfile
hadoop fs -put  /home/cloudera/sqoop_password  /user/cloudera/sqoop_passwordfile

#create database in Hive
hive -e "create database databse12"
#create 
hive -e "CREATE TABLE IF NOT EXISTS database12.user_upload_dump(id int, filename STRING, ts int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' "


#create a sqoop job to do ingetion
sqoop job --create activelog_load  -- import --connect jdbc:mysql://localhost/useractive12 --username root  --password-file   /user/cloudera/sqoop_passwordfile/sqoop_password  --table activitylog  --check-column id  --incremental append --last-value 0 --hive-import --hive-database database12 --driver com.mysql.jdbc.Driver
