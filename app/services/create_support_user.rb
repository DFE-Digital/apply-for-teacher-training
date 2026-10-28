class CreateSupportUser
  attr_accessor :dfe_sign_in_uid, :email_address, :role

  def initialize(dfe_sign_in_uid:, email_address:, role: 'user_support')
    self.dfe_sign_in_uid = dfe_sign_in_uid
    self.email_address = email_address
    self.role = role
  end

  def call
    support_user = SupportUser.find_or_initialize_by(dfe_sign_in_uid:)
    support_user.email_address = email_address
    support_user.role = role
    support_user.save!
    support_user
  end
end
