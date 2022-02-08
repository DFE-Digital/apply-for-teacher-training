class DuplicateMatchSendEmail
  attr_reader :duplicate_matches

  def initialize(start_date: Date.new(2022, 1, 26), end_date: Date.new(2022, 2, 2))
    @duplicate_matches = FraudMatch.where(
      'created_at between ? AND ?', start_date, end_date
    )
  end

  def call
    @duplicate_matches.each do |duplicate_match|
      duplicate_match.candidates.each do |candidate|
        SupportInterface::SendDuplicateMatchEmail.new(candidate).call
        duplicate_match.update!(candidate_last_contacted_at: Time.zone.now)
      end
    end
  end
end
