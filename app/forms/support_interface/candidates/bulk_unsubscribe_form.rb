class SupportInterface::Candidates::BulkUnsubscribeForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :email_addresses, :string
  attribute :audit_comment, :string
  attribute :audit_user

  validates :email_addresses, presence: true
  validates :audit_comment, presence: true

  def save
    return false unless valid?

    unsubscribe_email_addresses = email_addresses
                                    .split("\n")
                                    .map(&:strip)
                                    .compact_blank
    Support::Candidates::BulkUnsubscribeWorker.perform_async(
      audit_user.id,
      audit_comment,
      unsubscribe_email_addresses,
    )
    true
  end
end
