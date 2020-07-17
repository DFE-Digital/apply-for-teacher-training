require 'rails_helper'

RSpec.feature 'Add Other qualification' do
  include CandidateHelper
  include EFLHelper

  scenario "Candidate completes EFL section with details of a qualification type we don't provide an option for" do
    given_i_am_signed_in
    and_the_efl_feature_flag_is_active
    and_i_declare_a_non_english_speaking_nationality
    and_i_click_on_the_efl_section_link

    and_i_select_the_options_for_other_qualification
    when_i_provide_my_qualification_details
    then_i_can_review_my_qualification
    and_i_can_edit_my_qualification
    and_i_can_complete_this_section
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_select_the_options_for_other_qualification
    choose 'Yes'
    click_button 'Continue'
    choose 'Other'
    click_button 'Continue'
  end

  def when_i_provide_my_qualification_details
    fill_in 'Qualification name', with: 'Pearson Test of English'
    fill_in 'Score or grade', with: '90'
    fill_in 'Year qualification was awarded', with: '1999'
    click_button 'Save and continue'
  end

  def then_i_can_review_my_qualification
    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content 'Pearson Test of English'
    expect(page).to have_content '90'
    expect(page).to have_content 'I have completed this section'
  end

  def and_i_can_edit_my_qualification
    within(all('.govuk-summary-list__row')[3]) do
      click_link 'Change year'
    end

    expect(page).to have_field('Year qualification was awarded', with: '1999')
    fill_in 'Year qualification was awarded', with: '2001'
    click_button 'Save and continue'

    expect(page).to have_current_path candidate_interface_english_foreign_language_review_path
    expect(page).to have_content '2001'
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
