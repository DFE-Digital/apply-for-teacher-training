require 'rails_helper'

RSpec.describe 'Candidate submits their Personal Details' do
  scenario 'without selecting their immigration status' do
    i_am_signed_in_with_one_login
    i_visit_the_site

    i_click_on_personal_information
    i_fill_and_submit_my_personal_details

    i_choose_and_submit_a_non_uk_nationality
    i_choose_and_submit_yes_to_right_to_work_or_study_in_the_uk
    i_see_the_immigration_status_page

    i_click_your_details
    i_click_on_personal_information
    i_mark_the_section_as_completed # 🔥 No Visa/Immigration status selected
    # Add validation at this point to prevent the user from marking the section as complete
    # i_see_a_section_complete_error

    i_click_your_details
    i_see_my_personal_details_are_not_completed
  end

private

  def i_visit_the_site
    visit candidate_interface_details_path
  end

  def i_click_on_personal_information
    click_link_or_button 'Personal information'
  end

  def i_fill_and_submit_my_personal_details
    fill_in 'First name', with: 'Lando'
    fill_in 'Last name', with: 'Calrissian'
    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'

    click_link_or_button 'Save and continue'
  end

  def i_choose_and_submit_a_non_uk_nationality
    check 'Citizen of a different country'
    within('#candidate-interface-nationalities-form-other-nationality1-field') do
      select 'American'
    end

    click_link_or_button 'Save and continue'
  end

  def i_choose_and_submit_yes_to_right_to_work_or_study_in_the_uk
    choose 'Yes'

    click_link_or_button 'Save and continue'
  end

  def i_see_the_immigration_status_page
    expect(page).to have_css 'h1', text: 'Visa or immigration status'
  end

  def i_click_your_details
    click_link_or_button 'Your details'
  end

  def i_mark_the_section_as_completed
    choose 'Yes, I have completed this section'

    click_link_or_button 'Continue'
  end

  def i_see_my_personal_details_are_not_completed
    expect(page).to have_no_text 'Personal information Complete', normalize_ws: true
    expect(page).to have_text 'Personal information Incomplete', normalize_ws: true
  end
end
