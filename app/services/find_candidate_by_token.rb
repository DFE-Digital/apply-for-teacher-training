class FindCandidateByToken
  def self.call(raw_token:)
    token = MagicLinkToken.from_raw(raw_token)
    Candidate.find_by(magic_link_token: token)
  end
end
