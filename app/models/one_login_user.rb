class OneLoginUser
  class Error < StandardError; end
  attr_reader :email_address, :token

  def initialize(omniauth_object)
    @email_address = omniauth_object.info.email
    @token = omniauth_object.uid
  end

  def self.authenticate_or_create_by(omniauth_auth)
    new(omniauth_auth).authenticate_or_create_by
  end

  def authenticate_or_create_by
    one_login_auth = OneLoginAuth.find_by(token:)
    existing_candidate = Candidate.find_by(email_address:)

    return candidate_with_one_login(one_login_auth) if one_login_auth
    return existing_candidate_without_one_login(existing_candidate) if existing_candidate

    create_candidate!
  end

  def self.find_candidate(omniauth_auth)
    new(omniauth_auth).find_candidate
  end

  def find_candidate
    OneLoginAuth.find_by(token:)&.candidate || Candidate.find_by(email_address:)
  end

private

  def candidate_with_one_login(one_login_auth)
    one_login_auth.update!(email_address:)
    one_login_auth.candidate
  end

  def existing_candidate_without_one_login(existing_candidate)
    if existing_candidate.one_login_auth.present? && existing_candidate.one_login_auth.token != token
      raise(
        Error,
        "Candidate #{existing_candidate.id} has a different one login " \
        "token than the user trying to login. Token used to auth #{token}",
      )
    end

    existing_candidate.create_one_login_auth!(token:, email_address:)
    existing_candidate
  end

  def create_candidate!
    candidate = Candidate.create!(email_address:)
    candidate.create_one_login_auth!(token:, email_address:)

    candidate
  end
end
