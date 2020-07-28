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

    # when_i_choose_not_to_fill_in_the_equality_and_diversity_survey
    # and_i_choose_not_to_add_further_information
    # and_i_submit_the_application
    # then_i_can_see_my_application_has_been_successfully_submitted
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

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

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

  # def when_i_choose_not_to_fill_in_the_equality_and_diversity_survey
  #   click_link 'Continue without completing questionnaire'
  # end

  # def and_i_choose_not_to_add_further_information
  #   choose 'No'
  # end

  # def and_i_submit_the_application
  #   click_button 'Submit application'
  # end

  # def then_i_can_see_my_application_has_been_successfully_submitted
  #   expect(page).to have_content 'Application successfully submitted'
  #   expect(page).to have_content 'Your training provider will be in touch with you if they want to arrange an interview.'
  # end

  # def and_i_can_see_my_support_ref
  #   support_ref = page.find('span#application-ref').text
  #   expect(support_ref).not_to be_empty
  # end
end
