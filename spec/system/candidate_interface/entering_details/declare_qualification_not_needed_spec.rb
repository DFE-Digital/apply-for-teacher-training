require 'rails_helper'

RSpec.feature 'Declare EFL qualification not required' do
  include CandidateHelper
  include EFLHelper

  scenario 'Candidate declares that English is not a foreign language to them' do
    given_i_am_signed_in
    and_i_declare_a_non_english_speaking_nationality
    and_i_click_on_the_efl_section_link

    when_i_declare_that_english_is_not_foreign_to_me
    then_i_see_the_review_page
    and_i_can_complete_this_section
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_declare_that_english_is_not_foreign_to_me
    choose 'No, English is not a foreign language to me'
    click_button t('continue')
  end

  def then_i_see_the_review_page
    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content 'No, English is not a foreign language to me'
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
