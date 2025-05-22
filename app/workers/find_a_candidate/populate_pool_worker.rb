class FindACandidate::PopulatePoolWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform
    application_forms_eligible_for_pool = Pool::Candidates.new(providers: [])
                                                          .curated_application_forms
                                                          .pluck(:id, :candidate_id)

    candidate_application_insert_data = application_forms_eligible_for_pool.map do |application_form_id, candidate_id|
      {
        application_form_id: application_form_id,
        candidate_id: candidate_id,
      }
    end

    CandidatePoolApplication.transaction do
      CandidatePoolApplication.delete_all
      CandidatePoolApplication.insert_all(candidate_application_insert_data)
    end
  end
end
