class FindCandidateByToken
  MAX_TOKEN_DURATION = 1.hour

  def self.call(raw_token:)
    token = MagicLinkToken.from_raw(raw_token)

    Candidate.find_by(magic_link_token: token)
  end

  def self.token_not_expired?(candidate)
    return false if candidate.nil?

    Time.zone.now < (candidate.magic_link_token_sent_at + MAX_TOKEN_DURATION)
  end
end
