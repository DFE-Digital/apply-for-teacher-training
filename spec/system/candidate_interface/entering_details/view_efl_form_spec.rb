require 'rails_helper'

RSpec.feature 'View EFL form' do
  include CandidateHelper
  include EFLHelper

  scenario 'Candidate navigates to EFL form' do
    given_i_am_signed_in

    then_i_cannot_see_the_efl_section_link
    when_i_declare_a_non_english_nationality
    then_i_can_see_the_efl_section_link

    when_i_click_on_the_efl_section_link
    then_i_see_the_efl_form
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def then_i_cannot_see_the_efl_section_link
    visit candidate_interface_continuous_applications_details_path
    expect(page).to have_no_link efl_link_text
  end

  def then_i_can_see_the_efl_section_link
    visit candidate_interface_continuous_applications_details_path
    expect(page).to have_link efl_link_text
  end

  def then_i_see_the_efl_form
    expect(page).to have_content 'Have you done an English as a foreign language assessment?'
  end
end
