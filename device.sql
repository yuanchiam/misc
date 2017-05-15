select
        a11.*,
        --a11.fact_date,
	--a11.device_type_id,
	--a11.device_model,
	max(case when a14.device_model = '--' then a14.device_type_desc else a14.device_type_desc || ' (' || a14.device_model || ')' end)  device_model0,
	a12.sdk_version,
	a14.device_category_id,
        a14.brand,
	a14.manufacturer,
	--a14.device_type_id,
	max(case when a14.device_type_id=419 or a14.device_type_id=964 then a14.device_type_desc else a14.device_type_name end)  device_type_desc,
	a14.device_model_override,
	a15.device_major_category_id,
        a15.device_category,
        a19.call_center_desc
from
        dse.cs_device_contact_agg a11
join	dse.device_client_rollup_d a12 
        on (a11.device_client_ver = a12.client_version and 
	    a11.device_type_id = a12.device_type_id)
join	dse.device_model_rollup_d a14
	    on (a11.device_model = a14.device_model and 
	    a11.device_type_id = a14.device_type_id)
join	dse.device_category_d a15
	    on (a14.device_category_id = a15.device_category_id)
join	dse.cs_call_center_d a19
	    on (a11.call_center_id = a19.call_center_id)
where a11.fact_date > 20170101
        and answered_cnt>0
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27,29,30,31,32

---
---
---

select	a11.call_center_id  call_center_id,
	max(a19.call_center_desc)  call_center_desc,
	a11.contact_channel_id  contact_channel_id,
	a14.brand  brand,
	a11.device_type_id  device_type_id,
	a11.device_model  device_model,
	max(case when a14.device_model = '--' then a14.device_type_desc else a14.device_type_desc || ' (' || a14.device_model || ')' end)  device_model0,
	a11.ticket_gate_level0_desc  ticket_gate_level0_desc,
	a11.ticket_gate_level1_desc  ticket_gate_level1_desc,
	a11.ticket_gate_level2_desc  ticket_gate_level2_desc,
	a11.contact_origin_country_code  country_iso_code,
	max(a13.country_desc)  country_name,
	a13.region_sk  region_sk,
	max(a13.region_desc)  region_name,
	a13.subregion_sk  subregion_sk,
	max(a13.subregion_desc)  subregion_name,
	a11.fact_date  calendar_date,
	a14.device_category_id  device_category_id,
	max(a15.device_category)  device_category,
	a15.device_major_category_id  major_device_category_id,
	max(a16.major_device_category)  major_device_category,
	a14.manufacturer  manufacturer,
	a14.device_type_id  device_model_override,
	a14.device_model_override  device_model_override0,
	max(case when a14.device_model = '--' then a14.device_type_desc else a14.device_type_desc || ' (' || a14.device_model || ')' end)  CustCol_544,
	a16.device_platform_id  device_platform_id,
	max(a111.device_platform_rollup_name)  device_platform_rollup_name,
	a11.device_type_id  device_type_id0,
	max(case when a14.device_type_id=419 or a14.device_type_id=964 then a14.device_type_desc else a14.device_type_name end)  device_type_desc,
	max(a14.device_type_extended_name)  device_type_extended_name,
	a17.mnth_nbr  mnth_nbr,
	max(a110.mnth_name)  mnth_name0,
	a17.sun_to_sat_wk_end_date  sun_to_sat_wk_end_date,
	CEIL((DATEDIFF(DAY, a18.sun_to_sat_wk_start_date, CURRENT_DATE) / 7))  weekage0,
	a12.sdk_version  sdk_version,
	sum(a11.ticket_cnt)  WJXBFS1,
	sum(a11.has_7d_device_recontact)  WJXBFS2,
	sum(a11.member_ticket_with_cust_msg_cnt)  WJXBFS3,
	sum(a11.survey_cnt)  WJXBFS4,
	sum(a11.dsat_negative_survey_response_cnt)  WJXBFS5,
	sum(a11.dsat_survey_response_cnt)  WJXBFS6
from	dse.cs_device_contact_agg	a11
	join	dse.device_client_rollup_d	a12
	  on 	(a11.device_client_ver = a12.client_version and 
	a11.device_type_id = a12.device_type_id)
	join	dse.geo_country_d	a13
	  on 	(a11.contact_origin_country_code = a13.country_iso_code)
	join	dse.device_model_rollup_d	a14
	  on 	(a11.device_model = a14.device_model and 
	a11.device_type_id = a14.device_type_id)
	join	dse.device_category_d	a15
	  on 	(a14.device_category_id = a15.device_category_id)
	join	dse.device_major_category_d	a16
	  on 	(a15.device_major_category_id = a16.major_device_category_id)
	join	dse.dt_date_d	a17
	  on 	(a11.fact_date = a17.calendar_date)
	join	dse.dt_sun_to_sat_week_d	a18
	  on 	(a17.sun_to_sat_wk_end_date = a18.sun_to_sat_wk_end_date)
	join	dse.cs_call_center_d	a19
	  on 	(a11.call_center_id = a19.call_center_id)
	join	dse.dt_month_d	a110
	  on 	(a17.mnth_nbr = a110.mnth_nbr)
	join	dse.device_platform_rollup_d	a111
	  on 	(a16.device_platform_id = a111.device_platform_rollup_id)
where	a11.fact_date between '11/12/2016' and (Select reporting_date from dse.cs_reporting_date_d)
group by	a11.call_center_id,
	a11.contact_channel_id,
	a14.brand,
	a11.device_type_id,
	a11.device_model,
	a11.ticket_gate_level0_desc,
	a11.ticket_gate_level1_desc,
	a11.ticket_gate_level2_desc,
	a11.contact_origin_country_code,
	a13.region_sk,
	a13.subregion_sk,
	a11.fact_date,
	a14.device_category_id,
	a15.device_major_category_id,
	a14.manufacturer,
	a14.device_type_id,
	a14.device_model_override,
	a16.device_platform_id,
	a11.device_type_id,
	a17.mnth_nbr,
	a17.sun_to_sat_wk_end_date,
	CEIL((DATEDIFF(DAY, a18.sun_to_sat_wk_start_date, CURRENT_DATE) / 7)),
	a12.sdk_version
  
