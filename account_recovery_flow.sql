-- 1) # of unique users landing on website for account recovery
-- 2) # of unique users who performed login action
-- 3) # of unique users who successfully logged-in as current member

-- 1. input.flow:partnerMop AND input.mode: validateToken AND output.mode: registerOrSignIn AND partner.is_account_recovery:true AND NOT input.visitor_state: CURRENT_MEMBER AND input.method: SUBMIT

use ychiam;
CREATE TABLE ychiam.account_recovery_flow1 as
select 
distinct(other_properties['input.account_owner_id']) as account_id,
other_properties['partner.name'] as partner_name,
'Landing Page' as flow,
dateint

from default.dynecom_execution_events

where other_properties['input.method']='SUBMIT'
and other_properties['input.flow']='partnerMop'
and other_properties['input.mode']='validateToken'
and other_properties['output.mode']='registerOrSignIn'
and other_properties['partner.is_account_recovery']='true'
and other_properties['input.visitor_state'] not in ('CURRENT_MEMBER')
and dateint>=20170101;

-- 2. input.flow:partnerMop AND input.mode: registerOrSignIn  AND partner.is_account_recovery:true AND NOT input.visitor_state: CURRENT_MEMBER AND input.method:SUBMIT AND input.action:loginAction

use ychiam;
CREATE TABLE ychiam.account_recovery_flow2 as
select 
distinct(other_properties['input.account_owner_id']),
other_properties['partner.name'],
'Login Action' as flow,
dateint

from default.dynecom_execution_events

where other_properties['input.flow']='partnerMop'
and other_properties['input.mode']='registerOrSignIn'
and other_properties['partner.is_account_recovery']='true'
and other_properties['input.visitor_state'] not in ('CURRENT_MEMBER')
and other_properties['input.method']='SUBMIT'
and other_properties['input.action']='loginAction'
and dateint>=20170101;

-- 3. input.flow:partnerMop AND input.mode: registerOrSignIn  AND partner.is_account_recovery:true AND NOT input.visitor_state: CURRENT_MEMBER AND input.method:SUBMIT AND output.visitor_state:CURRENT_MEMBER
use ychiam;
CREATE TABLE ychiam.account_recovery_flow3 as
select 
distinct(other_properties['input.account_owner_id']),
other_properties['partner.name'],
'Success' as flow,
dateint

from default.dynecom_execution_events

where other_properties['input.flow']='partnerMop'
and other_properties['input.mode']='registerOrSignIn'
and other_properties['partner.is_account_recovery']='true'
and other_properties['input.visitor_state'] not in ('CURRENT_MEMBER')
and other_properties['input.method']='SUBMIT'
and other_properties['output.visitor_state']='CURRENT_MEMBER'
and dateint>=20170101;
