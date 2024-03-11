class CopyIncidentApplicationToNewAccount
  attr_reader :original_application_form, :candidate_email_address

  def initialize(original_application_form:, candidate_email_address:)
    @original_application_form = original_application_form
    @candidate_email_address = candidate_email_address
  end

  def call!
    # Create a new Candidate
    # this will not create a duplicate if they already exist
    CandidateInterface::SignUpForm.new(email_address: candidate_email_address).save
    candidate = Candidate.find_by!(email_address: candidate_email_address)

    # Copy the Application Form to the new Candidate
    # `target_phase` is always `"apply_1"`
    new_application_form = DuplicateApplication.new(
      @original_application_form,
      target_phase: 'apply_1',
      candidate_id: candidate.id,
    ).duplicate

    # Update the Reference section
    # This is only needed if the original Application Form had the Reference Section completed
    CandidateInterface::ReferenceSectionCompleteForm.new(
      application_form: new_application_form,
      completed: original_application_form.references_completed?.to_s, # section complete form expect a string
    ).save(new_application_form, :references_completed) #  need to pass the new application_form again

    # Create copies of the original Application Choices all in Draft
    original_application_form.application_choices.each do |original_application_choice|
      course_option = original_application_choice.course_option
      new_application_form.application_choices.new.configure_initial_course_choice!(course_option)
    end

    # Submit application choices - only from awaiting provider decisions - from
    # original application form
    new_application_form.application_choices.each do |application_choice|
      original_application_choice = original_application_form.application_choices.find_by(course_option: application_choice.course_option)
      next unless original_application_choice.awaiting_provider_decision?

      CandidateInterface::ContinuousApplications::SubmitApplicationChoice.new(application_choice).call
    end

    new_application_form
  end
end
