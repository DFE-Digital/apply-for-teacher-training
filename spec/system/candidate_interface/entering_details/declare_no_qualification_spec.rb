require 'rails_helper'

RSpec.feature 'Declare no EFL qualification' do
  include CandidateHelper
  include EFLHelper

  scenario 'Candidate declares they have no qualification and provides more detail' do
    given_i_am_signed_in
    and_i_declare_a_non_english_speaking_nationality
    and_i_click_on_the_efl_section_link

    when_i_declare_i_have_no_qualification
    then_i_see_the_review_page
    and_i_can_complete_this_section
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_declare_i_have_no_qualification
    choose 'No, I have not done an English as a foreign language assessment'
    fill_in(
      'If you’re planning on doing an assessment, give details here',
      with: 'I’m working towards an IELTS.',
    )
    click_button t('continue')
  end

  def then_i_see_the_review_page
    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content 'No, I have not done an English as a foreign language assessment'
    expect(page).to have_content 'I’m working towards an IELTS.'
  end

  def and_i_can_complete_this_section
    choose t('application_form.incomplete_radio')
    click_button t('continue')
    expect(page).to have_css('#english-as-a-foreign-language-assessment-badge-id', text: 'Incomplete')
    click_link efl_link_text
    choose t('application_form.completed_radio')
    click_button t('continue')
    expect(page).to have_css('#english-as-a-foreign-language-assessment-badge-id', text: 'Completed')
  end
end
