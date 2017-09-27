set session hive.aws_iam_role='arn:aws:iam::219382154434:role/s3_all_with_vault';
select count(distinct nrm_id), utc_date
from vault.clevent_f 
where navigation_level in ('nmLanding','signupSimplicity-planSelection','signupSimplicity-planSelectionWithContext','login') 
and source in ('www', 'www-hosted')
and visitor_state not in ('CURRENT_MEMBER')
and utc_date>=20170801
and utc_date<=20170810
--and (webpage_url='https://www.netflix.com/'
--or webpage_url='https://www.netflix.com/login'
--or webpage_url like 'https://www.netflix.com/signup%')
group by utc_date;
