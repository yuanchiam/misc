select
    country_desc,
    sum(rcr7)*1.0/count(*) as rcr,
    avg(handle_time) as aht,
    sum(negative_survey_responses)*1.0/sum(survey_responses) as dsat,
    sum(volume)*1.0/3 as monthly_vol,
    sum(InApp_flag)*1.0/count(*) as inapp_adopt

from

(select 
  aa.country_desc,
  aa.rcr7,
  case when aa.contact_subchannel_id='InApp' then 1 else 0 end as InApp_flag,
  (coalesce(aa.answered_cnt,0)) volume,
  (coalesce(aa.dsat_survey_response_cnt,0)) survey_responses,
  (coalesce(aa.dsat_negative_survey_response_cnt,0)) negative_survey_responses,
  (((coalesce(aa.talk_duration_secs,0)+coalesce(aa.acw_duration_secs,0)+coalesce(aa.answer_hold_duration_secs,0))/60.0)) handle_time

from

(select 
 cf.*,
 cc.call_center_desc,
 geo.country_iso_code,
 geo.country_desc,
 case when rcr.contact_code is null then 0 else 1 end as rcr7,
 case when cf.account_id<0 then 'Non-Member' else 'Member' end as member_status 
 from dse.cs_contact_f cf
 join dse.cs_transfer_type_d trt on cf.transfer_type_id = trt.transfer_type_id
 join dse.cs_contact_skill_d r on r.contact_skill_id=cf.contact_skill_id
 join dse.cs_call_center_d cc on cc.call_center_id=cf.call_center_id 
 join dse.account_d acc on acc.account_id=cf.account_id
 join dse.geo_country_d geo on acc.country_iso_code=geo.country_iso_code
 left join (select contact_code from dse.cs_recontact_f
            where days_to_recontact_cnt<=7
            and has_recontact_cnt =1
            -- 90 days prior
            and fact_utc_date >= cast(date_format((current_date - interval '4' month ), '%Y%m%d') as bigint)
            group by contact_code) rcr on cf.contact_code = rcr.contact_code
 --where cf.fact_utc_date >= cast(date_format((current_date - interval '1' month ), '%Y%m%d') as bigint)
 where cf.fact_utc_date >= 20170301
 and cf.fact_utc_date <= 20170531
 and r.escalation_code not in ('G-Escalation', 'SC-Consult','SC-Escalation','Corp-Escalation')
 and trt.major_transfer_type_desc not in ('TRANSFER_OUT')
 and cf.answered_cnt>0
 and cf.contact_subchannel_id in ('Phone', 'Chat', 'voip','InApp', 'MBChat')
) aa

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
(
'Austria',
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
'Luxembourg'
)) bb

on aa.country_iso_code=bb.country_iso_code

) a1

group by country_desc
