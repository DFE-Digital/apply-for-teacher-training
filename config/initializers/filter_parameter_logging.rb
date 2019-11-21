# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
SANITIZED_REQUEST_PARAMS = %i[
  password
  email
  first_name
  last_name
  full_name
  email_address
  address_line1
  address_line2
  address_line3
  address_line4
  country
  postcode
  date_of_birth
  phone_number
  magic_link_token
  date_of_birth
].freeze
Rails.application.config.filter_parameters += SANITIZED_REQUEST_PARAMS
