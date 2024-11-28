class OneLoginUser
  attr_reader :email, :token
  Error = Struct.new(:message)

  def initialize(auth)
    @email = auth.info.email
    @token = auth.uid
  end

  def self.authentificate(request)
    new(request).authentificate
  end

  def authentificate
    one_login_auth = OneLoginAuth.find_by(token:)
    existing_candidate = Candidate.find_by(email_address: email)
    candidate = nil
    error = nil

    if one_login_auth
      one_login_auth.update!(email:)
      candidate = one_login_auth.candidate
    elsif existing_candidate
      if existing_candidate.one_login_auth.present?
        error = Error.new('Candidate has one login attached, contact support') ## RAISE EXCEPTIONS
        raise 'Candidate has one login attached, contact support'
        ## This can happen if a user has 2 one login accounts and 2 apply accounts
        ## Then they 'recover' one account, recovering an account changes the one_login_auth association
        ## Should we not allow recover if a candidate has a one_login_auth? YES!
      else
        existing_candidate.create_one_login_auth(token:, email:) # find_or_create?
        candidate = existing_candidate
      end
    elsif existing_candidate.nil?
      candidate = Candidate.create!(email_address: email)
      candidate.create_one_login_auth(token:, email:)
    else
      error = Error.new('We cannot authentificate you, contact support')
      raise 'We cannot authentificate you, contact support'
    end

    [candidate, error]
  end
end
