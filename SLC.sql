select distinct tickets.fact_utc_date fact_utc_date,
        tickets.ticket_code l2_verified_tcks,
        max(case when tickets.action_category_code = 'GET_CUSTOMER_BY_EMAIL' then 1 end) GET_CUSTOMER_BY_EMAIL,        
        max(case when tickets.action_category_code in ('GET_CUSTOMER_BY_ACCOUNT_NUMBER',
                                            'GET_CUSTOMER_BY_EUDD',
                                            'GET_CUSTOMER_BY_GIFT',
                                            'GET_CUSTOMER_BY_MOP',
                                            'GET_CUSTOMER_BY_SOCIAL_ID') then 1 end) GET_ALL_OTHER_METHODS,
        max(case when tickets.action_category_code = 'GET_CUSTOMER_BY_ACCOUNT_NUMBER' then 1 end) GET_CUSTOMER_BY_ACCOUNT_NUMBER,
        max(case when tickets.action_category_code = 'GET_CUSTOMER_BY_EUDD' then 1 end) GET_CUSTOMER_BY_EUDD,
        max(case when tickets.action_category_code = 'GET_CUSTOMER_BY_GIFT' then 1 end) GET_CUSTOMER_BY_GIFT,
        max(case when tickets.action_category_code = 'GET_CUSTOMER_BY_ID' then 1 end) GET_CUSTOMER_BY_ID,
        max(case when tickets.action_category_code = 'GET_CUSTOMER_BY_MOP' then 1 end) GET_CUSTOMER_BY_MOP,
        max(case when tickets.action_category_code = 'GET_CUSTOMER_BY_PHONE_NUMBER' then 1 end) GET_CUSTOMER_BY_PHONE_NUMBER,
        max(case when tickets.action_category_code = 'GET_CUSTOMER_BY_SOCIAL_ID' then 1 end) GET_CUSTOMER_BY_SOCIAL_ID,
        max(case when tickets.action_category_code = 'VERIFY_MOP' then 1 end) VERIFY_MOP,
        max(case when tickets.action_category_code = 'VERIFY_CUSTOMER_BY_PHONE' then 1 end) VERIFY_CUSTOMER_BY_PHONE,
        max(case when tickets.action_category_code = 'UPDATE_EMAIL_AND_NAME' then 1 end) UPDATE_EMAIL_AND_NAME
    from dse.cs_ticket_action_f tickets 
    where tickets.fact_date >= 20170529
        and tickets.action_category_code in ('GET_CUSTOMER_BY_ACCOUNT_NUMBER',
                                            'GET_CUSTOMER_BY_EMAIL',
                                            'GET_CUSTOMER_BY_EUDD',
                                            'GET_CUSTOMER_BY_GIFT',
                                            'GET_CUSTOMER_BY_ID',
                                            'GET_CUSTOMER_BY_MOP',
                                            'GET_CUSTOMER_BY_PHONE_NUMBER',
                                            'GET_CUSTOMER_BY_SOCIAL_ID',
                                            'VERIFY_MOP',
                                            'VERIFY_CUSTOMER_BY_PHONE',
                                            'UPDATE_EMAIL_AND_NAME')
    group by 1, 2
    
    
    
    
contact.first_ticket_id = ticket_action.ticket_code
