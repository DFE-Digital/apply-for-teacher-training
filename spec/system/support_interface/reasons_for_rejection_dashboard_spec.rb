require 'rails_helper'

RSpec.feature 'Structured reasons for rejection dashboard' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2020, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'View structured reasons for rejection', with_audited: true do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_page_in_support
    then_i_can_see_reasons_for_rejection_dashboard_links_for_two_cycles
    and_i_click_on_the_reasons_for_rejection_dashboard_link_for_the_current_cycle

    then_i_should_see_reasons_for_rejection_dashboard
    and_i_should_see_sub_reasons_for_rejection

    when_i_click_on_a_top_level_reason
    then_i_can_see_a_list_of_applications_for_that_reason

    when_i_visit_the_performance_page_in_support
    and_i_click_on_the_reasons_for_rejection_dashboard_link_for_the_current_cycle
    and_i_click_on_a_sub_reason
    then_i_can_see_a_list_of_applications_for_that_sub_reason
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    allow(CycleTimetable).to receive(:apply_opens).and_return(60.days.ago)
    @application_choice1 = create(:application_choice, :awaiting_provider_decision)
    @application_choice2 = create(:application_choice, :awaiting_provider_decision)
    @application_choice3 = create(:application_choice, :awaiting_provider_decision)
    @application_choice4 = create(:application_choice, :awaiting_provider_decision)
    @application_choice5 = create(:application_choice, :awaiting_provider_decision)
    @application_choice6 = create(:application_choice, :awaiting_provider_decision)

    Timecop.freeze(@today - 40.days) do
      reject_application_for_candidate_behaviour_qualifications_and_safeguarding(@application_choice1)
      reject_application_for_candidate_behaviour_and_qualifications(@application_choice2)
      reject_application_for_candidate_behaviour(@application_choice3)
    end

    Timecop.freeze(@today) do
      reject_application_for_candidate_behaviour_qualifications_and_safeguarding(@application_choice4)
      reject_application_for_candidate_behaviour(@application_choice5)
      reject_application_without_structured_reasons(@application_choice6)
    end
  end

  def when_i_visit_the_performance_page_in_support
    visit support_interface_performance_path
  end

  def then_i_can_see_reasons_for_rejection_dashboard_links_for_two_cycles
    expect(page).to have_link("#{RecruitmentCycle.cycle_name} (starts #{RecruitmentCycle.current_year}) - current")
    expect(page).to have_link("#{RecruitmentCycle.cycle_name(RecruitmentCycle.previous_year)} (starts #{RecruitmentCycle.previous_year})")
  end

  def and_i_click_on_the_reasons_for_rejection_dashboard_link_for_the_current_cycle
    click_on "#{RecruitmentCycle.cycle_name} (starts #{RecruitmentCycle.current_year}) - current"
  end

  def then_i_should_see_reasons_for_rejection_dashboard
    then_i_should_see_reasons_for_rejection_title_and_details
    and_i_should_see_reasons_for_rejection_candidate_behaviour
    and_i_should_see_reasons_for_rejection_quality_of_application
    and_i_should_see_reasons_for_rejection_qualifications
    and_i_should_see_reasons_for_rejection_course_full
    and_i_should_see_reasons_for_rejection_offered_on_another_course
    and_i_should_see_reasons_for_rejection_honesty_and_professionalism
    and_i_should_see_reasons_for_rejection_performance_at_interview
    and_i_should_see_reasons_for_rejection_safeguarding_concerns
    and_i_should_see_reasons_for_rejection_cannot_sponsor_visa
    and_i_should_see_reasons_for_rejection_other_advice_or_feedback
  end

  def and_i_should_see_sub_reasons_for_rejection
    and_i_should_see_sub_reasons_for_rejection_due_to_qualifications
    and_i_should_see_sub_reasons_for_rejection_due_to_safeguarding
    and_i_should_see_sub_reasons_for_rejection_due_to_candidate_behaviour
  end

