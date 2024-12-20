require 'rails_helper'

RSpec.describe 'Carry over next cycle with cycle switcher', time: CycleTimetableHelper.mid_cycle do
  include CandidateHelper

  it 'Candidate can submit in next cycle with cycle switcher after apply opens' do
    given_i_am_signed_in_as_a_candidate
    when_i_have_an_unsubmitted_application_without_a_course
    and_the_cycle_switcher_set_to_apply_opens

    when_i_sign_in_again
    and_i_visit_the_application_dashboard
    then_i_cannot_submit_my_application
    and_i_am_redirected_to_the_carry_over_interstitial

    when_i_click_on_continue
    then_i_see_my_details

    when_i_view_referees
    then_i_can_see_the_referees_i_previously_added
    and_i_can_complete_the_references_section
    and_i_can_complete_the_equality_and_diversity_section

    when_i_view_courses
    then_i_can_see_that_i_need_to_select_courses
    then_i_can_see_that_i_need_to_select_courses

    and_i_select_a_course
    and_my_application_is_awaiting_provider_decision
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsubmitted_application_without_a_course
    @application_form = create(
      :completed_application_form,
      :with_gcses,
      :with_degree,
      date_of_birth: Date.new(1964, 9, 1),
      submitted_at: nil,
      candidate: @candidate,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
      references_count: 0,
    )
    @first_reference = create(
      :reference,
      feedback_status: :not_requested_yet,
      application_form: @application_form,
    )
    @second_reference = create(
      :reference,
      feedback_status: :feedback_requested,
      application_form: @application_form,
    )
  end

  def and_the_cycle_switcher_set_to_apply_opens
    current_year = RecruitmentCycle.current_year
    expect {
      SiteSetting.set(name: 'cycle_schedule', value: 'today_is_after_apply_opens')
    }.to change { RecruitmentCycle.current_year }.from(current_year).to(current_year + 1)
  end

  def when_i_sign_in_again
    logout
    login_as(@candidate)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_choices_path
  end

  def then_i_cannot_submit_my_application
    expect(page).to have_no_link('Check and submit your application')
  end

  def and_i_am_redirected_to_the_carry_over_interstitial
    expect(page).to have_current_path candidate_interface_start_carry_over_path
  end

  def when_i_click_on_continue
    click_link_or_button 'Continue'
  end

  def then_i_see_my_details
    expect(page).to have_title 'Your details'
  end

  def then_i_see_my_applications
    expect(page).to have_title('Your applications')
  end

  def when_i_view_referees
    click_link_or_button 'References to be requested if you accept an offer'
  end

  def then_i_can_see_the_referees_i_previously_added
    expect(page).to have_css('h3', text: @first_reference.name)
    expect(page).to have_css('h3', text: @second_reference.name)
  end

  def and_i_can_complete_the_references_section
    choose 'Yes, I have completed this section'
    click_on 'Continue'
  end

  def and_i_can_complete_the_equality_and_diversity_section
    click_on 'Equality and diversity questions'
    candidate_fills_in_diversity_information
  end

  def when_i_view_courses
    click_on 'Your applications'
  end

  def then_i_can_see_that_i_need_to_select_courses
    expect(page).to have_content('You can add up to 4 applications at a time')
  end

  def and_i_select_a_course
    given_courses_exist
    click_link_or_button 'Add application'

    choose 'Yes, I know where I want to apply'
    click_link_or_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_link_or_button 'Continue'

    choose 'Primary (2XT2)'
    click_link_or_button 'Continue'

    click_on 'Review application'
    click_on 'Confirm and submit application'

    expect(page).to have_content('You can add 3 more applications')
  end

  def and_my_application_is_awaiting_provider_decision
    application_choice = @candidate.current_application.application_choices.first
    expect(application_choice.status).to eq('awaiting_provider_decision')
  end
end
