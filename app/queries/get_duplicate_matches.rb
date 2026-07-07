class GetDuplicateMatches
  def self.call
    ActiveRecord::Base.connection.exec_query(
      "SELECT DISTINCT ON (application_details.candidate_id) application_details.candidate_id,
        application_details.first_name,
        application_details.last_name last_name,
        COALESCE(TRIM(UPPER(application_details.postcode)), '') postcode,
        application_details.date_of_birth,
        email_address,
        submitted_at
      FROM application_forms application_details
      JOIN(
        SELECT TRIM(UPPER(unaccent(application_forms.last_name))) last_name, application_forms.date_of_birth, COALESCE(REPLACE(UPPER(application_forms.postcode), ' ', ''), '') postcode
        FROM application_forms
        GROUP BY TRIM(UPPER(unaccent(application_forms.last_name))), application_forms.date_of_birth, COALESCE(REPLACE(UPPER(application_forms.postcode), ' ', ''), '')
        HAVING (COUNT(DISTINCT application_forms.candidate_id) > 1)
      ) duplicate_attributes
      ON COALESCE(REPLACE(UPPER(application_details.postcode), ' ', ''), '') = duplicate_attributes.postcode
      AND application_details.date_of_birth = duplicate_attributes.date_of_birth
      AND TRIM(UPPER(unaccent(application_details.last_name))) = duplicate_attributes.last_name
      JOIN(
        SELECT TRIM(UPPER(application_forms.last_name)) last_name, application_forms.date_of_birth, COALESCE(REPLACE(UPPER(application_forms.postcode), ' ', ''), '') postcode
        FROM application_forms
      ) duplicate_submitted_attributes
      ON COALESCE(REPLACE(UPPER(application_details.postcode), ' ', ''), '') = duplicate_submitted_attributes.postcode
      AND application_details.date_of_birth = duplicate_submitted_attributes.date_of_birth
      AND TRIM(UPPER(application_details.last_name)) = duplicate_submitted_attributes.last_name
      JOIN(
        SELECT candidates.id, candidates.email_address
        FROM candidates
      ) candidate_details
      ON application_details.candidate_id = candidate_details.id
      ORDER BY application_details.candidate_id, last_name, application_details.date_of_birth, postcode, application_details.submitted_at DESC;",
    ).to_a
  end
end
