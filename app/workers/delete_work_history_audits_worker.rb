class DeleteWorkHistoryAuditsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  AUDITABLE_TYPES = %w[ApplicationExperience ApplicationWorkHistoryBreak].freeze

  def perform(audit_ids)
    Audited::Audit.where(id: audit_ids).find_each(batch_size: 100) do |audit|
      audit.delete if AUDITABLE_TYPES.include?(audit.auditable_type) &&
                      audit.associated_type == 'ApplicationChoice' &&
                      audit.action == 'create' &&
                      audit.username == '(Automated process)'
    end
  end
end
