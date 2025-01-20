require 'rails_helper'

RSpec.describe 'Candidate updates their contact information from an international address to a UK' do
  include CandidateHelper

  scenario 'Candidate submits their contact information' do
    given_i_am_signed_in_with_one_login
    and_i_have_already_filled_in_an_international_address
    and_i_visit_the_site

    when_i_click_on_contact_information
    then_i_see_my_contact_details_are_complete

    when_i_change_to_an_international_address
    and_i_click_the_back_button
    then_i_do_not_have_the_option_to_complete
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
    visit candidate_interface_details_path
  end

  def when_i_click_on_contact_information
    click_link_or_button t('page_titles.contact_information')
  end

  def then_i_see_my_contact_details_are_complete
    expect(find_field('Yes, I have completed this section')).to be_checked
  end

  def when_i_change_to_an_international_address
    click_link_or_button('Change address')
    choose('In the UK')
    click_link_or_button('Save and continue')
  end

  def and_i_click_the_back_button
    click_link_or_button 'Back'
  end

  def then_i_do_not_have_the_option_to_complete
    expect(page).to have_no_field('Yes, I have completed this section')
    expect(page).to have_no_button('Continue')
  end
end
