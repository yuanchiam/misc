select 
other_properties['inapp_provider'] as inapp_provider,
--CALL DEVICE
case when (dh.is_in_app_contact='true' and ch.client_name is null and dh.token='G1702729789291246435779-1') or (ch.client_name='iOS') or (dh.platform='iOS') then 'iOS' 
  when (dh.is_in_app_contact='true' and ch.client_name is null and dh.token='G0702729789291246435780-1') or (ch.client_name='Android Mobile') or (dh.platform='Android') then 'Android Mobile' 
  when dh.is_in_app_contact='true' and ch.client_name is null and (dh.token not in ('G1702729789291246435779-1','G0702729789291246435780-1') or dh.token is null) then 'Unknown' 
  when (dh.is_in_app_contact='false' and ch.client_name is null) or (dh.is_in_app_contact is null) then 'Regular' else ch.client_name 
  end as client_names,
sum(c.answered_cnt) as answered_cnt,
sum(problematic) as problematic,
sum(good) as good
from   dse.cs_contact_f c 
join dse.cs_transfer_type_d trt 
      on c.transfer_type_id=trt.transfer_type_id 
join dse.cs_call_center_d dc 
      on dc.call_center_id=c.call_center_id 
join dse.geo_country_d geo 
     on geo.country_iso_code=c.contact_origin_country_code 
join dse.date_d dd 
     on dd.calendar_date=c.fact_utc_date 
join dse.cs_contact_skill_d r 
     on r.contact_skill_id=c.contact_skill_id 
left outer join (select distinct
call_data_json,
other_properties,
 call_id,
is_in_app_contact,
level3_ucid,
other_properties['device_client_ver'] as device_client,
cast((case when other_properties['device_type_id']='' then null else other_properties['device_type_id'] end) as bigint) as type_id,
other_properties['device_model'] as model,
other_properties['token'] as token,
other_properties['platform'] as platform ,
json_extract_scalar(call_data_json,'$.sdk') sdk,
json_extract_scalar(call_data_json,'$.codec') codec
from   etl.cs_stg_leia_call_f 
where dateint>=20170625) dh 
          on dh.call_id=c.bpo_contact_code 
left outer join ( select distinct contact_code 
from   dse.cs_recontact_f 
where fact_utc_date>=20170625 and has_recontact_cnt=1 and days_to_recontact_cnt<=1 )sq4 
on sq4.contact_code=c.contact_code 
left outer join (select distinct ticket_code,
          p_call_quality
from   etl.cs_stg_obiwan_ticket_f 
where dateint>=20170625 ) t 
          on t.ticket_code=c.first_ticket_id 
          
left outer join dse.device_client_rollup_d ch 
          on ch.client_version=dh.device_client and ch.device_type_id=dh.type_id 
          
left  join (select  app_session_id, call_id 
        from etl.cs_inapp_uievent_sum 
        where event_uuid is not null and event_uuid <> '' 
        and fact_utc_date>=20170625
        group by  app_session_id, call_id 
) sesh
          on sesh.call_id=c.gateway_contact_code
left outer join dse.device_model_rollup_d dcc on dcc.device_model=dh.model and dh.type_id=dcc.device_type_id
left join etl.cs_inapp_qos_model_output_f model on model.contact_code=c.contact_code
left join (select call_id,max(case when leg_type='AGENT' then rtp_audio_in_mos else 0 end) as agent_mos
,max(case when leg_type='CUSTOMER' then rtp_audio_in_mos else 0 end) as cust_mos
from  etl.cs_freeswitch_cdr_f where dateint >= 20170625
group by call_id
)  fs
    on fs.call_id = c.bpo_contact_code
join 
(
select * from 
vphan.sample_reviews_20170705 
where  (good=1 or problematic=1)
and client_names='Android Mobile'
union all
select *
from
vphan.sample_reviews_20170726
where  (good=1 or problematic=1)
union all
select *
from
vphan.sample_reviews_20170727
where  (good=1 or problematic=1)
)
svi on svi.leia_id=dh.call_id
where c.fact_utc_date>=20170625   
          and r.escalation_code not in ('G-Escalation', 'SC-Consult','SC-Escalation','Corp-Escalation') 
          and trt.major_transfer_type_desc not in ('TRANSFER_OUT') 
          and c.contact_subchannel_id in ('InApp') 
--calls from DE and FR are allowed to be reviewed due to laws
and geo.country_iso_code not in ('DE','FR')
group by 1,2
