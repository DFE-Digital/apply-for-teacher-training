class CopyIncidentApplicationToNewAccount
  attr_reader :original_application_form, :candidate_email_address

  def initialize(original_application_form:, candidate_email_address:)
    @original_application_form = original_application_form
    @candidate_email_address = candidate_email_address.downcase
  end

  def call!
    # Create a new Candidate
    # this will not create a duplicate if they already exist
    log('Creating a new candidate if they do not exist')
    CandidateInterface::SignUpForm.new(email_address: candidate_email_address).save
    candidate = Candidate.find_by!(email_address: candidate_email_address)

    # Copy the Application Form to the new Candidate
    # `target_phase` is always `"apply_1"`
    log("Copying application form #{@original_application_form.id} from candidate #{@original_application_form.candidate_id} to candidate #{candidate.id}")
    new_application_form = DuplicateApplication.new(
      @original_application_form,
      target_phase: 'apply_1',
      candidate_id: candidate.id,
    ).duplicate

    # Update the Reference section
    # This is only needed if the original Application Form had the Reference Section completed
    log('Mark references section as complete')
    CandidateInterface::ReferenceSectionCompleteForm.new(
      application_form: new_application_form,
      completed: original_application_form.references_completed?.to_s, # section complete form expect a string
    ).save(new_application_form, :references_completed) #  need to pass the new application_form again

    # When a qualification has constituent_grades the public id is generated for
    # each grade therefore on the Vendor API we need to show this public id for
    # each of constituent grade.
    #
    #   Constituent grades
    #    {"english_single_award"=>{"grade"=>"C", "public_id"=>121847}
    #    {"english_double_award"=>{"grade"=>"C:D", "public_id"=>121840}
    #
    # When a qualification does not have a constituent grade we have the public
    # id and the grade to be look upon.
    #
    #    grade: 'B', public_id: '3009'
    #
    # For the incident we need to force the generation of the public ids
    # for constituent grades because the set public id on qualification
    # models doesn't generate a new one
    #
    new_application_form.application_qualifications.each(&:update_constituent_grades_public_ids)

    log("Copying #{original_application_form.application_choices.count} application choices to application form #{new_application_form.id}")
    original_application_form.application_choices.each do |original_application_choice|
      course_option = original_application_choice.course_option
      new_application_choice = new_application_form.application_choices.new
      new_application_choice.configure_initial_course_choice!(course_option)

      # updating personal statement for unsubmitted application choices
      new_application_choice.update(personal_statement: original_application_choice.personal_statement)
    end

    # Submit application choices - only from awaiting provider decisions - from
    # original application form
    log("Submit #{original_application_form.application_choices.awaiting_provider_decision.count} application choices to application form #{new_application_form.id}")
    new_application_form.application_choices.each do |application_choice|
      original_application_choice = original_application_form.application_choices.find_by(course_option: application_choice.course_option)
      next unless original_application_choice.awaiting_provider_decision?

      application_choice_submission = CandidateInterface::ContinuousApplications::ApplicationChoiceSubmission.new(application_choice:)
      log("Submit application choice #{application_choice.id}. Valid?: #{application_choice_submission.valid?}")
      next unless application_choice_submission.valid?

      CandidateInterface::ContinuousApplications::SubmitApplicationChoice.new(application_choice).call

      # updating personal statement because the submit application choices
      # copies the current personal statement from the new created form at
      # the time of submission (line above)
      application_choice.update(personal_statement: original_application_choice.personal_statement)
    end

    new_application_form
  end

  def log(message)
    Rails.logger.info('=' * 80)
    Rails.logger.info(message)
    Rails.logger.info('=' * 80)
  end
end
