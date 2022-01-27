class UpdateDuplicateMatches
  def initialize
    @matches = GetFraudMatches.call
  end

  def save!
    @matches.each do |match|
      save_match(match)
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

  def save_match(match)
    ActiveRecord::Base.transaction do
      create_or_update_fraud_match(match)
    end
  end

  def create_or_update_fraud_match(match)
    existing_fraud_match = FraudMatch.match_for(
      last_name: match['last_name'],
      postcode: match['postcode'],
      date_of_birth: match['date_of_birth'],
    )
    candidate = Candidate.find(match['candidate_id'])

    if existing_fraud_match.present?
      unless existing_fraud_match.candidates.include?(candidate)
        existing_fraud_match.candidates << candidate
        process_match(candidate, existing_fraud_match)
      end
    else
      new_fraud_match = FraudMatch.create!(
        recruitment_cycle_year: RecruitmentCycle.current_year,
        last_name: match['last_name'],
        postcode: match['postcode'],
        date_of_birth: match['date_of_birth'],
        candidates: [candidate],
      )
      process_match(candidate, new_fraud_match)
    end

    candidate
  end

  def notify_candidate(candidate, fraud_match)
    SupportInterface::SendDuplicateMatchEmail.new(candidate).call
    fraud_match.update!(candidate_last_contacted_at: Time.zone.now)
  end

  def new_match_count
    @new_match_count ||= FraudMatch.where('created_at > ?', 1.day.ago).count
  end

  def fraudulent_match_count
    @fraudulent_match_count ||= FraudMatch.where(recruitment_cycle_year: CycleTimetable.current_year, fraudulent: true).count
  end

  def total_match_count
    @total_match_count ||= FraudMatch.where(recruitment_cycle_year: CycleTimetable.current_year).count
  end

  def process_match(candidate, fraud_match)
    notify_candidate(candidate, fraud_match)
    block_submission(candidate)
  end

  def block_submission(candidate)
    candidate.update!(submission_blocked: true)
  end
end
