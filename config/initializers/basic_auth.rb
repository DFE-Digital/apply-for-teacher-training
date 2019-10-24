options = {
  ui_auth: {
    enabled:  Rails.env.production? || ENV['BASIC_AUTH_ENABLE'] == 'true',
    username: ENV['BASIC_AUTH_USERNAME'],
    password: ENV['BASIC_AUTH_PASSWORD'],
  },
  support_auth: {
    username: ENV['SUPPORT_USERNAME'],
    password: ENV['SUPPORT_PASSWORD'],
  },
}

BASIC_AUTH = options.freeze

class BasicAuth
  def self.enabled?(subsystem = :ui)
    if subsystem == :support
      true
    else
      BASIC_AUTH.dig(:ui_auth, :enabled)
    end
  end

  def self.get(subsystem, key)
    if subsystem == :support
      BASIC_AUTH.dig(:support_auth, key)
    else
      BASIC_AUTH.dig(:ui_auth, key)
    end
  end
end
