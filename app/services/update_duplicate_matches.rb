class UpdateDuplicateMatches
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
          candidates: [candidate],
        )
      end

      SupportInterface::SendDuplicateMatchEmail.new(candidate).call
      candidate.update!(submission_blocked: true)

      # TODO: should this attribute be moved to the `Candidate` class?
      fraud_match.update!(candidate_last_contacted_at: Time.zone.now)
    end

    message = <<~MSG
      \n#{Rails.application.routes.url_helpers.support_interface_fraud_auditing_matches_url}
      :face_with_monocle: There #{new_match_count == 1 ? 'is' : 'are'} #{new_match_count} new duplicate candidate #{'match'.pluralize(new_match_count)} today :face_with_monocle:
      :gavel: #{fraudulent_match_count} #{'match'.pluralize(fraudulent_match_count)} #{fraudulent_match_count == 1 ? 'has' : 'have'} been marked as fraudulent :gavel:
      :female-detective: In total there #{total_match_count == 1 ? 'is' : 'are'} #{total_match_count} #{'match'.pluralize(total_match_count)} :male-detective:
    MSG

    SlackNotificationWorker.perform_async(message)
  end

private

  def new_match_count
    @new_match_count ||= FraudMatch.where('created_at > ?', 1.day.ago).count
  end

  def fraudulent_match_count
    @fraudulent_match_count ||= FraudMatch.where(recruitment_cycle_year: CycleTimetable.current_year, fraudulent: true).count
  end

  def total_match_count
    @total_match_count ||= FraudMatch.where(recruitment_cycle_year: CycleTimetable.current_year).count
  end
end
