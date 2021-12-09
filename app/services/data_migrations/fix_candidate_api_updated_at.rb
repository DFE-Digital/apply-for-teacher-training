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
        .select('candidates.*, candidates_with_latest_application_form.max_form_created_at')
        .where('candidate_api_updated_at < max_form_created_at')

      candidates.find_in_batches(batch_size: 10) do |batch|
        batch.each do |candidate|
          candidate.update!(candidate_api_updated_at: candidate.max_form_created_at)
        end
      end
    end
  end
end
