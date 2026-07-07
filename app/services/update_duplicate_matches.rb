class UpdateDuplicateMatches
  def initialize(matches: GetDuplicateMatches.call, send_email: true, block_submission: true)
    @matches = matches
    @send_email = send_email
    @block_submission = block_submission
  end

  def save!
    duplicate_groups.each_value do |group|
      process_duplicate_group(group)
    end
  end

private

  def current_year
    @current_year ||= RecruitmentCycleTimetable.current_year
  end

  # Process duplicate candidates as a group so an existing DuplicateMatch
  # can be reused before creating a new one. Previously matches were
  # processed individually and only reused a DuplicateMatch found via the
  # current surname, date of birth and postcode.
  def duplicate_groups
    @matches.group_by do |match|
      [
        match['last_name'].to_s.downcase.strip,
        match['date_of_birth'],
        match['postcode'].to_s.upcase.gsub(' ', ''),
      ]
    end
  end

  def process_duplicate_group(group)
    ActiveRecord::Base.transaction do
      candidates = Candidate.where(
        id: group.map { |match| match['candidate_id'] },
      )

      duplicate_match = duplicate_match_for_group(
        candidates:,
        match: group.first,
      )

      candidates.each do |candidate|
        next if duplicate_match.candidates.include?(candidate)

        duplicate_match.candidates << candidate
        process_match(candidate, duplicate_match)
      end

      unresolve_match(duplicate_match)
    end
  end

  def duplicate_match_for_group(candidates:, match:)
    # Reuse any DuplicateMatch already associated with this duplicate group.
    candidate_duplicate_matches = candidates
      .map(&:duplicate_match)
      .compact
      .uniq

    return candidate_duplicate_matches.first if candidate_duplicate_matches.any?

    # Fall back to the original behaviour: look for a DuplicateMatch
    # matching the current surname, date of birth and postcode.
    existing_duplicate_match = DuplicateMatch.match_for(
      last_name: match['last_name'],
      postcode: match['postcode'],
      date_of_birth: match['date_of_birth'],
    )

    return existing_duplicate_match if existing_duplicate_match.present?

    DuplicateMatch.create!(
      recruitment_cycle_year: current_year,
      last_name: match['last_name'],
      postcode: match['postcode'],
      date_of_birth: match['date_of_birth'],
    )
  end

  def notify_candidate(candidate, duplicate_match)
    SupportInterface::SendDuplicateMatchEmail.new(candidate).call
    duplicate_match.update!(candidate_last_contacted_at: Time.zone.now)
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
