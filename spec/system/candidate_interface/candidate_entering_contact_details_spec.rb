require 'rails_helper'

RSpec.feature 'Entering their contact details' do
  include CandidateHelper

  scenario 'Candidate submits their contact details' do
    given_i_am_not_signed_in
    and_i_visit_the_contact_details_page
    then_i_should_see_the_homepage

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_contact_details
    and_i_incorrectly_fill_in_my_phone_number
    and_i_submit_my_phone_number
    then_i_should_see_validation_errors_for_my_phone_number

    when_i_fill_in_my_phone_number
    and_i_submit_my_phone_number
    and_i_incorrectly_fill_in_my_address
    and_i_submit_my_address
    then_i_should_see_validation_errors_for_my_address

    when_i_fill_in_my_address
    and_i_submit_my_address
    then_i_can_check_my_answers

    when_i_click_to_change_my_phone_number
    then_i_can_see_my_phone_number

    when_i_fill_in_a_different_phone_number
    and_i_submit_my_phone_number
    then_i_can_check_my_revised_phone_number

    when_i_click_to_change_my_address
    then_i_can_see_my_address

    when_i_fill_in_a_different_address
    and_i_submit_my_address
    then_i_can_check_my_revised_address

    # when_i_submit_my_details
    # then_i_should_see_the_form
    # and_that_the_section_is_completed

    # when_i_click_on_contact_details
    # then_i_can_check_my_revised_answers
  end

  def given_i_am_not_signed_in; end

  def and_i_visit_the_contact_details_page
    visit candidate_interface_contact_details_edit_base_path
  end

  def then_i_should_see_the_homepage
    expect(page).to have_current_path(candidate_interface_start_path)
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
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

  def when_i_fill_in_my_phone_number
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 900 982'
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

  def when_i_click_to_change_my_address
    find_link('Change', href: candidate_interface_contact_details_edit_address_path).click
  end

  def then_i_can_see_my_address
    expect(page).to have_selector("input[value='42 Much Wow Street']")
    expect(page).to have_selector("input[value='London']")
    expect(page).to have_selector("input[value='SW1P 3BT']")
  end

  def when_i_fill_in_a_different_address
    fill_in t('application_form.contact_details.address_line1.label'), with: '99'
    fill_in t('application_form.contact_details.address_line2.label'), with: 'Problems Street'
  end

  def then_i_can_check_my_revised_address
    expect(page).to have_content t('application_form.contact_details.full_address.label')
    expect(page).to have_content '99'
    expect(page).to have_content 'Problems Street'
  end
end
