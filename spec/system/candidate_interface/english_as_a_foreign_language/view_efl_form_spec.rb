require 'rails_helper'

RSpec.feature 'View EFL form' do
  include CandidateHelper

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

  def and_the_efl_feature_flag_is_active
    FeatureFlag.activate(:efl_section)
  end

  def then_i_cannot_see_the_efl_section_link
    expect(page).not_to have_link efl_link_text
  end

  def when_i_declare_a_non_english_nationality
    visit candidate_interface_application_form_path
    click_link 'Personal details'
    candidate_fills_in_personal_details
    click_link 'Personal details'
    click_link 'Change nationality'
    select 'Hong Konger', from: 'Nationality'
    select 'Pakistani', from: 'Second nationality'
    click_button 'Save and continue'
    click_button 'Continue'
  end

  def then_i_can_see_the_efl_section_link
    expect(page).to have_link efl_link_text
  end

  def when_i_click_on_the_efl_section_link
    click_link efl_link_text
  end

  def then_i_see_the_efl_form
    expect(page).to have_content 'Do you have an English as a foreign language qualification?'
  end

private

  def efl_link_text
    'English as a foreign language'
  end
end
