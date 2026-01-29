require 'rails_helper'

RSpec.describe 'Carry over next cycle with cycle switcher' do
  include CandidateHelper

  context 'candidate preferences feature flag is activated' do
    it 'candidate can submit in next cycle after dismissing candidate preferences' do
      given_i_am_signed_in_with_one_login
      when_i_have_an_unsubmitted_application_without_a_course
      and_the_cycle_switcher_set_to_apply_opens

      when_i_sign_in_again
      and_i_navigate_to_my_details
      when_i_view_referees
      then_i_can_see_the_referees_i_previously_added
      and_i_can_complete_the_references_section
      and_i_can_complete_the_equality_and_diversity_section

      when_i_view_courses
      then_i_can_see_that_i_need_to_select_courses

      and_i_select_a_course_and_dismiss_candidate_preferences
      and_my_application_is_awaiting_provider_decision
    end
  end

  context 'candidate preferences feature flag is deactivated' do
    it 'Candidate can submit in next cycle with cycle switcher after apply opens', time: mid_cycle do
      given_i_am_signed_in_with_one_login
      when_i_have_an_unsubmitted_application_without_a_course
      and_the_cycle_switcher_set_to_apply_opens

      when_i_sign_in_again
      and_i_navigate_to_my_details
      then_i_see_my_details

      when_i_view_referees
      then_i_can_see_the_referees_i_previously_added
      and_i_can_complete_the_references_section
      and_i_can_complete_the_equality_and_diversity_section

      when_i_view_courses
      then_i_can_see_that_i_need_to_select_courses

      and_i_select_a_course
      and_my_application_is_awaiting_provider_decision
    end
  end

  def when_i_have_an_unsubmitted_application_without_a_course
    @application_form = create(
      :completed_application_form,
      :with_gcses,
      :with_degree,
      date_of_birth: Date.new(1964, 9, 1),
      submitted_at: nil,
      candidate: @current_candidate,
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
    application_timetable = @application_form.recruitment_cycle_timetable
    application_timetable.update(apply_deadline_at: 1.hour.ago)

    next_timetable = application_timetable.relative_next_timetable
    next_timetable.update(find_opens_at: 1.week.ago, apply_opens_at: 1.day.ago)
  end

  def when_i_sign_in_again
    click_link_or_button 'Sign out'
    i_am_signed_in_with_one_login
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_choices_path
  end

  def and_i_navigate_to_my_details
    click_on "Your details"
  end

  def then_i_cannot_submit_my_application
    expect(page).to have_no_link('Check and submit your application')
  end

  def then_i_see_the_carry_over_content
    expect(page).to have_current_path candidate_interface_application_choices_path

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      expect(page).to have_button 'Continue'
    end
  end
  alias_method :and_i_can_see_the_carry_over_content, :then_i_see_the_carry_over_content

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
    expect(page).to have_css('h2', text: @first_reference.name)
    expect(page).to have_css('h2', text: @second_reference.name)
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
    expect(page).to have_content('You can have up to 4 applications in progress at any time.')
  end

  def and_i_select_a_course
    given_courses_exist
    and_those_courses_are_for_this_year
    click_link_or_button 'Add application'

    choose 'Yes, I know where I want to apply'
    click_link_or_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_link_or_button 'Continue'

    choose 'Primary (2XT2)'
    click_link_or_button 'Continue'

    click_on 'Review application'
    click_on 'Confirm and submit application'

    expect(page).to have_content(
      'Do you want to be invited to similar courses?',
    )
    choose 'No'
    click_on 'Continue'

    click_on 'Your applications'

    expect(page).to have_content('You can submit 3 more applications')
  end

  def and_i_select_a_course_and_dismiss_candidate_preferences
    given_courses_exist
    and_those_courses_are_for_this_year
    click_link_or_button 'Add application'

    choose 'Yes, I know where I want to apply'
    click_link_or_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_link_or_button 'Continue'

    choose 'Primary (2XT2)'
    click_link_or_button 'Continue'

    click_on 'Review application'
    click_on 'Confirm and submit application'
    click_on 'Continue'
    choose 'No'
    click_on 'Continue'
    click_on 'Your applications'

    expect(page).to have_content('You can submit 3 more applications')
  end

  def and_those_courses_are_for_this_year
    @provider.courses.update_all(recruitment_cycle_year: current_year)
  end

  def and_my_application_is_awaiting_provider_decision
    application_choice = @current_candidate.current_application.application_choices.first
    expect(application_choice.status).to eq('awaiting_provider_decision')
  end
end
