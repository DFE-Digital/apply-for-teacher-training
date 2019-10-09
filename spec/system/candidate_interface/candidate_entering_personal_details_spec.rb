require 'rails_helper'

RSpec.feature 'Entering their personal details' do
  scenario 'Logged in candidate with no personal details' do
    given_i_am_signed_in
    and_i_visit_the_site
    when_i_click_on_personal_details
    then_i_can_edit_my_personal_details
  end

  scenario 'Candidate fills in personal details' do
    given_i_am_on_the_personal_details_page
    when_i_fill_in_the_form
    then_i_can_check_my_answers
  end

  scenario 'Candidate goes back to their application' do
    given_i_am_on_the_personal_details_page
    when_i_click_on_back_to_application
    then_i_can_see_my_application
  end

  def given_i_am_signed_in
    candidate = FactoryBot.create(:candidate)
    login_as(candidate)
  end

  def given_i_am_on_the_personal_details_page
    given_i_am_signed_in
    visit candidate_interface_personal_details_edit_path
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_personal_details
    click_link t('page_titles.personal_details')
  end

  def when_i_fill_in_the_form
    fill_in t('application_form.personal_details.first_name.label'), with: 'Lando'
    fill_in t('application_form.personal_details.last_name.label'), with: 'Calrissian'

    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'

    fill_in t('application_form.personal_details.nationality.label'), with: 'English'

    choose 'Yes'

    click_button t('application_form.personal_details.complete_form_button')
  end

  def when_i_click_on_back_to_application
    click_link 'Back to application'
  end

  def then_i_can_edit_my_personal_details
    expect(page).to have_content t('page_titles.personal_details')
    expect(page).to have_content t('application_form.personal_details.first_name.label')
    expect(page).to have_content t('application_form.personal_details.last_name.label')
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content 'Change'
  end

  def then_i_can_see_my_application
    expect(page).to have_content t('page_titles.application_form')
  end
end
