# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
SANITIZED_REQUEST_PARAMS = %i[
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
].freeze
Rails.application.config.filter_parameters += SANITIZED_REQUEST_PARAMS
