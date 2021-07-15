class GetDuplicateCandidateMatches < ApplicationRecord
  def self.call
    ActiveRecord::Base.connection.exec_query(
      "SELECT a.candidate_id, a.first_name, a.last_name, a.postcode, a.date_of_birth, email_address
    FROM application_forms a
    JOIN(
      SELECT application_forms.last_name, application_forms.date_of_birth, application_forms.postcode
      FROM application_forms
      WHERE application_forms.previous_application_form_id IS NULL
      AND application_forms.submitted_at IS NOT NULL
      GROUP BY application_forms.last_name, application_forms.date_of_birth, application_forms.postcode
      HAVING (count(*) > 1)
    ) b
    ON a.postcode = b.postcode
    AND a.date_of_birth = b.date_of_birth
    AND a.last_name = b.last_name
    JOIN(
      SELECT candidates.id, candidates.email_address
      FROM candidates
    ) c
    ON a.candidate_id = c.id
    ORDER BY a.date_of_birth",
    ).to_a
  end
end
