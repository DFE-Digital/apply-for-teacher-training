require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly', continuous_applications: false do
  include CandidateHelper

  it 'Candidate reviews completed application and updates contact details section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_have_not_filled_in_my_address
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete_except_contact_details

    when_i_click_complete_contact_details
    then_i_should_see_the_phone_number_form

    when_i_enter_a_phone_number_and_submit
    then_i_should_see_the_contact_information_review_page

    then_i_should_not_see_the_complete_form

    when_i_set_my_address
    and_i_select_section_complete_and_submit
    then_i_should_be_redirected_to_the_application_page
    and_i_should_see_all_sections_are_complete
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_have_not_filled_in_my_address
    current_candidate.current_application.update(
      address_type: 'uk',
      address_line1: nil,
      address_line2: nil,
      address_line3: nil,
      address_line4: nil,
      postcode: nil,
      country: nil,
      contact_details_completed: false,
    )
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_all_sections_are_complete_except_contact_details
    application_form_sections.excluding(:contact_details).each do |section|
      expect(page).not_to have_selector "[data-qa='incomplete-#{section}']"
    end
    expect(page).to have_selector "[data-qa='incomplete-contact_details']"
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def when_i_click_complete_contact_details
    click_link 'Complete your contact details'
  end

  def then_i_should_see_the_phone_number_form
    expect(page).to have_current_path(candidate_interface_edit_phone_number_path)
  end

  def when_i_enter_a_phone_number_and_submit
    fill_in 'Phone number', with: '0736519012'
    click_button 'Save and continue'
  end

  def then_i_should_see_the_contact_information_review_page
    expect(page).to have_current_path(candidate_interface_contact_information_review_path)
  end

  def and_i_select_section_complete_and_submit
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def then_i_should_not_see_the_complete_form
    expect(page).not_to have_field(t('application_form.completed_radio'))
    expect(page).not_to have_button(t('save_and_continue'))
  end

  def when_i_set_my_address
    when_i_click_change_address

    choose 'In the UK'
    click_button t('save_and_continue')
    find(:css, "[autocomplete='address-line1']").fill_in with: '42 Much Wow Street'
    fill_in t('application_form.contact_details.address_line3.label.uk'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label.uk'), with: 'SW1P 3BT'
    click_button t('save_and_continue')
  end

  def when_i_click_change_address
    within('[data-qa="contact-details-address"]') do
      click_link 'Enter address'
    end
  end

  def then_i_should_be_redirected_to_the_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def and_i_should_see_all_sections_are_complete
    expect(page).to have_content('Contact information Completed')
  end
end