private

  def reject_application_for_candidate_behaviour_qualifications_and_safeguarding(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        course_full_y_n: 'No',
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[didnt_reply_to_interview_offer],
        honesty_and_professionalism_y_n: 'No',
        performance_at_interview_y_n: 'No',
        qualifications_y_n: 'Yes',
        qualifications_which_qualifications: %w[no_maths_gcse no_degree no_phd],
        quality_of_application_y_n: 'No',
        safeguarding_y_n: 'Yes',
        safeguarding_concerns: %w[other],
        offered_on_another_course_y_n: 'No',
        cannot_sponsor_visa_y_n: 'No',
        interested_in_future_applications_y_n: 'No',
        other_advice_or_feedback_y_n: 'No',
        fashion_sense_y_n: 'Yes',
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_for_candidate_behaviour_and_qualifications(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        course_full_y_n: 'No',
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[didnt_attend_interview],
        honesty_and_professionalism_y_n: 'No',
        performance_at_interview_y_n: 'No',
        qualifications_y_n: 'Yes',
        qualifications_which_qualifications: %w[no_english_gcse other],
        quality_of_application_y_n: 'No',
        safeguarding_y_n: 'No',
        cannot_sponsor_visa_y_n: 'No',
        offered_on_another_course_y_n: 'No',
        interested_in_future_applications_y_n: 'No',
        other_advice_or_feedback_y_n: 'No',
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_for_candidate_behaviour(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        course_full_y_n: 'No',
        candidate_behaviour_y_n: 'Yes',
        honesty_and_professionalism_y_n: 'No',
        performance_at_interview_y_n: 'No',
        qualifications_y_n: 'No',
        quality_of_application_y_n: 'No',
        safeguarding_y_n: 'No',
        cannot_sponsor_visa_y_n: 'No',
        offered_on_another_course_y_n: 'No',
        interested_in_future_applications_y_n: 'No',
        other_advice_or_feedback_y_n: 'No',
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

  def then_i_should_see_reasons_for_rejection_title_and_details
    expect(page).to have_content('2020 to 2021 (starts 2021) - current Structured reasons for rejection')
    expect(page).to have_content('The report does not include rejections made through the API.')
    expect(page).to have_content('Since users can choose more than one reason for rejection, the percentages for all the categories will not add up to 100%.')
  end

  def and_i_should_see_reasons_for_rejection_course_full
    within '#course-full' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 rejections included this category')
      expect(page).to have_content('0 of 2 rejections in December included this category')
    end
  end

  def and_i_should_see_reasons_for_rejection_candidate_behaviour
    within '#candidate-behaviour' do
      expect(page).to have_content('100%')
      expect(page).to have_content('5 of 5 rejections included this category')
      expect(page).to have_content('2 of 2 rejections in December included this category')
    end
  end

  def and_i_should_see_reasons_for_rejection_honesty_and_professionalism
    within '#honesty-and-professionalism' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 rejections included this category')
      expect(page).to have_content('0 of 2 rejections in December included this category')
    end
  end

  def and_i_should_see_reasons_for_rejection_offered_on_another_course
    within '#offered-on-another-course' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 rejections included this category')
      expect(page).to have_content('0 of 2 rejections in December included this category')
    end
  end

  def and_i_should_see_reasons_for_rejection_performance_at_interview
    within '#performance-at-interview' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 rejections included this category')
      expect(page).to have_content('0 of 2 rejections in December included this category')
    end
  end

  def and_i_should_see_reasons_for_rejection_qualifications
    within '#qualifications' do
      expect(page).to have_content('60%')
      expect(page).to have_content('3 of 5 rejections included this category')
      expect(page).to have_content('50%')
      expect(page).to have_content('1 of 2 rejections in December included this category')
    end
  end

  def and_i_should_see_reasons_for_rejection_quality_of_application
    within '#quality-of-application' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 rejections included this category')
      expect(page).to have_content('0 of 2 rejections in December included this category')
    end
  end

  def and_i_should_see_reasons_for_rejection_safeguarding_concerns
    within '#safeguarding' do
      expect(page).to have_content('40%')
      expect(page).to have_content('2 of 5 rejections included this category')
      expect(page).to have_content('50%')
      expect(page).to have_content('1 of 2 rejections in December included this category')
    end
  end

  def and_i_should_see_reasons_for_rejection_other_advice_or_feedback
    within '#additional-advice-or-feedback' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 rejections included this category')
      expect(page).to have_content('0 of 2 rejections in December included this category')
    end
  end

  def and_i_should_see_sub_reasons_for_rejection_due_to_qualifications
    within '#qualifications' do
      expect(page).to have_content('No Maths GCSE grade 4 (C) or above, or valid equivalent 40% 2 of 5 66.67% 2 of 3 50% 1 of 2 100% 1 of 1')
      expect(page).to have_content('No English GCSE grade 4 (C) or above, or valid equivalent 20% 1 of 5 33.33% 1 of 3 0% 0 of 2 0% 0 of 1')
      expect(page).to have_content('Other 20% 1 of 5 33.33% 1 of 3 0% 0 of 2 0% 0 of 1')
      expect(page).to have_content('No degree 40% 2 of 5 66.67% 2 of 3 50% 1 of 2 100% 1 of 1')
      expect(page).to have_content('No Science GCSE grade 4 (C) or above, or valid equivalent (for primary applicants) 0% 0 of 5 0% 0 of 3 0% 0 of 2 0% 0 of 1')
    end
  end

  def and_i_should_see_sub_reasons_for_rejection_due_to_safeguarding
    within '#safeguarding' do
      expect(page).to have_content('Information disclosed by candidate makes them unsuitable to work with children 0% 0 of 5 0% 0 of 2 0% 0 of 2 0% 0 of 1')
      expect(page).to have_content('Information revealed by our vetting process makes the candidate unsuitable to work with children 0% 0 of 5 0% 0 of 2 0% 0 of 2 0% 0 of 1')
      expect(page).to have_content('Other 40% 2 of 5 100% 2 of 2 50% 1 of 2 100% 1 of 1')
    end
  end

  def and_i_should_see_sub_reasons_for_rejection_due_to_candidate_behaviour
    within '#candidate-behaviour' do
      expect(page).to have_content('Didn’t reply to our interview offer 40% 2 of 5 40% 2 of 5 50% 1 of 2 50% 1 of 2')
      expect(page).to have_content('Didn’t attend interview 20% 1 of 5 20% 1 of 5 0% 0 of 2 0% 0 of 2')
      expect(page).to have_content('Other 0% 0 of 5 0% 0 of 5 0% 0 of 2 0% 0 of 2')
    end
  end

  def and_i_should_see_reasons_for_rejection_cannot_sponsor_visa
    within '#cannot-sponsor-visa' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 rejections included this category')
      expect(page).to have_content('0 of 2 rejections in December included this category')
    end
  end

  def when_i_click_on_a_top_level_reason
    click_on 'Candidate behaviour'
  end

  def then_i_can_see_a_list_of_applications_for_that_reason
    expect(page).to have_current_path(
      support_interface_reasons_for_rejection_application_choices_path(
        structured_rejection_reasons: { candidate_behaviour_y_n: 'Yes' },
        recruitment_cycle_year: RecruitmentCycle.current_year,
      ),
    )
    expect(page).to have_css('span.govuk-caption-l', text: '2020 to 2021 (starts 2021) - current')
    expect(page).to have_css('h1', text: 'Candidate behaviour')
    [
      @application_choice1,
      @application_choice2,
      @application_choice3,
      @application_choice4,
      @application_choice5,
    ].each { |application_choice| expect(page).to have_link("##{application_choice.id}") }
    expect(page).not_to have_link("##{@application_choice6.id}")

    within "#application-choice-section-#{@application_choice1.id}" do
      expect(page).to have_content('Safeguarding')
      expect(page).to have_content("Qualifications\nNo Maths GCSE grade 4 (C) or above, or valid equivalentNo degree")
      expect(page).to have_content('Candidate behaviour')
      expect(page).to have_content('Didn’t reply to our interview offer')
      expect(page).not_to have_content('fashion_sense')
      expect(page).not_to have_content('no_phd')
    end
    within "#application-choice-section-#{@application_choice2.id}" do
      expect(page).not_to have_content('Safeguarding')
      expect(page).to have_content("Qualifications\nNo English GCSE grade 4 (C) or above, or valid equivalentOther")
      expect(page).to have_content('Candidate behaviour')
      expect(page).to have_content('Didn’t attend interview')
    end
    within "#application-choice-section-#{@application_choice3.id}" do
      expect(page).not_to have_content('Safeguarding')
      expect(page).not_to have_content('Qualifications')
      expect(page).to have_content('Candidate behaviour')
    end
  end

  def and_i_click_on_a_sub_reason
    click_on 'Didn’t attend interview'
  end

  def then_i_can_see_a_list_of_applications_for_that_sub_reason
    expect(page).to have_current_path(
      support_interface_reasons_for_rejection_application_choices_path(
        structured_rejection_reasons: { candidate_behaviour_what_did_the_candidate_do: 'didnt_attend_interview' },
        recruitment_cycle_year: RecruitmentCycle.current_year,
      ),
    )

    expect(page).to have_css('span.govuk-caption-l', text: '2020 to 2021 (starts 2021) - current')
    expect(page).to have_css('h1', text: 'Candidate behaviour - Didn’t attend interview')

    [
      @application_choice1,
      @application_choice3,
      @application_choice4,
      @application_choice5,
      @application_choice6,
    ].each { |application_choice| expect(page).not_to have_link("##{application_choice.id}") }
    expect(page).to have_link("##{@application_choice2.id}")

    within "#application-choice-section-#{@application_choice2.id}" do
      expect(page).not_to have_content('Safeguarding')
      expect(page).to have_content("Qualifications\nNo English GCSE grade 4 (C) or above, or valid equivalentOther")
      expect(page).to have_content('Candidate behaviour')
      expect(page).to have_content('Didn’t attend interview')
    end
  end
end
