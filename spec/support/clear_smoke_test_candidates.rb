class ClearSmokeTestCandidates
  def self.call
    Candidate.where(
      'email_address ILIKE ?', '%@smoketesting.example.com'
    ).destroy_all
  end
end
