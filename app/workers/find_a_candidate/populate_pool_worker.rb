class FindACandidate::PopulatePoolWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform
    application_forms_eligible_for_pool = Pool::Candidates.application_forms_in_the_pool
                                            .select('application_forms.id as application_form_id, application_forms.candidate_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP')

    insert_all_from_eligible_sql = <<~SQL
      INSERT INTO candidate_pool_applications (application_form_id, candidate_id, created_at, updated_at)
      #{application_forms_eligible_for_pool.to_sql}
    SQL

    CandidatePoolApplication.transaction do
      CandidatePoolApplication.delete_all
      ActiveRecord::Base.connection.execute(insert_all_from_eligible_sql)
    end
  end
end
