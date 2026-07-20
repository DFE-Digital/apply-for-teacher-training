class DeleteAllOldAuditsInBatches
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  def perform
    before = Time.zone.local(2022, 10, 4)

    Audited::Audit.where('created_at < ?', before).in_batches(of: 10_000, &:delete_all)
  end
end
