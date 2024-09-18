class DeleteAuditsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low_priority

  def perform(audit_ids)
    Audited::Audit.delete(audit_ids)
  end
end
