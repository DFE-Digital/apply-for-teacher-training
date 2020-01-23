require 'rails_helper'

RSpec.feature 'See candidates' do
  include DfESignInHelpers

  scenario 'Support agent visits the list of candidates and selects one who has never signed in' do
    given_i_am_a_support_user
    and_there_are_candidates_in_the_system
    and_i_visit_the_support_candidate_page
    then_i_should_see_the_candidates

    when_i_click_on_a_candidate_with_no_applications
    then_i_see_the_candidate_details

    and_i_visit_the_support_candidate_page
    when_i_click_on_a_candidate_with_one_application
    then_i_should_see_a_summary_of_the_application
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_in_the_system
    @candidate_with_sign_up_email_bounced = create(:candidate, sign_up_email_bounced: true)
    @candidate_who_has_signed_up_but_not_signed_in = create(:candidate)
    @candidate_with_a_submitted_application = create(:application_form).candidate
  end

  def and_i_visit_the_support_candidate_page
    visit support_interface_candidates_path
  end

  def then_i_should_see_the_candidates
    within("[data-qa='candidate-#{@candidate_with_sign_up_email_bounced.id}']") do
      expect(page).to have_content @candidate_with_sign_up_email_bounced.email_address
      expect(page).to have_content('Sign up email bounced')
    end
    within("[data-qa='candidate-#{@candidate_who_has_signed_up_but_not_signed_in.id}']") do
      expect(page).to have_content @candidate_who_has_signed_up_but_not_signed_in.email_address
      expect(page).to have_content('Never signed in')
    end
    expect(page).to have_content @candidate_with_a_submitted_application.email_address
  end

  def when_i_click_on_a_candidate_with_no_applications
    click_link @candidate_who_has_signed_up_but_not_signed_in.email_address
  end

  def then_i_see_the_candidate_details
    expect(page).to have_title(@candidate_who_has_signed_up_but_not_signed_in.id)
  end

  def when_i_click_on_a_candidate_with_one_application
    click_link @candidate_with_a_submitted_application.email_address
  end

  def then_i_should_see_a_summary_of_the_application
    application = @candidate_with_a_submitted_application.application_forms.first
    within '[data-qa="application-summary"]' do
      expect(page).to have_content application.support_reference
    end
  end
end
