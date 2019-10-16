require 'rails_helper'
require_relative 'helpers/candidate_helper'

RSpec.feature 'Candidate submit the application' do
  include CandidateHelper

  scenario 'Candidate with personal details' do
    given_i_am_signed_in
    and_i_filled_in_personal_details_and_review_my_application

    and_i_confirm_my_application

    then_i_can_see_the_submit_application_page
  end

  def then_i_can_see_the_submit_application_page
    expect(page).to have_content 'Submit application'
  end

  def and_i_confirm_my_application
    click_link 'Continue'
  end

  def and_i_filled_in_personal_details_and_review_my_application
    and_i_filled_in_personal_details
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_can_review_my_application
    expect(page).to have_content 'Review your application'
  end

  def then_i_can_see_the_personal_my_details
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '6 April 1937'
    expect(page).to have_content 'British and American'
    expect(page).to have_content "I'm great at Galactic Basic so English is a piece of cake"
  end
end
