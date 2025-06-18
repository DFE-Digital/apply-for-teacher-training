class Candidate::ReferencesPreview < ActionMailer::Preview
  def chase_reference
    CandidateMailer.chase_reference(reference_at_offer)
  end

  def chase_reference_again
    CandidateMailer.chase_reference_again(reference)
  end

  def new_referee_request_with_refused
    CandidateMailer.new_referee_request(reference, reason: :refused)
  end

  def new_referee_request_with_email_bounced
    CandidateMailer.new_referee_request(reference, reason: :email_bounced)
  end

  def reference_received
    CandidateMailer.reference_received(reference)
  end

  def reference_received_after_recruitment
    reference_at_offer.application_form.application_choices.first.update!(status: :recruited)
    CandidateMailer.reference_received(reference)
  end

private

  def reference_at_offer
    @application_form = FactoryBot.create(:application_form, :minimum_info, application_choices: [application_choice_pending_conditions])
    FactoryBot.create(:reference, application_form: @application_form)
  end

  def reference
    FactoryBot.build_stubbed(:reference, application_form:)
  end

  def application_choice_pending_conditions
    provider = FactoryBot.build(:provider, name: 'Brighthurst Technical College')
    course = FactoryBot.build(:course, name: 'Applied Science (Psychology)', code: '3TT5', provider: provider)
    course_option = FactoryBot.build(:course_option, course: course)

    FactoryBot.build(:application_choice,
                     :pending_conditions,
                     application_form:,
                     course_option: course_option,
                     sent_to_provider_at: 1.day.ago)
  end

  def candidate
    @candidate ||= FactoryBot.build_stubbed(:candidate)
  end

  def application_form
    @application_form ||= FactoryBot.build_stubbed(:application_form, first_name: 'Gemma', candidate:)
  end
end
