require 'rails_helper'

RSpec.describe 'Receives rejection email' do
  include CandidateHelper

  scenario 'Receives rejection email during mid-cycle' do
    given_it_is_mid_cycle
    when_i_have_submitted_an_application
    and_a_provider_rejects_my_application
    then_i_receive_the_application_rejected_email
    and_it_includes_text_for_mid_cycle
    and_it_includes_details_of_my_application
  end

  scenario 'Receive rejection email between cycles' do
    given_it_is_between_cycles
    when_i_have_submitted_an_application
    and_a_provider_rejects_my_application
    then_i_receive_the_application_rejected_email
    and_it_includes_text_for_between_cycle
    and_it_includes_details_of_my_application
  end

  def given_it_is_between_cycles
    TestSuiteTimeMachine.travel_permanently_to(after_apply_deadline)
  end

  def given_it_is_mid_cycle
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
  end

  def when_i_have_submitted_an_application
    @application_form = create(:completed_application_form)
    @application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: @application_form)
  end

  def and_a_provider_rejects_my_application
    rejection_reasons_attrs = {
      selected_reasons: [
        { id: 'qualifications', label: 'Qualifications', selected_reasons: [
          { id: 'no_maths_gcse', label: 'No Maths GCSE' },
          { id: 'no_science_gcse', label: 'No Science GCSE' },
        ] },
        { id: 'course_full', label: 'Course full' },
      ],
    }
    RejectApplication.new(
      actor: create(:support_user),
      application_choice: @application_choice,
      structured_rejection_reasons: RejectionReasons.new(rejection_reasons_attrs),
    ).save
  end

  def then_i_receive_the_application_rejected_email
    open_email(@application_form.candidate.email_address)

    expect(current_email.subject).to include(I18n.t!('candidate_mailer.application_rejected.subject'))
  end

  def and_it_includes_text_for_mid_cycle
    expect(current_email.text).to include('You can apply again')
    expect(current_email.text).to include('This year, more people than ever are choosing to apply again.')
  end

  def and_it_includes_text_for_between_cycle
    apply_reopens = current_timetable.apply_reopens_at
    expect(current_email.text).to include("You can apply again from#{I18n.l(apply_reopens.to_date, format: :long)}")
    expect(current_email.text).to include('Lots of people are successful when they apply again.')
  end

  def and_it_includes_details_of_my_application
    expect(current_email.text).to include(@application_choice.course.provider.name)
    expect(current_email.text).to include(@application_choice.course.name)
    expect(current_email.text).to include('No Maths GCSE')
    expect(current_email.text).to include('No Science GCSE')
    expect(current_email.text).to include('Course full')
    expect(current_email.text).to include('Make sure you meet the qualifications criteria')
  end
end
