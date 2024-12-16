class OneLoginUserBypass
  include ActiveModel::Model

  validates :token, presence: true

  attr_accessor :token

  def authentificate
    return unless valid?

    one_login_auth = OneLoginAuth.find_by(token:)

    return one_login_auth.candidate if one_login_auth

    created_candidate
  end

private

  def created_candidate
    candidate = Candidate.create!(email_address: bypass_email_address)
    candidate.create_one_login_auth!(token:, email_address: bypass_email_address)

    candidate
  end

  def bypass_email_address
    "#{token}@example.com"
  end
end
