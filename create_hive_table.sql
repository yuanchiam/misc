show create table etl.cs_ab_test_manual_entry

use etl; 
create table etl.cs_message_id_entry
(message_id int, date_added varchar(100))
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY '\u0001' 
  COLLECTION ITEMS TERMINATED BY '\u0004' 
  MAP KEYS TERMINATED BY '\u0002' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat';
