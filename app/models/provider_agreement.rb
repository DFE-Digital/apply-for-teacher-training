class ProviderAgreement < ApplicationRecord
  belongs_to :provider
  belongs_to :provider_user
  attr_accessor :accept_agreement

  audited associated_with: :provider

  validates :accept_agreement, :agreement_type, presence: true
  validate :provider_is_associated_with_the_user
  before_create :set_accepted_at

  scope :data_sharing_agreements, -> { where(agreement_type: :data_sharing_agreement) }
  scope :for_provider, ->(specific_provider) { where(provider: specific_provider) }

private

  def provider_is_associated_with_the_user
    if provider && provider_user && provider.provider_users.exclude?(provider_user)
      errors.add(:provider, 'Provider and ProviderAgreement must share a ProviderUser')
    end
  end

  def set_accepted_at
    self.accepted_at ||= Time.zone.now
  end
end
