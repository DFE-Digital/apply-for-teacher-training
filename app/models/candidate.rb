class Candidate < ApplicationRecord
  # Only Devise's :timeoutable module is enabled to handle session expiry
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  devise :timeoutable

  before_validation :downcase_email
  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            length: { maximum: 250 },
                            email_address: true

  has_many :application_forms

  def self.for_email(email)
    find_or_initialize_by(email_address: email.downcase) if email
  end

  def current_application
    application_form = application_forms.first_or_create!
    application_form
  end

private

  def downcase_email
    email_address.try(:downcase!)
  end
end
