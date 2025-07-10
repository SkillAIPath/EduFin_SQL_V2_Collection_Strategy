select * from [dbo].[sample_customers];
select * from [dbo].[sample_defaults];
select * from [dbo].[sample_institutions];
select * from [dbo].[sample_loans];
select * from [dbo].[sample_payments];

-- Create table collection_activities
CREATE TABLE collection_activities (
    contact_id INT IDENTITY(1,1) PRIMARY KEY,         -- Auto-increment in SQL Server
    loan_id INT NOT NULL,                             -- FK to loans
    contact_date DATETIME NOT NULL,                   -- Timestamp of contact
    contact_method VARCHAR(50),                       -- Call / WhatsApp / Email etc.
    contact_result VARCHAR(100),                      -- Paid / Promise Made / No Response
    promised_amount FLOAT,                            -- Customer's committed amount
    actual_payment_amount FLOAT,                      -- Actual payment received
    agent_id INT,                                     -- Agent who contacted
    contact_notes TEXT,                               -- Remarks by agent
    contact_channel_type VARCHAR(30),                 -- Human / Digital / Automated
    created_at DATETIME DEFAULT GETDATE(),            -- Created time
    updated_at DATETIME DEFAULT GETDATE()             -- Updated time (static unless updated manually)
);

-- Step 2: Insert data
INSERT INTO collection_activities (
    loan_id, contact_date, contact_method, contact_result,
    promised_amount, actual_payment_amount,
    agent_id, contact_notes, contact_channel_type
)
VALUES
(1, '2025-06-01 10:00:00', 'Phone Call', 'Promise Made', 5000.00, 0.00, 101, 'Customer said salary is delayed', 'Human'),
(1, '2025-06-03 11:15:00', 'Phone Call', 'Paid', 0.00, 5000.00, 101, 'Confirmed EMI received', 'Human'),

(2, '2025-06-01 09:30:00', 'WhatsApp', 'Seen', 0.00, 0.00, 102, 'Message seen but no response', 'Digital'),
(2, '2025-06-04 10:45:00', 'Phone Call', 'Promise Made', 7000.00, 0.00, 102, 'Requested 3 more days to pay', 'Human'),
(2, '2025-06-07 15:20:00', 'Phone Call', 'Paid', 0.00, 7000.00, 102, 'Payment successfully collected', 'Human'),

(3, '2025-06-03 14:00:00', 'Email', 'Email Opened', 0.00, 0.00, 103, 'Opened but no further action', 'Digital'),
(3, '2025-06-06 11:00:00', 'Phone Call', 'Promise Made', 6000.00, 0.00, 103, 'Expected to pay on 9th', 'Human'),

(4, '2025-06-02 17:30:00', 'Field Visit', 'Promise Made', 8000.00, 0.00, 104, 'Agreed to clear dues next week', 'Human'),
(4, '2025-06-09 13:00:00', 'Phone Call', 'Paid', 0.00, 8000.00, 104, 'Loan cleared', 'Human'),

(5, '2025-06-01 08:00:00', 'Phone Call', 'No Response', 0.00, 0.00, 105, 'Phone switched off', 'Human'),
(5, '2025-06-03 09:45:00', 'WhatsApp', 'Seen', 0.00, 0.00, 105, 'Seen, awaiting action', 'Digital'),

(6, '2025-06-02 10:15:00', 'Phone Call', 'Promise Made', 5500.00, 0.00, 106, 'Customer had network issues, asked to follow up later', 'Human'),
(6, '2025-06-04 10:50:00', 'Phone Call', 'Paid', 0.00, 5500.00, 106, 'Confirmed payment via UPI', 'Human'),

(7, '2025-06-05 13:00:00', 'Email', 'No Response', 0.00, 0.00, 107, 'Reminder email sent', 'Digital'),

(8, '2025-06-01 16:40:00', 'Phone Call', 'Promise Made', 4500.00, 0.00, 108, 'Partial payment committed', 'Human'),
(8, '2025-06-05 12:30:00', 'Phone Call', 'Paid', 0.00, 4500.00, 108, 'Partial payment received', 'Human'),

(9, '2025-06-03 14:45:00', 'WhatsApp', 'Seen', 0.00, 0.00, 109, 'Seen and acknowledged', 'Digital'),
(9, '2025-06-06 11:15:00', 'Phone Call', 'Promise Made', 7000.00, 0.00, 109, 'Will pay before 10th', 'Human'),

(10, '2025-06-02 09:00:00', 'Phone Call', 'No Response', 0.00, 0.00, 110, 'No pickup despite 3 attempts', 'Human'),
(10, '2025-06-04 15:00:00', 'Field Visit', 'Promise Made', 10000.00, 0.00, 110, 'Promised to pay in 2 days', 'Human');


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