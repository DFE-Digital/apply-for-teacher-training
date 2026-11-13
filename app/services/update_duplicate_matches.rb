class UpdateDuplicateMatches
  def initialize(matches: GetDuplicateMatches.call, send_email: true, lock_account: true)
    @matches = matches
    @send_email = send_email
    @lock_account = lock_account
  end

  def save!
    @matches.each do |match|
      save_match(match)
    end
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
      # lock them here
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

  def process_match(candidate, duplicate_match)
    # notify both accounts
    #
    #  new_candidate = Candidate.find_by(id: params.require(:candidate_id))
    #  CandidateMailer.duplicate_account_locked(
    #    new_candidate.current_application,
    #  ).deliver_later

    #  match = new_candidate.duplicate_match
    #  old_candidate = match.candidates.where.not(id: new_candidate.id).order(:created_at).last
    #  CandidateMailer.duplicate_account_original_account_sign_in(
    #    old_candidate.current_application,
    #  ).deliver_later
    #
    notify_candidate(candidate, duplicate_match) if @send_email
    lock_account(candidate) if @lock_account
  end

  def lock_account(candidate)
    candidate.update!(account_locked: true)
  end

  def unresolve_match(duplicate_match)
    duplicate_match.update!(resolved: false)
  end
end
