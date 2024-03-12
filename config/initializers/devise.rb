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
  next unless FeatureFlag.active?(:incident_eviction)

  # User is not affected
  next unless record.id.in?(1..46) && record.instance_of?(Candidate)

  scope = options[:scope]
  lra = warden.session(scope)['last_request_at']

  # The cookie must have a last_request_at in order to be relevant
  next if lra.nil?

  case lra
  when Integer
    last_request_at = Time.zone.at(lra)
  when String
    last_request_at = Time.zone.parse(lra)
  end

  # The cookie has already expired
  next if Time.zone.now > Devise.timeout_in.since(last_request_at)

  # The cookie has already been cleared once if last_request_at is after the feature flag was activated
  next if Feature.find_by(name: 'incident_eviction').audits.empty?
  next if last_request_at > Feature.find_by(name: 'incident_eviction').audits.last.created_at

  # Set the last_request_at so that the session has timed out.
  # Then Devise will log the user out.
  warden.session(scope)['last_request_at'] = 2.weeks.ago.to_i
  Rails.logger.info "Candidate with id #{record.id} has been logged out"
end
