require 'rails_helper'

RSpec.feature 'Candidate adding referees in Sandbox', sandbox: true do
  include CandidateHelper

  scenario 'Candidate adds two auto-references' do
    given_i_am_signed_in
    and_i_have_provided_my_personal_details

    when_i_provide_two_references
    then_i_see_that_references_are_given

    when_i_provide_incomplete_reference_details
    then_i_see_that_the_incomplete_reference_rendered
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_provided_my_personal_details
    @candidate.current_application.update!(first_name: 'Mr', last_name: 'Bot')
  end

  def when_i_provide_two_references
    visit candidate_interface_references_start_path
    click_link t('continue')
    choose 'Academic'
    click_button t('save_and_continue')

    candidate_fills_in_referee(
      name: 'Refbot One',
      email_address: 'refbot1@example.com',
      relationship: 'First boss',
    )
    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')

    click_link 'Add a second referee'
    click_link t('continue')
    choose 'Professional'
    click_button t('save_and_continue')

    candidate_fills_in_referee(
      name: 'Refbot Two',
      email_address: 'refbot2@example.com',
      relationship: 'Second boss',
    )
    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')
  end

  def then_i_see_that_references_are_given
    within all('.app-summary-card')[0] do
      expect(all('.govuk-summary-list__value')[4].text).to have_content('Reference given')
    end

    within all('.app-summary-card')[1] do
      expect(all('.govuk-summary-list__value')[4].text).to have_content('Reference given')
    end
  end

  def when_i_provide_incomplete_reference_details
    visit candidate_interface_references_start_path
    click_link t('continue')
    choose 'Academic'
    click_button t('save_and_continue')
  end

  def then_i_see_that_the_incomplete_reference_rendered
    visit candidate_interface_references_review_path
    within all('.app-summary-card')[2] do
      expect(all('.govuk-summary-list__value')[0].text).to have_content('Not entered')
      expect(all('.govuk-summary-list__value')[1].text).to have_content('Not entered')
      expect(all('.govuk-summary-list__value')[2].text).to have_content('Academic')
      expect(all('.govuk-summary-list__value')[3].text).to have_content('Not entered')
    end
  end
end
