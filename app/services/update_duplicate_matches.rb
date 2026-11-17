class UpdateDuplicateMatches
  def initialize(application_form)
    @application_form = application_form
  end

  def save!
    matching_forms = GetDuplicateMatchesForApplicationForm.call(@application_form)

    ActiveRecord::Base.transaction do
      if matching_forms.empty?
        @application_form.candidate.reload.duplicate_match&.touch
      else
        duplicate_match = find_or_create_duplicate_match
        existing_candidate_ids = duplicate_match.candidate_ids

        new_duplicate_forms = matching_forms.drop(1).reject do |application_form|
          existing_candidate_ids.include?(application_form.candidate_id)
        end

        if new_duplicate_forms.any?
          CandidateMailer.duplicate_match_original_account_email(matching_forms.first).deliver_later
        end

        new_duplicate_forms.each do |application_form|
          CandidateMailer.duplicate_match_email(application_form).deliver_later
          application_form.candidate.update!(account_locked: true)
        end

        Candidate.where(id: matching_forms.pluck('candidate_id')).update(fraud_match_id: duplicate_match.id)
      end
    end
  end

private

  def find_or_create_duplicate_match
    DuplicateMatch.match_for(
      last_name: @application_form.last_name,
      postcode: @application_form.postcode,
      date_of_birth: @application_form.date_of_birth,
    ) || DuplicateMatch.create!(
      recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
      last_name: @application_form.last_name,
      postcode: @application_form.postcode.to_s.upcase.strip,
      date_of_birth: @application_form.date_of_birth,
      resolved: true,
    )
  end
end
