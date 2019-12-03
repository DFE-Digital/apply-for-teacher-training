class Candidate < ApplicationRecord
  # Only Devise's :timeoutable module is enabled to handle session expiry
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  devise :timeoutable
  validates :email_address, presence: true, uniqueness: true, length: { maximum: 250 }
  validates :email_address, email_address: true

  has_many :application_forms

  def current_application
    application_form = application_forms.first_or_create!
    application_form
  end
end
