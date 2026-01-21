class SupportUser < ApplicationRecord
  include Discard::Model
  include AuthenticatedUsingMagicLinks

  attr_accessor :impersonated_provider_user
  validates :dfe_sign_in_uid, presence: true
  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(email) { email.downcase.strip }

  audited except: [:last_signed_in_at]

  has_many :dsi_sessions, as: :user, dependent: :destroy

  def display_name
    [first_name, last_name].join(' ').presence || email_address
  end
end
