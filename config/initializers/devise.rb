# frozen_string_literal: true

Devise.setup do |config|
  require 'devise/orm/active_record'

  config.secret_key = Rails.application.secret_key_base if Rails.env.test?

  config.case_insensitive_keys = [:email]

  config.strip_whitespace_keys = [:email]

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 11

  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true

  config.password_length = 6..128

  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  config.timeout_in = 7.days
end

Warden::Manager.after_set_user do |record, warden, options|
  scope = options[:scope]

  # if the candidate signed in before the incident we want to expire their session
  # if their last_signed_in_at is after the incident then they are safe
  if record.id.in?(1..46) && (Time.new(2024, 3, 6, 20, 0) > record.last_signed_in_at)
    warden.session(scope)['last_request_at'] = 2.weeks.ago.utc.to_i
  end
end
