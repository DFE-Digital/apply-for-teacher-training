require 'rails_helper'

RSpec.feature 'Candidate attempts to submit the application after the end-of-cycle cutoff' do
  include CandidateHelper

  scenario 'Candidate with a completed application' do
    given_i_am_signed_in

    when_i_have_completed_my_application

    and_i_review_my_application

    then_i_should_see_all_sections_are_complete

    given_stop_new_applications_feature_flag_is_on
    and_i_confirm_my_application
    then_i_am_redirected_to_the_application_page
    and_i_see_an_error_message_telling_me_that_applications_are_closed

    when_i_review_my_application_again
    then_i_do_not_see_the_continue_button
    and_i_do_see_a_banner_telling_me_that_applications_are_closed

    when_i_visit_the_application_form_page
    and_i_click_on_course_choices
    then_i_do_not_see_an_add_another_course_button

    when_i_visit_the_choose_course_page
    then_i_am_redirected_to_the_application_page
    and_i_see_an_error_message_telling_me_that_applications_are_closed
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_stop_new_applications_feature_flag_is_on
    FeatureFlag.activate(:stop_new_applications)
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  alias_method :when_i_review_my_application_again, :and_i_review_my_application

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  alias_method :when_i_visit_the_application_form_page, :and_i_visit_the_application_form_page

  def then_i_should_see_all_sections_are_complete
    CandidateHelper::APPLICATION_FORM_SECTIONS.each do |section|
      expect(page).not_to have_selector "[aria-describedby='missing-#{section}']"
    end
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def and_i_confirm_my_application
    click_link 'Continue'
  end

  def then_i_am_redirected_to_the_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def and_i_see_an_error_message_telling_me_that_applications_are_closed
    expect(page).to have_content 'New applications are now closed for 2020'
  end

  def then_i_do_not_see_the_continue_button
    expect(page).not_to have_link 'Continue'
  end

  def and_i_do_see_a_banner_telling_me_that_applications_are_closed
    expect(page).to have_content 'The 2020 recruitment cycle is now closed for new applications'
  end

  def and_i_click_on_course_choices
    click_link 'Course choices'
  end

  def then_i_do_not_see_an_add_another_course_button
    expect(page).not_to have_link 'Add another course'
  end

  def when_i_visit_the_choose_course_page
    visit candidate_interface_course_choices_choose_path
  end
end
