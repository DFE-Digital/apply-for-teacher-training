class SupportUser < ActiveRecord::Base
  validates :dfe_sign_in_uid, presence: true
  validates :email_address, presence: true
end
