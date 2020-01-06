class ProviderAgreement < ActiveRecord::Base
  belongs_to :provider
  belongs_to :provider_user
  attr_accessor :accept_agreement

  validates :accept_agreement, :agreement_type, :provider, :provider_user, presence: true
  validate :provider_is_associated_with_the_user
  before_create :set_accepted_at

  scope :data_sharing_agreements, -> { where(agreement_type: :data_sharing_agreement) }
  scope :for_provider, ->(specific_provider) { where(provider: specific_provider) }

private

  def provider_is_associated_with_the_user
    if provider && provider_user
      unless provider.provider_users.pluck(:id).include? provider_user.id
        errors.add(:provider, 'Provider/user mismatch')
      end
    end
  end

  def set_accepted_at
    self.accepted_at ||= Time.zone.now
  end
end
