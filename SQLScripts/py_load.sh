 #! /bin/sh -
cd /home/cloudera
cd python
python  practical_exercise_data_generator.py  --create_csv
python  practical_exercise_data_generator.py  --load_data
cd
#upload_dump is the directory which receives csv dumps after running the python scripts --create_csv
cd upload_dump
mv  *.csv  ram.csv
cd /home/cloudera
hadoop fs -put /home/cloudera/upload_dump/ram.csv  /user/cloudera/upload_dump_temp
