require 'rails_helper'

RSpec.describe 'Candidate attempts to submit their application without a valid address' do
  include CandidateHelper

  it 'The candidate has completed their contact details without entering an address' do
    given_i_complete_my_application
    and_my_address_details_are_incomplete

    when_i_click_contact_details_link_from_dashboard
    then_i_see_populated_telephone_number_form

    when_i_click_continue
    then_i_see_populated_address_type_form

    when_i_click_continue
    then_i_see_address_details_form

    when_i_click_back
    then_i_see_populated_address_type_form

    when_i_click_back
    then_i_see_populated_telephone_number_form
  end

  def given_i_complete_my_application
    candidate_completes_application_form
  end

  def and_my_address_details_are_incomplete
    current_candidate.current_application.update(
      address_line1: nil,
    )
  end

  def when_i_click_contact_details_link_from_dashboard
    visit candidate_interface_continuous_applications_details_path
    click_link_or_button 'Contact information'
  end

  def then_i_see_populated_telephone_number_form
    expect(page).to have_field(
      'Phone number',
      with: current_candidate.current_application.phone_number,
    )
  end

  def when_i_click_continue
    click_link_or_button 'Save and continue'
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def then_i_see_populated_address_type_form
    expect(find_field('In the UK').checked?).to be(true)
  end

  def then_i_see_address_details_form
    expect(page).to have_content('What is your address?')
    expect(page).to have_field(
      'Postcode',
      with: current_candidate.current_application.postcode,
    )
  end
end
