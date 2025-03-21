class UpdateDuplicateMatches
  def initialize(matches: GetDuplicateMatches.call, send_email: true, block_submission: true, notify_slack_at: nil)
    @matches = matches
    @send_email = send_email
    @block_submission = block_submission
    @notify_slack_at = notify_slack_at
  end

  def save!
    @matches.each do |match|
      save_match(match)
    end

    message = <<~MSG
      \n#{Rails.application.routes.url_helpers.support_interface_duplicate_matches_url}
      :face_with_monocle: There #{new_match_count == 1 ? 'is' : 'are'} #{new_match_count} new duplicate candidate #{'match'.pluralize(new_match_count)} today :face_with_monocle:
      :female-detective: In total there #{total_match_count == 1 ? 'is' : 'are'} #{total_match_count} #{'match'.pluralize(total_match_count)} :male-detective:
    MSG

    SlackNotificationWorker.perform_async(message) if @notify_slack_at.blank? || Time.zone.now.hour == @notify_slack_at
  end

private

  def current_year
    @current_year ||= RecruitmentCycleTimetable.current_year
  end

  def save_match(match)
    ActiveRecord::Base.transaction do
      create_or_update_duplicate_match(match)
    end
  end

  def create_or_update_duplicate_match(match)
    existing_duplicate_match = DuplicateMatch.match_for(
      last_name: match['last_name'],
      postcode: match['postcode'],
      date_of_birth: match['date_of_birth'],
    )
    candidate = Candidate.find(match['candidate_id'])

    if existing_duplicate_match.present?
      unless existing_duplicate_match.candidates.include?(candidate)
        existing_duplicate_match.candidates << candidate
        unresolve_match(existing_duplicate_match)
        process_match(candidate, existing_duplicate_match)
      end
    else
      new_duplicate_match = DuplicateMatch.create!(
        recruitment_cycle_year: current_year,
        last_name: match['last_name'],
        postcode: match['postcode'],
        date_of_birth: match['date_of_birth'],
        candidates: [candidate],
      )
      process_match(candidate, new_duplicate_match)
    end

    candidate
  end

  def notify_candidate(candidate, duplicate_match)
    SupportInterface::SendDuplicateMatchEmail.new(candidate).call
    duplicate_match.update!(candidate_last_contacted_at: Time.zone.now)
  end

  def new_match_count
    @new_match_count ||= DuplicateMatch.where('created_at > ?', 1.day.ago).count
  end

  def total_match_count
    @total_match_count ||= DuplicateMatch.where(recruitment_cycle_year: current_year).count
  end

  def process_match(candidate, duplicate_match)
    notify_candidate(candidate, duplicate_match) if @send_email
    block_submission(candidate) if @block_submission
  end

  def block_submission(candidate)
    candidate.update!(submission_blocked: true)
  end

  def unresolve_match(duplicate_match)
    duplicate_match.update!(resolved: false)
  end
end
