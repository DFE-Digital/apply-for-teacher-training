require 'rails_helper'

RSpec.feature 'Candidate attempts to submit their application without a valid address', continuous_applications: false do
  include CandidateHelper

  it 'The candidate has completed their contact details without entering an address' do
    given_i_complete_my_application
    and_my_address_details_are_blank
    when_i_submit_my_application
    then_i_cannot_proceed
    when_i_complete_my_contact_details
    then_i_can_proceed
  end

  def given_i_complete_my_application
    candidate_completes_application_form
  end

  def and_my_address_details_are_blank
    current_candidate.current_application.update(
      address_line1: nil,
      address_line2: nil,
      address_line3: nil,
      address_line4: nil,
      postcode: nil,
    )
  end

  def when_i_submit_my_application
    click_link 'Check and submit your application'
    click_link t('continue')
  end

  def then_i_cannot_proceed
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Contact details not complete')
  end

  def when_i_complete_my_contact_details
    click_link 'Complete your contact details'
    click_link 'Enter address'

    choose 'In the UK'
    click_button t('save_and_continue')
    find(:css, "[autocomplete='address-line1']").fill_in with: '42 Much Wow Street'
    fill_in t('application_form.contact_details.address_line3.label.uk'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label.uk'), with: 'SW1P 3BT'
    click_button t('save_and_continue')

    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def then_i_can_proceed
    click_link 'Check and submit your application'
    click_link t('continue')

    expect(page).to have_content('Send application to training providers')
  end
end
