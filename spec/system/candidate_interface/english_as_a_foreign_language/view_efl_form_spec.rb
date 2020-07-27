require 'rails_helper'

RSpec.feature 'View EFL form' do
  include CandidateHelper
  include EFLHelper

  scenario 'Candidate navigates to EFL form' do
    given_i_am_signed_in
    and_the_efl_feature_flag_is_active

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
    visit candidate_interface_application_form_path
    expect(page).not_to have_link efl_link_text
  end

  def then_i_can_see_the_efl_section_link
    visit candidate_interface_application_form_path
    expect(page).to have_link efl_link_text
  end

  def then_i_see_the_efl_form
    expect(page).to have_content 'Do you have an English as a foreign language qualification?'
  end
end
