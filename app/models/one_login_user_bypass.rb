class OneLoginUserBypass
  include ActiveModel::Model

  validates :token, presence: true
  validate :token_format

  attr_accessor :token

  def authenticate
    return unless valid?

    bypass_one_login = OneLoginAuth.find_by(token: 'dev-candidate')

    if bypass_one_login && bypass_one_login.token == token
      bypass_one_login.candidate
    else
      errors.add(:base, "There is no candidate with #{token} uid")
      nil
    end
  end

private

  def token_format
    return if token.nil?

    errors.add(:token, :invalid) if token.match?(URI::MailTo::EMAIL_REGEXP)
  end
end
