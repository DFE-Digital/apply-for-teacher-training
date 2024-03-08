# frozen_string_literal: true

DEPLOY_DATE = Time.zone.local(2024, 3, 8, 12)
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
  # User is not affected
  break unless record.id.in?(1..46)

  scope = options[:scope]
  lra = warden.session(scope)['last_request_at']

  # The cookie must have a last_request_at in order to be relevant
  next if warden.session(scope)['last_request_at'].nil?
  next if warden.session(scope)['incident_cleared'].present?

  case lra
  when Integer
    last_request_at = Time.zone.at(lra)
  when String
    last_request_at = Time.zone.parse(lra)
  end

  # The cookie has already expired
  next if Time.zone.now > Devise.timeout_in.since(last_request_at)

  warden.session(scope).delete('last_request_at')
  warden.session(scope)['incident_cleared'] = Time.zone.now.utc.to_i.to_s
end
