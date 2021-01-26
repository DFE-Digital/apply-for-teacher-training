require 'rails_helper'

RSpec.feature 'Reasons for rejection dashboard' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2020, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'View reasons for rejection', with_audited: true do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_page_in_support
    and_i_click_on_the_reasons_for_rejection_metrics_link

    then_i_should_see_reasons_for_rejection_metrics
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    allow(EndOfCycleTimetable).to receive(:apply_reopens).and_return(60.days.ago)
    application_choice1 = create(:application_choice, :awaiting_provider_decision)
    application_choice2 = create(:application_choice, :awaiting_provider_decision)
    application_choice3 = create(:application_choice, :awaiting_provider_decision)

    Timecop.freeze(@today - 40.days) do
      reject_application_with_structured_reasons(application_choice1)
    end

    Timecop.freeze(@today) do
      reject_application_with_structured_reasons(application_choice2)
      reject_application_without_structured_reasons(application_choice3)
    end
  end

  def when_i_visit_the_performance_page_in_support
    visit support_interface_performance_path
  end

  def and_i_click_on_the_reasons_for_rejection_metrics_link
    click_on 'Reasons for rejection'
  end

  def then_i_should_see_reasons_for_rejection_metrics
    then_i_should_see_reasons_for_rejection_course_full
    and_i_should_see_reasons_for_rejection_candidate_behaviour
    and_i_should_see_reasons_for_rejection_honesty_and_professionalism
    and_i_should_see_reasons_for_rejection_interested_in_future_applications
    and_i_should_see_reasons_for_rejection_offered_on_another_course
    and_i_should_see_reasons_for_rejection_other_advice_or_feeback
    and_i_should_see_reasons_for_rejection_performance_at_interview
    and_i_should_see_reasons_for_rejection_qualifications
    and_i_should_see_reasons_for_rejection_quality_of_application
    and_i_should_see_reasons_for_rejection_safeguarding_concerns
  end

private

  def reject_application_with_structured_reasons(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        course_full_y_n: 'Yes',
        candidate_behaviour_y_n: 'Yes',
        honesty_and_professionalism_y_n: 'Yes',
        performance_at_interview_y_n: 'Yes',
        qualifications_y_n: 'Yes',
        quality_of_application_y_n: 'Yes',
        safeguarding_y_n: 'Yes',
        offered_on_another_course_y_n: 'Yes',
        interested_in_future_applications_y_n: 'Yes',
        other_advice_or_feedback_y_n: 'Yes',
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_without_structured_reasons(application_choice)
    application_choice.update!(
      status: :rejected,
      rejected_at: Time.zone.now,
    )
  end

  def then_i_should_see_reasons_for_rejection_course_full
    expect(all('.govuk-heading-m')[0]).to have_content('Course full')
    expect(all('.govuk-grid-row')[0]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[0]).to have_content('2 total')
    expect(all('.govuk-grid-row')[0]).to have_content('1 this month')
  end

  def and_i_should_see_reasons_for_rejection_candidate_behaviour
    expect(all('.govuk-heading-m')[1]).to have_content('Candidate behaviour')
    expect(all('.govuk-grid-row')[1]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[1]).to have_content('2 total')
    expect(all('.govuk-grid-row')[1]).to have_content('1 this month')
  end

  def and_i_should_see_reasons_for_rejection_honesty_and_professionalism
    expect(all('.govuk-heading-m')[2]).to have_content('Honesty and professionalism')
    expect(all('.govuk-grid-row')[2]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[2]).to have_content('2 total')
    expect(all('.govuk-grid-row')[2]).to have_content('1 this month')
  end

  def and_i_should_see_reasons_for_rejection_offered_on_another_course
    expect(all('.govuk-heading-m')[3]).to have_content('Offered on another course')
    expect(all('.govuk-grid-row')[3]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[3]).to have_content('2 total')
    expect(all('.govuk-grid-row')[3]).to have_content('1 this month')
  end

  def and_i_should_see_reasons_for_rejection_performance_at_interview
    expect(all('.govuk-heading-m')[4]).to have_content('Performance at interview')
    expect(all('.govuk-grid-row')[4]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[4]).to have_content('2 total')
    expect(all('.govuk-grid-row')[4]).to have_content('1 this month')
  end

  def and_i_should_see_reasons_for_rejection_qualifications
    expect(all('.govuk-heading-m')[5]).to have_content('Qualifications')
    expect(all('.govuk-grid-row')[5]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[5]).to have_content('2 total')
    expect(all('.govuk-grid-row')[5]).to have_content('1 this month')
  end

  def and_i_should_see_reasons_for_rejection_quality_of_application
    expect(all('.govuk-heading-m')[6]).to have_content('Quality of application')
    expect(all('.govuk-grid-row')[6]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[6]).to have_content('2 total')
    expect(all('.govuk-grid-row')[6]).to have_content('1 this month')
  end

  def and_i_should_see_reasons_for_rejection_safeguarding_concerns
    expect(all('.govuk-heading-m')[7]).to have_content('Safeguarding concerns')
    expect(all('.govuk-grid-row')[7]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[7]).to have_content('2 total')
    expect(all('.govuk-grid-row')[7]).to have_content('1 this month')
  end

  def and_i_should_see_reasons_for_rejection_interested_in_future_applications
    expect(all('.govuk-heading-m')[8]).to have_content('Interested in future applications')
    expect(all('.govuk-grid-row')[8]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[8]).to have_content('2 total')
    expect(all('.govuk-grid-row')[8]).to have_content('1 this month')
  end

  def and_i_should_see_reasons_for_rejection_other_advice_or_feeback
    expect(all('.govuk-heading-m')[9]).to have_content('Other advice or feedback')
    expect(all('.govuk-grid-row')[9]).to have_content('10% of all structured rejections')
    expect(all('.govuk-grid-row')[9]).to have_content('2 total')
    expect(all('.govuk-grid-row')[9]).to have_content('1 this month')
  end
end
