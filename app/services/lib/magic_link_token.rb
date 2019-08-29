class MagicLinkToken
  attr_reader :encrypted, :raw

  def initialize
    @raw, @encrypted = Devise.token_generator.generate(Candidate, :magic_link_token)
  end

  def self.from_raw(token)
    Devise.token_generator.digest(Candidate, :magic_link_token, token)
  end
end
