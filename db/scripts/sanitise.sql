CREATE OR REPLACE FUNCTION generate_lorem_ipsum(mode TEXT DEFAULT NULL)
    RETURNS TEXT AS $$
DECLARE
    lorem TEXT[] := ARRAY[
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
        'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
        ];
    result TEXT;
BEGIN
    IF mode = 'long' THEN
        -- Concatenate all statements and repeat 5 times
        result := repeat(array_to_string(lorem, ' '), 5);
    ELSIF mode = 'short' THEN
        -- Pick a random statement
        result := lorem[floor(random() * array_length(lorem, 1) + 1)];
    END IF;
    RETURN result;
END;
$$ LANGUAGE plpgsql;


DELETE FROM "audits";
DELETE FROM "blazer_audits";
DELETE FROM "blazer_checks";
DELETE FROM "blazer_dashboard_queries";
DELETE FROM "blazer_dashboards";
DELETE FROM "blazer_queries";
DELETE FROM "email_clicks";
DELETE FROM "emails";
DELETE FROM "find_feedback";
DELETE FROM "vendor_api_requests";

-- ApplicationForm
UPDATE "application_forms"
SET
    first_name = CASE
        WHEN first_name IS NULL THEN NULL
        ELSE 'Candidate'
        END,

    last_name = CASE
        WHEN last_name IS NULL THEN NULL
        ELSE concat('User', id)
        END,

    phone_number = CASE
        WHEN phone_number IS NULL THEN NULL
        ELSE '07' || LPAD(FLOOR(RANDOM() * 100000000)::TEXT, 8, '0')
        END,

    address_line1 = CASE
        WHEN address_line1 IS NULL THEN NULL
        ELSE 'Address Line 1'
        END,

    address_line2 = CASE
        WHEN address_line2 IS NULL THEN NULL
        ELSE 'Address Line 2'
        END,

    address_line3 = CASE
        WHEN address_line3 IS NULL THEN NULL
        ELSE 'Address Line 3'
        END,

    address_line4 = CASE
        WHEN address_line4 IS NULL THEN NULL
        ELSE 'Address Line 4'
        END,

    postcode = CASE
        WHEN postcode IS NULL THEN NULL
        ELSE 'SW1P 3BT'
        END,

    disability_disclosure = CASE
        WHEN  disability_disclosure IS NULL THEN NULL
        ELSE  generate_lorem_ipsum('short')
        END,

    becoming_a_teacher = CASE
        WHEN becoming_a_teacher IS NULL THEN NULL
        ELSE generate_lorem_ipsum('long')
        END,

    safeguarding_issues = CASE
        WHEN safeguarding_issues IS NULL THEN NULL
        ELSE generate_lorem_ipsum('short')
        END,

    international_address = CASE
        WHEN international_address IS NULL THEN NULL
        ELSE '20 W 34th St., New York, NY 10001, USA'
        END,

    right_to_work_or_study_details = CASE
        WHEN right_to_work_or_study IS NULL THEN NULL
        ELSE generate_lorem_ipsum('short')
        END;

-- ApplicationChoice
UPDATE "application_choices"
SET personal_statement = CASE
    WHEN  personal_statement IS NULL THEN NULL
    ELSE generate_lorem_ipsum('long')
    END;

-- Candidate
UPDATE "candidates"
SET
    email_address = concat('candidate_user_', id, '@example.com');

-- FraudMatch
UPDATE "fraud_matches"
SET
    last_name = CASE
        WHEN last_name IS NULL THEN NULL
        ELSE concat('Fraudster', id)
        END,
    postcode = CASE
        WHEN postcode IS NULL THEN NULL
        ELSE 'SW1P 3BT'
        END;

-- ProviderUser
UPDATE "provider_users"
SET
    email_address = concat('provider_user_', id, '@example.com'),
    first_name = 'Provider',
    last_name = concat('User', id),
    dfe_sign_in_uid = gen_random_uuid();

-- Reference
UPDATE "references"
SET
    email_address = concat('application_reference_', id, '@example.com'),
    feedback = CASE
        WHEN feedback IS NULL THEN NULL
        ELSE generate_lorem_ipsum('short')
        END,
    name = concat('Application Reference_', id);

-- SupportUser
UPDATE "support_users"
SET
    email_address = concat('application_reference_', id, '@example.com'),
    first_name  = 'Support',
    last_name = concat('User', id),
    dfe_sign_in_uid = gen_random_uuid();

-- VendorApiUser
UPDATE "vendor_api_users"
SET
    full_name = concat('Api User', id),
    email_address = concat('application_reference_', id, '@example.com');
