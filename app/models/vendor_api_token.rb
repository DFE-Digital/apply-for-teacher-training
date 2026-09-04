class VendorAPIToken < ApplicationRecord
  include Discard::Model

  IN_HOUSE = 'in_house'.freeze
  THIRD_PARTY = 'third_party'.freeze

  belongs_to :provider
  belongs_to :vendor, optional: true

  audited associated_with: :provider

  scope :used_in_last_3_months, -> { where('last_used_at >= ?', 3.months.ago) }

  def vendor_name
    return unless vendor

    vendor.name == IN_HOUSE ? 'In-house developers' : vendor.name.humanize
  end

  def status
    discarded_at ? 'revoked' : 'active'
  end

  def self.create_with_random_token!(provider:, **attributes)
    unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
    create!(attributes.merge({ hashed_token:, provider: }))
    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    hashed_token = Devise.token_generator.digest(VendorAPIToken, :hashed_token, unhashed_token)
    find_by(hashed_token:)
  end
end
