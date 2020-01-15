class SupportUser < ActiveRecord::Base
  validates :dfe_sign_in_uid, presence: true
  validates :email_address, presence: true

  before_save :downcase_email_address

  def self.load_from_session(session)
    dfe_sign_in_user = DfESignInUser.load_from_session(session)
    return unless dfe_sign_in_user

    SupportUser.find_by(dfe_sign_in_uid: dfe_sign_in_user.dfe_sign_in_uid)
  end

private

  def downcase_email_address
    self.email_address = email_address.downcase
  end
end
