require 'rails_helper'

RSpec.describe 'Entering personal details', time: Time.zone.local(RecruitmentCycle.current_year, 7, 6, 12) do
  include CandidateHelper

  scenario 'I can specify that I need to apply for right to work or study in the UK' do
    and_i_am_signed_in
    and_i_can_complete_personal_information_with_non_british_or_irish_nationality
    and_i_can_mark_the_section_complete
  end

  def and_i_am_signed_in
    create_and_sign_in_candidate
    visit candidate_interface_details_path
  end

  def and_i_can_complete_personal_information_with_non_british_or_irish_nationality
    click_link_or_button t('page_titles.personal_information.heading')

    # Basic details
    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope:), with: 'Lando'
    fill_in t('last_name.label', scope:), with: 'Calrissian'
    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'
    click_link_or_button t('save_and_continue')

    # Nationality
    check 'British'
    click_link_or_button t('save_and_continue')
    expect(page).to have_current_path candidate_interface_personal_details_show_path

    # Go back and change nationality
    visit candidate_interface_nationalities_path
    check 'Citizen of a different country'
    within all('.govuk-form-group')[1] do
      select 'Pakistani'
    end
    click_link_or_button t('save_and_continue')

    # Right to work or study
    expect(page).to have_content 'Do you already have the right to work or study in the UK?'
    choose 'No'
    click_link_or_button t('save_and_continue')

    # Review
    expect(page).to have_current_path candidate_interface_personal_details_show_path
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content 'Pakistani'
    expect(page).to have_content 'Do you have the right to work or study in the UK?'
  end

  def and_i_can_mark_the_section_complete
    choose t('application_form.completed_radio')
    click_link_or_button t('continue')

    expect(page).to have_css('#personal-information-badge-id', text: 'Completed')
  end
end
