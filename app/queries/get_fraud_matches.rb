class GetFraudMatches
  def self.call
    ActiveRecord::Base.connection.exec_query(
      "SELECT DISTINCT application_details.candidate_id,
          application_details.first_name,
          application_details.last_name last_name,
          TRIM(UPPER(application_details.postcode)) postcode,
          application_details.date_of_birth,
          email_address,
          submitted_at
        FROM application_forms application_details
        JOIN(
          SELECT TRIM(UPPER(application_forms.last_name)) last_name, application_forms.date_of_birth, REPLACE(UPPER(application_forms.postcode), ' ', '') postcode
          FROM application_forms
          WHERE application_forms.previous_application_form_id IS NULL
          GROUP BY TRIM(UPPER(application_forms.last_name)), application_forms.date_of_birth, REPLACE(UPPER(application_forms.postcode), ' ', '')
          HAVING (count(*) > 1)
        ) duplicate_attributes
        ON REPLACE(UPPER(application_details.postcode), ' ', '') = duplicate_attributes.postcode
        AND application_details.date_of_birth = duplicate_attributes.date_of_birth
        AND TRIM(UPPER(application_details.last_name)) = duplicate_attributes.last_name
        JOIN(
          SELECT TRIM(UPPER(application_forms.last_name)) last_name, application_forms.date_of_birth, REPLACE(UPPER(application_forms.postcode), ' ', '') postcode
          FROM application_forms
          WHERE application_forms.previous_application_form_id IS NULL
          AND application_forms.submitted_at IS NOT NULL
        ) duplicate_submitted_attributes
        ON REPLACE(UPPER(application_details.postcode), ' ', '') = duplicate_submitted_attributes.postcode
        AND application_details.date_of_birth = duplicate_submitted_attributes.date_of_birth
        AND TRIM(UPPER(application_details.last_name)) = duplicate_submitted_attributes.last_name
        JOIN(
          SELECT candidates.id, candidates.email_address
          FROM candidates
        ) candidate_details
                     ON application_details.candidate_id = candidate_details.id
        WHERE application_details.previous_application_form_id IS NULL
        ORDER BY last_name, application_details.date_of_birth, postcode;",
    ).to_a
  end
end
