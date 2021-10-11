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
        FraudMatch.create!(
          recruitment_cycle_year: RecruitmentCycle.current_year,
          last_name: match['last_name'],
          postcode: match['postcode'],
          date_of_birth: match['date_of_birth'],
          candidates: [candidate],
        )
      end
    end

    message = <<~MSG
      :face_with_monocle: There’s #{new_match_count} new fraud #{'match'.pluralize(new_match_count)} today :face_with_monocle:
      :gavel: #{fraudulent_match_count} #{'match'.pluralize(fraudulent_match_count)} #{fraudulent_match_count == 1 ? 'has' : 'have'} been marked as fraudulent :gavel:
      :female-detective: In total there’s #{FraudMatch.count} #{'match'.pluralize(FraudMatch.count)} :male-detective:
    MSG

    url = Rails.application.routes.url_helpers.support_interface_fraud_auditing_matches_url
    SlackNotificationWorker.perform_async(message, url)
  end

private

  def new_match_count
    FraudMatch.where('created_at > ?', 1.day.ago).count
  end

  def fraudulent_match_count
    FraudMatch.where(fraudulent?: true).count
  end
end
