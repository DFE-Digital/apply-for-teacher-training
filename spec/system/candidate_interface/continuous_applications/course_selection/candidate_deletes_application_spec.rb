require 'rails_helper'

RSpec.feature 'Candidate edits their choice section' do
  include CandidateHelper

  it 'Candidate deletes and adds additional courses' do
    given_i_am_signed_in
    and_i_have_applications

    when_i_visit_the_course_choices_page
    and_i_click_delete_a_choice
    and_i_confirm_i_want_to_delete_the_choice
    and_visit_my_application_page
    then_i_should_see_only_one_application
    and_if_i_try_manually_to_enter_on_delete_the_url_for_my_submitted_choice
    then_i_should_be_on_the_my_application_page
    and_my_submitted_choice_should_be_displayed
  end

  it 'Candidate deletes course choice from the review page' do
    given_i_am_signed_in
    and_i_have_applications

    when_i_visit_the_course_choice_review_page
    and_i_click_delete_your_draft_application
    and_i_click_cancel
    then_i_should_be_on_the_course_choice_review_page

    when_i_visit_the_course_choice_review_page
    and_i_click_delete_your_draft_application
    and_i_confirm_i_want_to_delete_the_choice
    and_visit_my_application_page
    then_i_should_see_only_one_application
    and_if_i_try_manually_to_enter_on_delete_the_url_for_my_submitted_choice
    then_i_should_be_on_the_my_application_page
    and_my_submitted_choice_should_be_displayed
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_applications
    @application_form = create(:application_form, candidate: @candidate, course_choices_completed: true)
    @first_application_choice = create(:application_choice, :unsubmitted, application_form: @application_form)
    @second_application_choice = create(:application_choice, :awaiting_provider_decision, application_form: @application_form)
  end

  def when_i_visit_the_course_choices_page
    visit candidate_interface_continuous_applications_choices_path
  end

  def and_i_click_delete_a_choice
    within "#course-choice-#{@first_application_choice.id}" do
      click_link_or_button 'Remove'
    end
  end

  def and_i_confirm_i_want_to_delete_the_choice
    click_link_or_button t('application_form.continuous_applications.courses.confirm_delete')
  end

  def then_i_should_see_only_one_application
    expect(page).to have_no_content(@first_application_choice.current_course.name_and_code)
  end

  def and_visit_my_application_page
    visit candidate_interface_continuous_applications_details_path
  end

  def and_if_i_try_manually_to_enter_on_delete_the_url_for_my_submitted_choice
    visit candidate_interface_continuous_applications_confirm_destroy_course_choice_path(@second_application_choice.id)
  end

  def then_i_should_be_on_the_my_application_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_choices_path)
  end

  def and_my_submitted_choice_should_be_displayed
    expect(page).to have_content(@second_application_choice.current_course.name_and_code)
  end

  def when_i_visit_the_course_choice_review_page
    visit candidate_interface_continuous_applications_course_review_path(@first_application_choice.id)
  end

  def and_i_click_delete_your_draft_application
    click_link_or_button 'delete your draft application'
  end

  def and_i_click_cancel
    click_link_or_button 'Cancel'
  end

  def then_i_should_be_on_the_course_choice_review_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_course_review_path(@first_application_choice.id))
  end
end
