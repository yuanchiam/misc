select contact_full.*,
aht_details.aht_prior4w

from

(
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
 and fact_utc_date >= 20170507
) contact_details

on test_assignments.chewbacca_user_id=contact_details.chewbacca_user_id
) contact_full

join

(
select 
 cf.chewbacca_user_id,
 avg((((coalesce(cf.talk_duration_secs,0)+coalesce(cf.acw_duration_secs,0)+coalesce(cf.answer_hold_duration_secs,0))/60.0))) aht_prior4w
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
 and cf.fact_utc_date>=20170401
 and cf.fact_utc_date<=20170430
 group by cf.chewbacca_user_id
) aht_details

on contact_full.chewbacca_user_id=aht_details.chewbacca_user_id

---------------
---- FINAL ----
---------------

select	
    abcell.cs_test_id cs_test_id,
	alloc.cs_test_cell_id  cs_test_cell_id,
	contact.fact_date calendar_date,
	contact.ticket_gate_level2_desc  ticket_gate_level2_desc,
	contact.ticket_gate_level1_desc  ticket_gate_level1_desc,
	contact.ticket_gate_level0_desc  ticket_gate_level0_desc,
	contact.chewbacca_user_id  chewbacca_user_id,
	agent.current_supervisor_chewbacca_user_id,
	contact.contact_subchannel_id,
	subchannel.contact_channel_id,
	contact.member_type_desc,
	contact.customer_lookup_type,
	alloc.allocation_date,
	alloc.deallocation_date,
	contact.answered_cnt,
	(((coalesce(contact.talk_duration_secs,0)+coalesce(contact.acw_duration_secs,0)+coalesce(contact.answer_hold_duration_secs,0))/60.0)) handle_time,
	contact.survey_cnt,
	contact.dsat_negative_survey_response_cnt,
	contact.dsat_survey_response_cnt,
	contact.negative_survey_response_cnt,
	contact.survey_response_cnt,
	case when recontact.days_to_recontact_cnt < 8 then recontact.has_recontact_cnt else 0 end as rcr7,
	round(ahist.tenure_day_cnt/7.0) as tenure_weeks
from dse.cs_contact_f contact join dse.cs_agent_abtest_allocation_d alloc on (contact.chewbacca_user_id = alloc.chewbacca_user_id)
        left join dse.cs_recontact_f recontact on contact.contact_code = recontact.contact_code and contact.fact_date = recontact.fact_date
        join dse.cs_transfer_type_d	transfer on contact.transfer_type_id = transfer.transfer_type_id
        join dse.cs_contact_subchannel_d subchannel on contact.contact_subchannel_id = subchannel.contact_subchannel_id
        join dse.cs_agent_abtest_cell_d abcell on alloc.cs_test_cell_id =  abcell.cs_test_cell_id
        join dse.cs_agent_abtest_d	abtest on abcell.cs_test_id = abtest.cs_test_id
        join dse.cs_agent_d agent on agent.chewbacca_user_id = contact.chewbacca_user_id
        join dse.cs_agent_d mgr on agent.current_supervisor_chewbacca_user_id = mgr.chewbacca_user_id
        join dse.cs_agent_hist_d ahist on contact.chewbacca_user_id = ahist.chewbacca_user_id and contact.fact_date = ahist.calendar_date
        join dse.dt_date_d date_d on contact.fact_date = date_d.calendar_date
        
where alloc.cs_test_id in ('SLC00004')
 and contact.call_center_id in ('NCSL')
 and contact.fact_date between alloc.allocation_date and alloc.deallocation_date
 --and contact.fact_date>=20170507
 --and contact.fact_date<=20170430
 and subchannel.contact_channel_id in ('Phone', 'Chat')
 and contact.ticket_gate_level0_desc in ('Content','Getting Started')
 and transfer.major_transfer_type_desc not in ('TRANSFER_OUT')
 and contact.answered_cnt>0
