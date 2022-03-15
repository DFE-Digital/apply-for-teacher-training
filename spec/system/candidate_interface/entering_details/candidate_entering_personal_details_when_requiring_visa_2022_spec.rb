require 'rails_helper'

RSpec.describe 'Entering personal details' do
  include CandidateHelper

  scenario 'I can specify that I need to apply for right to work or study in the UK' do
    given_i_am_apply_during_the_2022_recruitment_cycle
    and_i_am_signed_in
    and_i_can_complete_personal_information_stating_that_i_need_a_visa_sponsorship
    and_i_can_change_state_that_i_have_permanent_residence
    and_i_can_change_nationality_to_an_eu_country_with_settled_status
    and_i_can_change_immigration_status
    and_i_can_mark_the_section_complete
  end

  def given_i_am_apply_during_the_2022_recruitment_cycle
    allow(RecruitmentCycle).to receive(:current_year).and_return(2022)
  end

  def and_i_am_signed_in
    create_and_sign_in_candidate
    visit candidate_interface_application_form_path
  end

  def and_i_can_complete_personal_information_stating_that_i_need_a_visa_sponsorship
    click_link t('page_titles.personal_information')

    # Basic details
    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope: scope), with: 'Lando'
    fill_in t('last_name.label', scope: scope), with: 'Calrissian'
    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'
    click_button t('save_and_continue')

    # Nationality
    check 'Citizen of a different country'
    within all('.govuk-form-group')[1] do
      select 'Pakistani'
    end
    click_button t('save_and_continue')

    # Right to work or study
    expect(page).to have_content 'Do you already have the right to work or study in the UK?'
    choose 'Not yet'
    click_button t('save_and_continue')

    # Review
    expect(page).to have_current_path candidate_interface_personal_details_show_path
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content 'Pakistani'
    expect(page).to have_content "Do you have the right to work or study in the UK?\nNot yet"
  end

  def and_i_can_change_state_that_i_have_permanent_residence
    click_change_link('if you have the right to work or study in the UK')
    expect(page).to have_content 'Do you already have the right to work or study in the UK?'
    choose 'Yes'
    click_button t('save_and_continue')

    expect(page).to have_content 'What is your immigration status?'
    fill_in 'What is your immigration status?', with: 'I have permanent residence'
    click_button t('save_and_continue')

    expect(page).not_to have_content 'When did you enter the UK?'

    expect(page).to have_current_path candidate_interface_personal_details_show_path
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content 'Pakistani'
    expect(page).to have_content "Do you have the right to work or study in the UK?\nYes"
    expect(page).to have_content "Immigration status\nI have permanent residence"
    expect(page).not_to have_content 'Date of entry into the UK'
  end

  def and_i_can_change_nationality_to_an_eu_country_with_settled_status
    click_change_link('nationality')

    check 'Citizen of a different country'
    within all('.govuk-form-group')[1] do
      select 'French'
    end
    click_button t('save_and_continue')

    expect(page).to have_content 'Do you already have the right to work or study in the UK?'
    choose 'Yes'
    click_button t('save_and_continue')

    expect(page).to have_content 'What is your immigration status?'
    choose 'EU settled status'
    click_button t('save_and_continue')

    expect(page).not_to have_content 'When did you enter the UK?'

    expect(page).to have_current_path candidate_interface_personal_details_show_path
    expect(page).to have_content "Nationality\nFrench"
    expect(page).to have_content "Do you have the right to work or study in the UK?\nYes"
    expect(page).to have_content "Immigration status\nEU settled status"
    expect(page).not_to have_content 'Date of entry into the UK'
  end

  def and_i_can_change_immigration_status
    click_change_link('immigration status')

    expect(page).to have_content 'What is your immigration status?'
    choose 'EU pre-settled status'
    click_button t('save_and_continue')

    expect(page).to have_current_path candidate_interface_personal_details_show_path
    expect(page).to have_content "Immigration status\nEU pre-settled status"
  end

  def and_i_can_mark_the_section_complete
    choose t('application_form.completed_radio')
    click_button t('continue')

    expect(page).to have_css('#personal-information-badge-id', text: 'Completed')
  end
end
