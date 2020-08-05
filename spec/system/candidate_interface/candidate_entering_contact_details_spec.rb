require 'rails_helper'

RSpec.feature 'Entering their contact details' do
  include CandidateHelper

  scenario 'Candidate submits their contact details' do
    given_i_am_signed_in
    and_the_international_addresses_flag_is_active
    and_i_visit_the_site

    when_i_click_on_contact_details
    and_i_incorrectly_fill_in_my_phone_number
    and_i_submit_my_phone_number
    then_i_should_see_validation_errors_for_my_phone_number
    and_a_validation_error_is_logged_for_phone_number

    when_i_fill_in_my_phone_number
    and_i_submit_my_phone_number
    and_i_select_live_in_uk
    and_i_incorrectly_fill_in_my_address
    and_i_submit_my_address

    when_i_fill_in_my_address
    and_i_submit_my_address
    then_i_can_check_my_answers

    when_i_click_to_change_my_phone_number
    then_i_can_see_my_phone_number

    when_i_fill_in_a_different_phone_number
    and_i_submit_my_phone_number
    then_i_can_check_my_revised_phone_number

    when_i_click_to_change_my_address_type
    then_i_can_see_my_address_type

    when_i_select_outside_the_uk
    and_fill_in_an_international_address
    and_i_submit_my_address
    then_i_can_check_my_revised_address

    when_i_mark_the_section_as_completed
    and_i_submit_my_details
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_contact_details
    then_i_can_check_my_revised_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_international_addresses_flag_is_active
    FeatureFlag.activate('international_addresses')
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_contact_details
    click_link t('page_titles.contact_details')
  end

  def and_i_incorrectly_fill_in_my_phone_number
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 CAT DOG'
  end

  def and_i_submit_my_phone_number
    click_button t('application_form.contact_details.base.button')
  end

  def then_i_should_see_validation_errors_for_my_phone_number
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/contact_details_form.attributes.phone_number.invalid')
  end

  def and_a_validation_error_is_logged_for_phone_number
    validation_error = ValidationError.last
    expect(validation_error).to be_present
    expect(validation_error.details).to have_key('phone_number')
    expect(validation_error.user).to eq(current_candidate)
    expect(validation_error.request_path).to eq(candidate_interface_contact_details_update_base_path)
  end

  def when_i_fill_in_my_phone_number
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 900 982'
  end

  def and_i_select_live_in_uk
    expect(page).to have_content('Where do you live?')
    choose 'In the UK'
    click_button t('application_form.contact_details.base.button')
  end

  def and_i_incorrectly_fill_in_my_address
    fill_in t('application_form.contact_details.address_line3.label'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label'), with: 'MUCH W0W'
  end

  def then_i_should_see_validation_errors_for_my_address
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/contact_details_form.attributes.address_line1.blank')
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/contact_details_form.attributes.postcode.invalid')
  end

  def when_i_fill_in_my_address
    fill_in t('application_form.contact_details.address_line1.label'), with: '42 Much Wow Street'
    fill_in t('application_form.contact_details.address_line3.label'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label'), with: 'SW1P 3BT'
  end

  def and_i_submit_my_address
    click_button t('application_form.contact_details.address.button')
  end

  def then_i_can_check_my_answers
    expect(page).to have_content t('application_form.contact_details.phone_number.label')
    expect(page).to have_content '07700 900 982'
  end

  def when_i_click_to_change_my_phone_number
    find_link('Change', href: candidate_interface_contact_details_edit_base_path).click
  end

  def then_i_can_see_my_phone_number
    expect(page).to have_selector("input[value='07700 900 982']")
  end

  def when_i_fill_in_a_different_phone_number
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 424 242'
  end

  def then_i_can_check_my_revised_phone_number
    expect(page).to have_content t('application_form.contact_details.phone_number.label')
    expect(page).to have_content '07700 424 242'
  end

  def when_i_click_to_change_my_address_type
    find_link('Change', href: candidate_interface_contact_details_edit_address_type_path).click
  end

  def then_i_can_see_my_address
    expect(page).to have_selector("input[value='42 Much Wow Street']")
    expect(page).to have_selector("input[value='London']")
    expect(page).to have_selector("input[value='SW1P 3BT']")
  end

  def then_i_can_see_my_address_type
    expect(page).to have_selector("input[value='uk']")
  end

  def when_i_select_outside_the_uk
    expect(page).to have_content('Where do you live?')
    choose 'Outside the UK'
    select('India', from: t('application_form.contact_details.country.label'))
    click_button t('application_form.contact_details.base.button')
  end

  def and_fill_in_an_international_address
    fill_in t('page_titles.address'), with: '123 Chandni Chowk, Old Delhi'
  end

  def then_i_can_check_my_revised_address
    expect(page).to have_content t('application_form.contact_details.full_address.label')
    expect(page).to have_content '123 Chandni Chowk, Old Delhi'
    expect(page).to have_content 'India'
  end

  def when_i_mark_the_section_as_completed
    check t('application_form.completed_checkbox')
  end

  def and_i_submit_my_details
    click_button t('application_form.contact_details.review.button')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#contact-details-badge-id', text: 'Completed')
  end

  def then_i_can_check_my_revised_answers
    then_i_can_check_my_revised_phone_number
    then_i_can_check_my_revised_address
  end
end
