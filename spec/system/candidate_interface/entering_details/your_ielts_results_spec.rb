require 'rails_helper'

RSpec.feature 'Your IELTS result' do
  include CandidateHelper
  include EFLHelper

  scenario 'Candidate completes EFL section with details of their IELTS' do
    given_i_am_signed_in
    and_i_declare_a_non_english_speaking_nationality
    and_i_click_on_the_efl_section_link

    and_i_select_the_options_for_ielts
    when_i_provide_my_ielts_details
    then_i_can_review_my_qualification
    and_i_can_edit_my_qualification
    and_i_can_complete_this_section
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_select_the_options_for_ielts
    choose 'Yes'
    click_button t('continue')
    choose 'International English Language Testing System'
    click_button t('continue')
  end

  def when_i_provide_my_ielts_details
    fill_in 'Test report form (TRF) number', with: '123456'
    fill_in 'Overall band score', with: '7.5'
    fill_in 'When did you complete the assessment?', with: '1999'
    click_button t('save_and_continue')
  end

  def then_i_can_review_my_qualification
    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content 'IELTS'
    expect(page).to have_content '123456'
    expect(page).to have_content 'I have completed this section'
  end

  def and_i_can_edit_my_qualification
    click_change_link 'TRF number'

    expect(page).to have_field('Test report form (TRF) number', with: '123456')
    fill_in 'Test report form (TRF) number', with: '888'
    click_button t('save_and_continue')

    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content '888'
    expect(page).to have_content 'I have completed this section'
  end

  def and_i_can_complete_this_section
    click_button t('continue')
    expect(page).to have_css('#english-as-a-foreign-language-assessment-badge-id', text: 'Incomplete')
    click_link efl_link_text
    choose t('application_form.completed_radio')
    click_button t('continue')
    expect(page).to have_css('#english-as-a-foreign-language-assessment-badge-id', text: 'Completed')
  end
end
