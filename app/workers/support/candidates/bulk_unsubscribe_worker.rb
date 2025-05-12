# frozen_string_literal: true

class Support::Candidates::BulkUnsubscribeWorker
  include Sidekiq::Worker

  def perform(email_addresses = [])
    SupportInterface::Candidates::BulkUnsubscribe.bulk_unsubscribe(email_addresses)
  end
end
