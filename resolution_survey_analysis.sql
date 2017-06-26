select 
 cf.ticket_gate_level0_desc,
 cf.survey_question_id,
 cf.survey_response_cnt,
 cf.negative_survey_response_cnt,
 --cc.call_center_desc,
 --geo.country_iso_code,
 --geo.country_desc,
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
            and fact_utc_date >= 20170101
            group by contact_code) rcr on cf.contact_code = rcr.contact_code
 --where cf.fact_utc_date >= cast(date_format((current_date - interval '1' month ), '%Y%m%d') as bigint)
 where cf.fact_utc_date >= 20170201
 and r.escalation_code not in ('G-Escalation', 'SC-Consult','SC-Escalation','Corp-Escalation')
 and trt.major_transfer_type_desc not in ('TRANSFER_OUT')
 and cf.answered_cnt>0
 and cf.contact_subchannel_id in ('Phone', 'Chat', 'voip','InApp', 'MBChat')
 and cf.survey_question_id='survey_prompt_resolved'
