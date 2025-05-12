require 'rails_helper'

RSpec.describe 'Change qualification' do
  include CandidateHelper
  include EFLHelper

  scenario 'Candidate changes their IELTS to a TOEFL' do
    given_i_am_signed_in_with_one_login
    and_i_declare_a_non_english_speaking_nationality
    and_i_click_on_the_efl_section_link

    and_i_have_an_ielts_qualification
    when_i_visit_the_review_page
    then_i_can_change_my_qualification
  end

  def and_i_have_an_ielts_qualification
    application_form = current_candidate.current_application
    application_form.english_proficiency = create(
      :english_proficiency, :with_ielts_qualification
    )
  end

  def when_i_visit_the_review_page
    visit candidate_interface_english_foreign_language_review_path
  end

  def then_i_can_change_my_qualification
    click_change_link('type of assessment')
    choose 'Test of English as a Foreign Language (TOEFL)'
    click_link_or_button t('continue')

    fill_in 'TOEFL registration number', with: '0000 0000'
    fill_in 'Total score', with: '10'
    fill_in 'When did you complete the assessment?', with: '2007'
    click_link_or_button t('save_and_continue')

    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content 'TOEFL'
    expect(page).to have_content '0000 0000'
    expect(page).to have_content '10'
    expect(page).to have_content '2007'
    expect(page).to have_content 'I have completed this section'
  end
end
