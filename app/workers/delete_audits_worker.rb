class DeleteAuditsWorker < ApplicationJob
  queue_as :low_priority

  def perform(audit_ids)
    Audited::Audit.where(id: audit_ids).delete_all
  end
end
