require 'rails_helper'

RSpec.feature 'Reasons for rejection sub-reasons' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2020, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'View reasons for rejection sub-reasons' do
    given_i_am_a_support_user
    and_there_are_candidates_and_rejected_applications_in_the_system

    when_i_visit_the_reasons_for_rejection_sub_reasons_page

    then_i_should_see_counts_for_rejection_sub_reasons
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def create_application
    application_form = create(:application_form)
    create(:application_choice, application_form: application_form)
  end

  def reject_application(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[didnt_reply_to_interview_offer],
        quality_of_application_y_n: 'Yes',
        quality_of_application_which_parts_needed_improvement: %w[personal_statement],
        qualifications_y_n: 'Yes',
        qualifications_which_qualifications: %w[no_maths_gcse],
        performance_at_interview_y_n: 'No',
        offered_on_another_course_y_n: 'No',
        honesty_and_professionalism_y_n: 'Yes',
        honesty_and_professionalism_concerns: %w[other],
        safeguarding_concerns: %w[candidate_disclosed_information],
        why_are_you_rejecting_this_application: 'So many reasons',
        other_advice_or_feedback_y_n: 'Yes',
        other_advice_or_feedback_details: 'Try again soon',
        interested_in_future_applications_y_n: 'Yes',
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_all_reasons(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other didnt_reply_to_interview_offer didnt_attend_interview],
        quality_of_application_y_n: 'Yes',
        quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge other],
        qualifications_y_n: 'Yes',
        qualifications_which_qualifications: %w[no_maths_gcse no_english_gcse no_science_gcse no_degree other],
        performance_at_interview_y_n: 'No',
        offered_on_another_course_y_n: 'No',
        honesty_and_professionalism_y_n: 'Yes',
        honesty_and_professionalism_concerns: %w[information_false_or_inaccurate plagiarism references other],
        safeguarding_concerns: %w[candidate_disclosed_information vetting_disclosed_information other],
        why_are_you_rejecting_this_application: 'So many reasons',
        other_advice_or_feedback_y_n: 'Yes',
        other_advice_or_feedback_details: 'Try again soon',
        interested_in_future_applications_y_n: 'Yes',
      },
      rejected_at: Time.zone.now,
    )
  end

  def and_there_are_candidates_and_rejected_applications_in_the_system
    Timecop.freeze(@today - 50.days) do
      @application_choice1 = create_application
    end
    Timecop.freeze(@today - 40.days) do
      @application_choice2 = create_application
      reject_application(@application_choice1)
    end
    Timecop.freeze(@today - 21.days) do
      @application_choice3 = create_application
      reject_application(@application_choice2)
    end
    Timecop.freeze(@today - 2.days) do
      reject_application_all_reasons(@application_choice3)
    end
  end

  def when_i_visit_the_reasons_for_rejection_sub_reasons_page
    visit support_interface_reasons_for_rejection_sub_reasons_path
  end

  def then_i_should_see_counts_for_rejection_sub_reasons
    expect(page).to have_content("Quality of application: Personal statement\n3 2")
    expect(page).to have_content("Quality of application: Other\n1 1")
    expect(page).to have_content("Quality of application: Subject knowledge\n1 1")
  end
end
