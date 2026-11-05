class UpdateTriggeredDuplicateMatches
  def initialize(application_form)
    @application_form = application_form
  end

  def save!
    matches = GetDuplicateMatchesForApplicationForm.call(@application_form)

    ActiveRecord::Base.transaction do
      if matches.empty?
        @application_form.candidate.reload.triggered_duplicate_match&.touch
      else
        duplicate_match = find_or_create_duplicate_match
        Candidate.where(id: matches.pluck('candidate_id')).update_all(triggered_duplicate_match_id: duplicate_match.id)
      end
    end
  end

private

  def find_or_create_duplicate_match
    TriggeredDuplicateMatch.match_for(
      last_name: @application_form.last_name,
      postcode: @application_form.postcode,
      date_of_birth: @application_form.date_of_birth,
    ) || TriggeredDuplicateMatch.create!(
      recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
      last_name: @application_form.last_name,
      postcode: @application_form.postcode.to_s.upcase.strip,
      date_of_birth: @application_form.date_of_birth,
    )
  end
end
