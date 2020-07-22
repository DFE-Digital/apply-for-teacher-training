require 'rails_helper'

RSpec.feature 'Declare no EFL qualification' do
  include CandidateHelper
  include EFLHelper

  scenario 'Candidate declares they have no qualification and provides more detail' do
    given_i_am_signed_in
    and_the_efl_feature_flag_is_active
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
    choose 'No, I do not have an English as a foreign language qualification'
    fill_in(
      "If you're working towards a qualification, give details here",
      with: "I'm working towards an IELTS.",
    )
    click_button 'Continue'
  end

  def then_i_see_the_review_page
    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content 'No, I do not have an English as a foreign language qualification'
    expect(page).to have_content "I'm working towards an IELTS."
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
