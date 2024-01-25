require 'rails_helper'

RSpec.feature 'Selecting a course' do
  include CandidateHelper

  it 'Candidate selects a course they have already applied to when editing' do
    given_i_am_signed_in
    and_there_are_course_options
    and_i_have_two_applications

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_click_to_edit_the_first_application
    and_i_click_to_change_course
    and_i_choose_the_course_on_the_second_application
    then_i_should_be_on_the_application_choice_duplicate_page

    when_i_click_back
    then_i_should_be_on_the_course_choice_page
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    create_and_sign_in_candidate(candidate: @candidate)
  end

  def and_i_click_to_change_course
    click_change_link 'course for Primary (2XT2)'
  end

  def and_i_choose_the_course_on_the_second_application
    choose 'Secondary (2XP2)'
    click_link_or_button t('continue')
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course_one = create(:course, :open_on_apply, name: 'Primary', code: '2XT2', provider: @provider)
    @course_two = create(:course, :open_on_apply, name: 'Secondary', code: '2XP2', provider: @provider)
    create(:course_option, course: @course_one)
    create(:course_option, course: @course_two)
  end

  def then_i_should_be_on_the_application_choice_duplicate_page
    expect(page).to have_content('You already have an application for Secondary (2XP2) at Gorse SCITT')
  end

  def and_i_have_two_applications
    @application_one = create(:application_choice, :unsubmitted, course_option: @course_one.course_options.first, application_form: @candidate.current_application)
    @application_two = create(:application_choice, :unsubmitted, course_option: @course_two.course_options.first, application_form: @candidate.current_application)
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_course_choices
    click_link_or_button 'Your application'
  end

  def and_i_click_to_edit_the_first_application
    within("div[data-qa='application-choice-#{@application_one.id}']") do
      click_link_or_button 'Continue application'
    end
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def then_i_should_be_on_the_course_choice_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_which_course_are_you_applying_to_path(@provider))
  end
end
