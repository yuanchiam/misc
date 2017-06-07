select 
test_assignments.cs_test_id,
test_assignments.cs_test_cell_id,
test_assignments.tenure_weeks,
test_assignments.current_supervisor_chewbacca_user_id,
contact_details.*
from
-- start test_assignments
(
select
a.*,
round(date_diff('day', date_parse(cast(b.netflix_hire_date as varchar), '%Y%m%d'),  date_parse(cast(a.allocation_date as varchar), '%Y%m%d'))/7) as tenure_weeks,
b.current_supervisor_chewbacca_user_id,
b.netflix_hire_date
from
(select
*
from dse.cs_agent_abtest_allocation_d
where cs_test_id='SLC00004') a
left join
(select
chewbacca_user_id,
current_supervisor_chewbacca_user_id,
netflix_hire_date
from dse.cs_agent_d) b
on a.chewbacca_user_id = b.chewbacca_user_id
) test_assignments

join

-- start contact_details
(
select 
 cf.chewbacca_user_id,
 cf.answered_cnt,
 cf.contact_subchannel_id,
 (((coalesce(cf.talk_duration_secs,0)+coalesce(cf.acw_duration_secs,0)+coalesce(cf.answer_hold_duration_secs,0))/60.0)) handle_time,
 (coalesce(cf.dsat_survey_response_cnt,0)) survey_responses,
 (coalesce(cf.dsat_negative_survey_response_cnt,0)) negative_survey_responses,
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
            and fact_utc_date >= 20170507
            group by contact_code) rcr on cf.contact_code = rcr.contact_code
 where cf.fact_utc_date >= cast(date_format((current_date - interval '3' month ), '%Y%m%d') as bigint)
 and r.escalation_code not in ('G-Escalation', 'SC-Consult','SC-Escalation','Corp-Escalation')
 and trt.major_transfer_type_desc not in ('TRANSFER_OUT')
 and cf.answered_cnt>0
 and cf.call_center_id in ('NCSL')
) contact_details

on test_assignments.chewbacca_user_id=contact_details.chewbacca_user_id