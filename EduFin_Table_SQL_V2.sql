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