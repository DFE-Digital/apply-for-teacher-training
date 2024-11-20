# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
SANITIZED_REQUEST_PARAMS = %i[
  token
  address_line1
  address_line2
  address_line3
  address_line4
  country
  date_of_birth
  email
  email_address
  first_name
  full_name
  last_name
  magic_link_token
  password
  phone_number
  postcode
  subject
  passw
  secret
  _key
  crypt
  salt
  certificate
  otp
  ssn
].freeze

MAILER_SANITIZED_PARAMS = %w[
  mailer.subject
  mailer.to
  mailer.args
].freeze

SANITIZED_PARAMS_RAILS_DEFAULTS = %i[
  passw email secret token _key crypt salt certificate otp ssn cvv cvc
].freeze

Rails.application.config.filter_parameters += SANITIZED_PARAMS_RAILS_DEFAULTS
Rails.application.config.filter_parameters += SANITIZED_REQUEST_PARAMS
Rails.application.config.filter_parameters += MAILER_SANITIZED_PARAMS
