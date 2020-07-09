require 'rails_helper'

RSpec.feature 'Add IELTS qualification' do
  include CandidateHelper

  scenario 'Candidate completes EFL section with details of their IELTS' do
    given_i_am_signed_in
    and_the_efl_feature_flag_is_active
    and_i_declare_a_non_english_speaking_nationality
    and_i_click_on_the_efl_section_link

    and_i_select_the_options_for_ielts
    when_i_provide_my_ielts_details
    then_i_have_completed_the_efl_section
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_efl_feature_flag_is_active
    FeatureFlag.activate(:efl_section)
  end

  def and_i_declare_a_non_english_speaking_nationality
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

  def and_i_click_on_the_efl_section_link
    click_link efl_link_text
  end

  def and_i_select_the_options_for_ielts
    choose 'Yes'
    click_button 'Continue'
    choose 'International English Language Testing System'
    click_button 'Continue'
  end

  def when_i_provide_my_ielts_details
    fill_in 'Test report form', with: '123456'
    fill_in 'Overall band score', with: '7.5'
    fill_in 'Year qualification was awarded', with: '1999'
    click_button 'Save and continue'
  end

  def then_i_have_completed_the_efl_section
    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content 'IELTS'
    expect(page).to have_content '123456'
    expect(page).to have_checked_field 'I have completed this section'
    click_button 'Continue'
    # expect EFL section to be marked complete
  end

private

  def efl_link_text
    'English as a foreign language'
  end
end
