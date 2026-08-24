class DeleteOldCandidatesWorker < ApplicationJob
  def perform
    # candidates = Candidate.where('last_signed_in_at < ?', 7.years.ago).find_in_batches(&:destroy_all)

    analytics_tables = YAML.load_file('config/analytics.yml').fetch('shared').keys.map(&:to_s)
    candidates = Candidate.where(id: 58)
    candidates.find_in_batches(batch_size: 100) do |batch|
      batch.each do |candidate| # put this into a worker
        ActiveRecord::Base.transaction do
          sql_keys = candidate.test_sql
          rails_keys = candidate.test_delete

          shared_keys = sql_keys.keys & rails_keys.keys
          deleted_tables = sql_keys.merge(rails_keys).except(shared_keys).except(analytics_tables).compact_blank

          DeletedCandidate.create!(candidate_id: candidate.id, deleted_tables:)
          candidate.destroy!
        end
      end
    end
  end
end
