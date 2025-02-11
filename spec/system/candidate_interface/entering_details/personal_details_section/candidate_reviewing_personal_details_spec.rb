require 'rails_helper'

RSpec.describe 'Reviewing personal information' do
  include CandidateHelper

  scenario 'Candidate submits their personal details' do
    given_i_am_signed_in_with_one_login
    when_i_visit_the_personal_information_review_page
    then_i_see_details_with_links_to_enter_details
    and_i_do_not_see_dynamic_details
    and_i_do_not_see_the_complete_section_question
  end

  def when_i_visit_the_personal_information_review_page
    visit candidate_interface_personal_details_show_path
  end

  def then_i_see_details_with_links_to_enter_details
    within '[data-qa="personal-details-name"]' do
      expect(page).to have_text('Name')
      expect(page).to have_link('Enter your name', href: candidate_interface_edit_name_and_dob_path)
      expect(page).to have_no_link('Change name', href: candidate_interface_edit_name_and_dob_path)
    end

    within '[data-qa="personal-details-dob"]' do
      expect(page).to have_text('Date of birth')
      expect(page).to have_link('Enter your date of birth', href: candidate_interface_edit_name_and_dob_path)
      expect(page).to have_no_link('Change date of birth', href: candidate_interface_edit_name_and_dob_path)
    end

    within '[data-qa="personal-details-nationality"]' do
      expect(page).to have_text('Nationality')
      expect(page).to have_link('Enter your nationality', href: candidate_interface_edit_nationalities_path)
      expect(page).to have_no_link('Change nationality', href: candidate_interface_edit_nationalities_path)
    end

    ## Do not show if there is no Nationality not set
    # within '[data-qa="personal_details_immigration_right_to_work"]' do # update identifier to match kebab-case
    #   expect(page).to have_text('Do you have the right to work or study in the UK?')
    #   expect(page).to have_link('Change if you have the right to work or study in the UK', href: candidate_interface_edit_immigration_right_to_work_path)
    # end
    #
    ## Do not show if there is no Right to work is not set
    # within '[data-qa="personal_details_visa_or_immigration_status"]' do # update identifier to match kebab-case
    #   expect(page).to have_text('Visa or Immigration status')
    #   expect(page).to have_link('Change visa or immigration status', href: candidate_interface_edit_immigration_status_path)
    # end
  end

  def and_i_do_not_see_dynamic_details
    expect(page).to have_no_css('[data-qa="personal_details_immigration_right_to_work"]')
    expect(page).to have_no_css('[data-qa="personal_details_visa_or_immigration_status"]')
  end

  def and_i_do_not_see_the_complete_section_question
    expect(page).to have_no_content('Have you completed this section?')
    expect(page).to have_no_text('Continue')
  end
end
