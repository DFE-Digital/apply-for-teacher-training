class SupportUser < ActiveRecord::Base
  validates :dfe_sign_in_uid, presence: true
  validates :email_address, presence: true

  def self.load_from_session(session)
    dfe_sign_in_user = DfESignInUser.load_from_session(session)
    return unless dfe_sign_in_user

    SupportUser.find_by(dfe_sign_in_uid: dfe_sign_in_user.dfe_sign_in_uid)
  end
end
