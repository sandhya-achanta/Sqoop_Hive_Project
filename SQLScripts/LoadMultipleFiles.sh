#!/bin/sh
cd /home/cloudera/user_upload_dump_dir
for file in $(find . -type f -name "user_upload_dump.*")
do
  echo "Processing $file file..."
  # take action on each file. 
  cd /home/cloudera/
  #create directory to be process
  mkdir /home/cloudera/user_upload_dump_WorkInProgress
  #create directory to stage processed file 
  mkdir /home/cloudera/user_upload_dump_loadedfiles
  cd /home/cloudera/user_upload_dump
  #move each file to uer_upload_dump_WorkInProgress
  mv  $file  /home/cloudera/user_upload_dump_WorkInProgress
  cd /home/cloudera
  #remove directory if exists
  hadoop dfs -rmr hdfs://quickstart.cloudera:8020/user/cloudera/user_upload_dump_WorkInProgress
  #copy file Directory to HDFS
  hadoop fs -put /home/cloudera/user_upload_dump_WorkInProgress
  hadoop fs -cat  /user/cloudera/user_upload_dump_WorkInProgress/$file
  hive -e "load data  inpath '/user/cloudera/user_upload_dump_WorkInProgress' into  table user_active_dump.user_upload_dump;"
  #move prcoessed files to  user_upload_dump_loadedfiles
  mv /home/cloudera/user_upload_dump_WorkInProgress/$file  /home/cloudera/user_upload_dump_loadedfile
  #remove file from user_upload_dump_WorkInProgress directory incase it failed to move. 
  rm -rf /home/cloudera/user_upload_dump_WorkInProgress
  #remove file from user_upload_dump firectory since it is processed
  rm -rf  /home/cloudera/user_upload_dump/$file 
done
hadoop dfs -rmr hdfs://quickstart.cloudera:8020/user/cloudera/user
sqoop  import --connect jdbc:mysql://localhost/useractive12  --username root --password-file  /user/cloudera/sqoop_passwordfile/sqoop_password  \
--table user --hive-import --hive-overwrite\
--hive-table user_active_dump.user --driver com.mysql.jdbc.Driver
#execute sqoop job
sqoop job -exec activelog_load
