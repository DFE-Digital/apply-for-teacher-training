require 'rails_helper'

RSpec.feature 'Candidate attempts to submit the application after the end-of-cycle cutoff' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Date.new(2020, 8, 30)) { example.run }
  end

  scenario 'Candidate with an unsubmitted application between cycles' do
    given_i_am_signed_in

    when_i_have_completed_my_application

    and_i_review_my_application

    then_i_should_see_all_sections_are_complete
    and_i_cannot_confirm_my_application
    and_i_cannot_confirm_my_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
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

  def and_i_cannot_confirm_my_application
    expect(page).not_to have_link 'Check and submit your application'
  end

  def and_i_cannot_confirm_my_application
    expect(page).not_to have_link 'Continue'
  end
end
