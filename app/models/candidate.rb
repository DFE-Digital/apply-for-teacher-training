class Candidate < ApplicationRecord
  # Only Devise's :timeoutable module is enabled to handle session expiry
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  devise :timeoutable
  validates :email_address, presence: true, uniqueness: true, length: { maximum: 250 }

  # Validate against the pattern that notify use, because a mismatch will lead
  # to a 400.
  # From https://github.com/alphagov/notifications-utils/blob/ace25bd04f5802a1ca41633b8308600abce517fc/notifications_utils/__init__.py#L10-L11
  NOTIFY_EMAIL_REGEXP = %r{\A[a-zA-Z0-9.!#$%&'*+=?^_`{|}~\\-]+@([^.@][^@\\s]+)\z}.freeze
  validates :email_address, format: { with: NOTIFY_EMAIL_REGEXP }

  has_many :application_forms

  def current_application
    choice = ApplicationChoice.first_or_create do |ac|
      provider = Provider.find_or_create_by(code: 'ABC') { |p| p.name = 'Example provider' }
      ac.course = Course.find_or_create_by(name: 'English Primary', code: '123', provider: provider)
    end

    ApplicationForm.find_or_create_by(candidate: self) do |form|
      form.application_choices = [choice]
    end
  end
end
