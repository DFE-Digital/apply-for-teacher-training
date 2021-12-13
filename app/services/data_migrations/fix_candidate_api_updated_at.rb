module DataMigrations
  class FixCandidateAPIUpdatedAt
    TIMESTAMP = 20211208172459
    MANUAL_RUN = false

    # Ensure that all the candidates have a `candidate_api_updated_at` that is
    # no earlier than the `created_at` of the most recent application form.
    def change
      candidates = Candidate
        .joins(
          'inner join (
            select candidates.id id,
              max(application_forms.created_at) max_form_created_at
            from candidates
            inner join application_forms on application_forms.candidate_id = candidates.id
            group by candidates.id
          ) candidates_with_latest_application_form on candidates_with_latest_application_form.id = candidates.id',
        )
        .joins(
          "left outer join (
            select application_forms.candidate_id candidate_id,
              min(audits.created_at) earliest_update
            from audits
            inner join application_forms on application_forms.id = audits.auditable_id
            WHERE audits.action = 'update'
            AND audits.auditable_type = 'ApplicationForm'
            AND audits.user_id IS NOT NULL
            group by application_forms.candidate_id
          ) forms_with_earliest_audit ON forms_with_earliest_audit.candidate_id = candidates.id",
        )
        .select('candidates.*, candidates_with_latest_application_form.max_form_created_at, forms_with_earliest_audit.earliest_update')
        .where('candidate_api_updated_at < max_form_created_at OR candidate_api_updated_at < forms_with_earliest_audit.earliest_update')
        .where("created_at > '2021-01-01'")

      candidates.find_in_batches(batch_size: 10) do |batch|
        batch.each do |candidate|
          candidate.update!(candidate_api_updated_at: calculate_candidate_api_updated_at(candidate))
        end
      end
    end

  private

    def calculate_candidate_api_updated_at(candidate)
      [candidate.max_form_created_at, candidate.earliest_update].compact.max
    end
  end
end
