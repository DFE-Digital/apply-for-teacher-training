class SupportUser < ActiveRecord::Base
  include Discard::Model
  include AuthenticatedUsingMagicLinks

  attr_accessor :impersonated_provider_user
  validates :dfe_sign_in_uid, presence: true
  validates :email_address, presence: true, uniqueness: true

  before_validation :downcase_email_address

  audited except: [:last_signed_in_at]

  def self.load_from_session(session)
    return unless (dsi_user = DfESignInUser.load_from_session(session))

    support_user = SupportUser.kept.find_by(dfe_sign_in_uid: dsi_user.dfe_sign_in_uid)

    if support_user
      support_user.impersonated_provider_user = dsi_user.impersonated_provider_user
      support_user
    end
  end

  def display_name
    [first_name, last_name].join(' ').presence || email_address
  end

private

  def downcase_email_address
    self.email_address = email_address.downcase
  end
end
