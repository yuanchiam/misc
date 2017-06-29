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

--

use ychiam;
CREATE TABLE ychiam.cs_message_alloc (
    message_guid string,
    account_id bigint,
    message_id bigint,
    send_epoch bigint,
    country_iso_code string,
    status_desc string,
    fail_reason_short_desc string,
    message_name string,
    channel string
)
PARTITIONED BY (send_utc_dateint bigint)
STORED AS TEXTFILE;
