-- Tables

select * from [dbo].[sample_customers];
select * from [dbo].[sample_defaults];
select * from [dbo].[sample_institutions];
select * from [dbo].[sample_loans];
select * from [dbo].[sample_payments];

-- =====================================================
-- VERSION 2 ENHANCED: Live Session Advanced Analytics
-- =====================================================

-- CHALLENGE: Real-time Collection Optimization Engine
-- Business Context: Live war room session - collection efficiency at 47%
-- Corporate Reality: Must process 800K+ payment records with sub-second response

-- Advanced Contact Strategy Optimization
WITH contact_sequence_analysis AS (
    SELECT 
        ca.loan_id,
        ca.contact_date,
        ca.contact_method,
        ca.contact_result,
        ca.promised_amount,
        ca.actual_payment_amount,
        
        -- Advanced sequence analysis
        ROW_NUMBER() OVER (PARTITION BY ca.loan_id ORDER BY ca.contact_date) as contact_sequence,
        LAG(ca.contact_method, 1) OVER (PARTITION BY ca.loan_id ORDER BY ca.contact_date) as prev_method_1,
        LAG(ca.contact_method, 2) OVER (PARTITION BY ca.loan_id ORDER BY ca.contact_date) as prev_method_2,
        
        -- Time-based patterns
        DATEPART(HOUR, ca.contact_date) as contact_hour,
        DATEPART(WEEKDAY, ca.contact_date) as contact_weekday,
        
        -- Customer context during contact
        c.annual_income,
        c.employment_type,
        c.current_city,
        
        -- Loan context
        l.emi_amount,
        l.loan_amount,
        DATEDIFF(DAY, l.disbursement_date, ca.contact_date) as days_since_disbursement,
        
        -- Default context
        d.dpd_days,
        d.default_amount,
        
        -- Success metrics
        CASE WHEN ca.actual_payment_amount > 0 THEN 1 ELSE 0 END as payment_success,
        CASE WHEN ca.promised_amount > 0 THEN 1 ELSE 0 END as promise_made,
        
        -- Next contact prediction features
        LEAD(ca.actual_payment_amount) OVER (PARTITION BY ca.loan_id ORDER BY ca.contact_date) as next_payment_amount,
        DATEDIFF(DAY, ca.contact_date, 
                 LEAD(ca.contact_date) OVER (PARTITION BY ca.loan_id ORDER BY ca.contact_date)) as days_to_next_contact
        
    FROM collection_activities ca
    INNER JOIN sample_loans l ON ca.loan_id = l.loan_id
    INNER JOIN sample_customers c ON l.customer_id = c.customer_id
    INNER JOIN sample_defaults d ON l.loan_id = d.loan_id
    WHERE ca.contact_date >= DATEADD(month, -6, GETDATE())
),
method_effectiveness_matrix AS (
    SELECT 
        contact_method,
        prev_method_1,
        prev_method_2,
        contact_hour,
        contact_weekday,
        employment_type,
        
        -- Effectiveness metrics
        COUNT(*) as total_attempts,
        SUM(payment_success) as successful_payments,
        SUM(promise_made) as promises_made,
        AVG(actual_payment_amount) as avg_payment_amount,
        
        -- Conversion rates
        ROUND(SUM(payment_success) * 100.0 / COUNT(*), 2) as payment_conversion_rate,
        ROUND(SUM(promise_made) * 100.0 / COUNT(*), 2) as promise_conversion_rate,
        
        -- Advanced metrics
        AVG(CASE WHEN payment_success = 1 THEN days_to_next_contact END) as avg_resolution_days,
        STDEV(actual_payment_amount) as payment_amount_variance,
        
        -- ROI calculation
        SUM(actual_payment_amount) / NULLIF(COUNT(*) * 150, 0) as roi_per_contact  -- Assuming ₹150 per contact cost
        
    FROM contact_sequence_analysis
    GROUP BY contact_method, prev_method_1, prev_method_2, contact_hour, contact_weekday, employment_type
    -- HAVING COUNT(*) >= 50
    HAVING COUNT(*) >= 1  -- Statistical significance
),
optimal_strategy_recommendations AS (
    SELECT 
        employment_type,
        contact_hour,
        
        -- Best performing method for each context
        FIRST_VALUE(contact_method) OVER (
            PARTITION BY employment_type, contact_hour 
            ORDER BY payment_conversion_rate DESC, roi_per_contact DESC
        ) as optimal_primary_method,
        
        FIRST_VALUE(payment_conversion_rate) OVER (
            PARTITION BY employment_type, contact_hour 
            ORDER BY payment_conversion_rate DESC, roi_per_contact DESC
        ) as optimal_conversion_rate,
        
        -- Sequence recommendations
        CASE 
            WHEN prev_method_1 = 'Phone Call' AND payment_conversion_rate > 15 THEN contact_method
            WHEN prev_method_1 = 'Email' AND payment_conversion_rate > 10 THEN contact_method
            ELSE NULL
        END as recommended_follow_up_method
        
    FROM method_effectiveness_matrix
    WHERE payment_conversion_rate >= 5  -- Minimum viable conversion
)
SELECT 
    employment_type,
    contact_hour,
    optimal_primary_method,
    optimal_conversion_rate,
    
    -- Strategic recommendations
    CASE 
        WHEN optimal_conversion_rate >= 20 THEN 'SCALE UP: High performance channel'
        WHEN optimal_conversion_rate >= 15 THEN 'OPTIMIZE: Fine-tune approach'
        WHEN optimal_conversion_rate >= 10 THEN 'MAINTAIN: Standard performance'
        ELSE 'REVIEW: Consider alternative strategies'
    END as strategic_action,
    
    -- Operational recommendations
    CONCAT(
        'Contact ', employment_type, ' customers at ', contact_hour, ':00 using ', 
        optimal_primary_method, ' for ', optimal_conversion_rate, '% success rate'
    ) as operational_guideline
    
FROM optimal_strategy_recommendations
WHERE optimal_conversion_rate IS NOT NULL
ORDER BY employment_type, contact_hour;