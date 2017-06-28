-- daily view, needs to average if weekly, monthly view
select aa.*,
bb.country_desc,
case when bb.country_desc in
(
'France',
'Austria',
'Bolivia',
'Honduras',
'Dominican Republic',
'Guatemala',
'United States'
) then 'Grp A' 
when bb.country_desc in
(
'Switzerland',
'Belgium',
'Ecuador',
'Panama',
'El Salvador',
'Nicaragua'
) then 'Grp B' 
when bb.country_desc in
(
'Mexico', 
'Uruguay',
'Netherlands',
'Germany'
) then 'Grp A Blockbuster' 
when bb.country_desc in
(
'Argentina', 
'Chile', 
'Columbia', 
'Peru',
'Norway',
'Sweden',
'Denmark',
'Finland'
) then 'Grp B Blockbuster' 
else 'Leftovers' end as country_group,
bb.subregion_desc
from
(select b.*,
a.contact_cnt
from
(select
contact_origin_country_code,
count(*) as contact_cnt,
fact_utc_date
from
dse.cs_contact_f
where fact_utc_date>=20170101
and answered_cnt>=0
group by fact_utc_date, contact_origin_country_code) a
join
(select
country_iso_code,
count(account_id) as membership,
snapshot_date
from dse.account_day_d
where has_service>0
and snapshot_date>=20170101
group by snapshot_date, country_iso_code
having count(account_id)>1000) b
on a.fact_utc_date=b.snapshot_date and a.contact_origin_country_code=b.country_iso_code) aa
join
(select
a1.country_iso_code,
a1.country_desc,
b1.subregion_desc
from
dse.geo_country_d a1
join dse.geo_subregion_d b1
on a1.subregion_sk=b1.subregion_sk
where a1.country_desc in 
('Austria',
'Belgium',
'Chile',
'Colombia',
'Dominican Republic',
'El Salvador',
'Finland',
'France',
'Germany',
'Guatemala',
'Honduras',
'Ireland',
'Italy',
'Japan',
'Mexico',
'Netherlands',
'New Zealand',
'Nicaragua',
'Norway',
'Panama',
'Peru',
'Portugal',
'Spain',
'Sweden',
'Switzerland',
'Uruguay',
'Venezuela',
'Denmark',
'United Kingdom',
'Luxembourg',
'Argentina',
'Costa Rica',
'Ecuador',
'Bolivia',
'Honduras',
'United States'
)) bb
on aa.country_iso_code=bb.country_iso_code
