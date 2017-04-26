#! /bin/sh -
cd /home/cloudera/
#create directoty dump to move files to load from upload_dump(directory client save files)
mkdir /home/cloudera/dump
#create directory to store mergedfiles
mkdir /home/cloudera/user_upload_dump
#move files from "client files" directory to dump directory
mv /home/cloudera/upload_dump/user_upload_dump.*  /home/cloudera/dump
#go to dump directory and do operation to merge if more than 0 files exists
cd /home/cloudera/dump
for file in $(find . -type f -name "user_upload_dump.*")
do
               sed '1'd $file > $file.tmp
               mv $file.tmp $file
               cat $file >> bigfile.csv
done
#mergedfile copy to uer_upload_dump
cp /home/cloudera/dump/bigfile.csv  /home/cloudera/user_upload_dump
cd /home/cloudera
#remove directory if exists
hadoop dfs -rmr hdfs://quickstart.cloudera:8020/user/cloudera/user_upload_dump
#copy file to HDFS
hadoop fs -put /home/cloudera/user_upload_dump
hadoop fs -cat  /user/cloudera/user_upload_dump14/bigfile.csv
hive -e "load data  inpath '/user/cloudera/user_upload_dump' into  table database12.user_upload_dump;"
#remove user_upload_dump and dump directories
rm -rf  /home/cloudera/user_upload_dump
rm -rf /home/cloudera/dump
hadoop dfs -rmr hdfs://quickstart.cloudera:8020/user/cloudera/user
sqoop  import --connect jdbc:mysql://localhost/useractive12  --username root --password-file  /user/cloudera/sqoop_passwordfile/sqoop_password  \
--table user --hive-import --hive-overwrite\
    --hive-table database12.user --driver com.mysql.jdbc.Driver
#execute sqoop job
sqoop job -exec activelog3