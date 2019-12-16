require 'rails_helper'

RSpec.feature 'See candidates' do
  include DfESignInHelpers

  scenario 'Support agent visits the list of candidates' do
    given_i_am_a_support_user
    and_there_are_candidates_in_the_system
    and_i_visit_the_support_candidate_page
    then_i_should_see_the_candidates
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_in_the_system
    @candidate_who_has_signed_up_but_not_signed_in = create(:candidate)
    @candidate_with_a_submitted_application = create(:application_form).candidate
  end

  def and_i_visit_the_support_candidate_page
    visit support_interface_candidates_path
  end

  def then_i_should_see_the_candidates
    expect(page).to have_content @candidate_who_has_signed_up_but_not_signed_in.email_address
    expect(page).to have_content @candidate_with_a_submitted_application.email_address
  end
end
