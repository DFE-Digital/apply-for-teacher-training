class DuplicateMatchBlockSubmissions
  attr_reader :duplicate_matches

  def initialize(start_date: Date.new(2022, 1, 25), end_date: Date.new(2022, 2, 2))
    @duplicate_matches = DuplicateMatch.where(
      'created_at between ? AND ?', start_date, end_date
    )
  end

  def call
    @duplicate_matches.each do |duplicate_match|
      duplicate_match.candidates.each do |candidate|
        candidate.update(submission_blocked: true)
      end
    end
  end
end
