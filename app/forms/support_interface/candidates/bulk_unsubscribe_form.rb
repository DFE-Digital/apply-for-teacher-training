class SupportInterface::Candidates::BulkUnsubscribeForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :email_addresses, :string

  validates :email_addresses, presence: true

  def save
    return false unless valid?

    unsubscribe_email_addresses = email_addresses
                                    .split("\n")
                                    .map(&:strip)
                                    .compact_blank
    Support::Candidates::BulkUnsubscribeWorker.perform_async(unsubscribe_email_addresses)
    true
  end
end
