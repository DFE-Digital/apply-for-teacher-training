require 'rails_helper'

RSpec.feature 'Candidate updates their contact information from an international address to a UK' do
  include CandidateHelper

  scenario 'Candidate submits their contact information' do
    given_i_am_signed_in
    and_i_have_already_filled_in_an_international_address
    and_i_visit_the_site

    when_i_click_on_contact_information
    then_i_see_my_contact_details_are_complete

    when_i_change_to_an_international_address
    and_i_click_the_back_button
    then_i_do_not_have_the_option_to_complete
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_already_filled_in_an_international_address
    current_candidate.current_application.update(
      phone_number: '+123 456 7890',
      address_type: 'international',
      address_line1: '1 Big Road',
      address_line3: 'Small Town',
      country: 'FR',
      postcode: nil,
      contact_details_completed: true,
    )
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_contact_information
    click_link t('page_titles.contact_information')
  end

  def then_i_see_my_contact_details_are_complete
    expect(find_field('Yes, I have completed this section')).to be_checked
  end

  def when_i_change_to_an_international_address
    click_link('Change address')
    choose('In the UK')
    click_button('Save and continue')
  end

  def and_i_click_the_back_button
    click_link 'Back'
  end

  def then_i_do_not_have_the_option_to_complete
    expect(page).not_to have_field('Yes, I have completed this section')
    expect(page).not_to have_button('Continue')
  end
end
