require 'rails_helper'

RSpec.feature 'Candidate reviews the answers' do
  scenario 'Logged in candidate with no personal details' do
    given_i_am_signed_in
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
    then_i_can_review_my_application
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def given_i_am_signed_in
    candidate = create(:candidate)
    login_as(candidate)
  end

  def then_i_can_review_my_application
    expect(page).to have_content 'Review your application'
  end
end
