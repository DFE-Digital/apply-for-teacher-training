require 'rails_helper'

RSpec.feature 'References' do
  include CandidateHelper

  before { FeatureFlag.deactivate(:reference_selection) }

  scenario 'The candidate receives feedback from two of their four referees' do
    given_i_am_signed_in
    and_i_have_provided_my_name
    and_i_have_provided_4_references
    and_one_my_references_has_declined_to_give_feedback
    and_i_have_received_feedback_from_two_references

    when_i_visit_my_reference_review_page
    then_i_can_see_my_references_have_provided_feedback
    and_i_can_see_that_one_of_my_referees_declined_my_request
    and_i_can_see_my_remaining_reference_request_has_been_cancelled
    and_my_final_referee_has_been_told_that_they_do_not_need_to_provide_feedback
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
    @application = @candidate.current_application
  end

  def and_i_have_provided_my_name
    @application.update!(first_name: 'Lando', last_name: 'Calrissian')
  end

  def and_i_have_provided_4_references
    visit candidate_interface_references_start_path
    click_link t('continue')
    choose 'Academic'
    click_button t('continue')

    candidate_fills_in_referee
    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')

    click_link 'Add a second referee'
    click_link t('continue')
    choose 'Professional'
    click_button t('continue')

    candidate_fills_in_referee(
      name: 'Anne Other',
      email_address: 'anne@other.com',
      relationship: 'First boss',
    )
    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')

    click_link 'Add another referee'
    click_link t('continue')
    choose 'School-based'
    click_button t('continue')

    candidate_fills_in_referee(
      name: 'Mr Declined',
      email_address: 'mr@declined.com',
      relationship: 'Mentor',
    )
    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')

    click_link 'Add another referee'
    click_link t('continue')
    choose 'Character'
    click_button t('continue')

    candidate_fills_in_referee(
      name: 'Ms Cancelled',
      email_address: 'ms@ocancelled.com',
      relationship: 'Worked with me at a charity.',
    )
    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')
  end

  def and_one_my_references_has_declined_to_give_feedback
    @application.application_references.school_based.first.feedback_refused!
  end

  def and_i_have_received_feedback_from_two_references
    receive_references
  end

  def when_i_visit_my_reference_review_page
    visit candidate_interface_references_review_path
  end

  def then_i_can_see_my_references_have_provided_feedback
    within all('.app-summary-card')[0] do
      expect(find('.app-summary-card__title').text).to have_content 'Academic reference from Terri Tudor'
      expect(all('.govuk-summary-list__row')[4].text).to have_content 'Reference given'
    end

    within all('.app-summary-card')[1] do
      expect(find('.app-summary-card__title').text).to have_content 'Professional reference from Anne Other'
      expect(all('.govuk-summary-list__row')[4].text).to have_content 'Reference given'
    end
  end

  def and_i_can_see_that_one_of_my_referees_declined_my_request
    within all('.app-summary-card')[2] do
      expect(find('.app-summary-card__title').text).to have_content 'School-based reference from Mr Declined'
      expect(all('.govuk-summary-list__row')[4].text).to have_content 'Reference declined'
    end
  end

  def and_i_can_see_my_remaining_reference_request_has_been_cancelled
    within all('.app-summary-card')[3] do
      expect(find('.app-summary-card__title').text).to have_content 'Character reference from Ms Cancelled'
      expect(all('.govuk-summary-list__row')[4].text).to have_content 'Request cancelled'
    end
  end

  def and_my_final_referee_has_been_told_that_they_do_not_need_to_provide_feedback
    open_email('ms@ocancelled.com')

    expect(current_email.body).to have_content('You do not need to give a reference for Lando Calrissian')
  end
end
