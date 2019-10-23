FEATURES = {
  basic_auth: {
    enabled:  Rails.env.production? || (!ENV['BASIC_AUTH_FORCE'].blank? && ENV['BASIC_AUTH_FORCE'] != 'false'),
    username: ENV['BASIC_AUTH_USERNAME'],
    password: ENV['BASIC_AUTH_PASSWORD'],
  },
  support_auth: {
    username: ENV['SUPPORT_USERNAME'],
    password: ENV['SUPPORT_PASSWORD'],
  },
}.to_hash.freeze # rubocop does not detect freezing without the to_hash
