class UpdateFraudMatches
  def initialize
    @matches = GetFraudMatches.call
  end

  def save!
    @matches.each do |match|
      fraud_match = FraudMatch.find_by(last_name: match['last_name'], postcode: match['postcode'], date_of_birth: match['date_of_birth'])
      candidate = Candidate.find(match['candidate_id'])
      if fraud_match.present?
        fraud_match.candidates << candidate unless fraud_match.candidates.include?(candidate)
      else
        fraud_match = FraudMatch.create!(
          recruitment_cycle_year: RecruitmentCycle.current_year,
          last_name: match['last_name'],
          postcode: match['postcode'],
          date_of_birth: match['date_of_birth'],
        )

        fraud_match.candidates << candidate
      end
    end
  end
end
