require 'rails_helper'

RSpec.feature 'Add TOEFL qualification' do
  include CandidateHelper
  include EFLHelper

  scenario 'Candidate completes EFL section with details of their TOEFL' do
    given_i_am_signed_in
    and_the_efl_feature_flag_is_active
    and_i_declare_a_non_english_speaking_nationality
    and_i_click_on_the_efl_section_link

    and_i_select_the_options_for_toefl
    when_i_provide_my_toefl_details
    then_i_can_review_my_qualification
    and_i_can_edit_my_qualification
    and_i_can_complete_this_section
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_select_the_options_for_toefl
    choose 'Yes'
    click_button 'Continue'
    choose 'Test of English as a Foreign Language'
    click_button 'Continue'
  end

  def when_i_provide_my_toefl_details
    fill_in 'TOEFL registration number', with: '123456'
    fill_in 'Total score', with: '10'
    fill_in 'Year qualification was awarded', with: '1999'
    click_button 'Save and continue'
  end

  def then_i_can_review_my_qualification
    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content 'TOEFL'
    expect(page).to have_content '123456'
    expect(page).to have_content 'I have completed this section'
  end

  def and_i_can_edit_my_qualification
    within(all('.govuk-summary-list__row')[2]) do
      click_link 'Change registration number'
    end

    expect(page).to have_field('TOEFL registration number', with: '123456')
    fill_in 'TOEFL registration number', with: '888'
    click_button 'Save and continue'

    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content '888'
    expect(page).to have_content 'I have completed this section'
  end

  def and_i_can_complete_this_section
    click_button 'Continue'
    expect(page).to have_css('#english-as-a-foreign-language-badge-id', text: 'Incomplete')
    click_link efl_link_text
    check 'I have completed this section'
    click_button 'Continue'
    expect(page).to have_css('#english-as-a-foreign-language-badge-id', text: 'Completed')
  end
end
