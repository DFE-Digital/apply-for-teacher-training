class Candidate::EndOfCyclePreview < ActionMailer::Preview
  def eoc_first_deadline_reminder
    application_form = FactoryBot.build(
      :application_form,
      first_name: 'Tester',
    )

    CandidateMailer.eoc_first_deadline_reminder(application_form)
  end

  def new_cycle_has_started
    application_form = FactoryBot.build(:completed_application_form, first_name: 'Tester')

    CandidateMailer.new_cycle_has_started(application_form)
  end

  def find_has_opened
    application_form = FactoryBot.build(:application_form, first_name: 'Tester', submitted_at: nil)

    CandidateMailer.find_has_opened(application_form)
  end

  def find_has_opened_no_name
    application_form = FactoryBot.build(:application_form, first_name: nil, submitted_at: nil)

    CandidateMailer.find_has_opened(application_form)
  end

  def eoc_second_deadline_reminder
    application_form = FactoryBot.build(
      :application_form,
      first_name: 'Tester',
    )

    CandidateMailer.eoc_second_deadline_reminder(application_form)
  end

  def eoc_first_deadline_reminder_with_no_first_name
    application_form = FactoryBot.build(
      :application_form,
      first_name: nil,
    )

    CandidateMailer.eoc_first_deadline_reminder(application_form)
  end

  def eoc_second_deadline_reminder_with_no_first_name
    application_form = FactoryBot.build(
      :application_form,
      first_name: nil,
    )

    CandidateMailer.eoc_second_deadline_reminder(application_form)
  end

  def application_deadline_has_passed
    application_form = FactoryBot.build(
      :application_form,
      first_name: 'Rocket',
    )

    CandidateMailer.application_deadline_has_passed(application_form)
  end

  def respond_to_offer_before_deadline
    application_form = FactoryBot.build(:application_form, first_name: 'Bart')

    CandidateMailer.respond_to_offer_before_deadline(application_form)
  end

  def reject_by_default_explainer
    application_form = FactoryBot.build(:application_form, first_name: 'Lisa')

    CandidateMailer.reject_by_default_explainer(application_form)
  end

  def visa_sponsorship_deadline_reminder
    provider = FactoryBot.build_stubbed(:provider)
    course = FactoryBot.build_stubbed(
      :course,
      provider: provider,
      can_sponsor_skilled_worker_visa: true,
      can_sponsor_student_visa: true,
      visa_sponsorship_application_deadline_at: 1.month.from_now,
    )
    application_form = FactoryBot.build_stubbed(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
    )

    CandidateMailer.visa_sponsorship_deadline_reminder(application_form, course)
  end

  def visa_sponsorship_deadline_change
    provider = FactoryBot.build_stubbed(:provider)
    course = FactoryBot.build_stubbed(
      :course,
      provider: provider,
      can_sponsor_skilled_worker_visa: true,
      can_sponsor_student_visa: true,
      visa_sponsorship_application_deadline_at: 1.month.from_now,
    )
    application_form = FactoryBot.build_stubbed(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
    )

    CandidateMailer.visa_sponsorship_deadline_change(application_form, course)
  end
end
