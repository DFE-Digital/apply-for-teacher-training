require 'rails_helper'

RSpec.feature 'Review references' do
  include CandidateHelper

  before { FeatureFlag.deactivate(:reference_selection) }

  scenario 'Candidate submits and reviews references' do
    given_i_am_signed_in

    when_i_have_no_references_and_try_to_visit_the_review_page
    then_i_am_redirected_to_the_start_page

    when_i_view_my_application
    then_the_references_section_is_incomplete

    when_i_have_added_references
    then_the_references_section_is_still_incomplete

    when_enough_references_have_been_given
    then_the_references_section_is_complete
    and_i_can_review_my_references_before_submission
    and_i_can_delete_a_reference
    and_i_can_delete_a_reference_request
    and_i_can_cancel_a_sent_reference
    and_referee_receives_email_about_reference_cancellation
    and_i_can_return_to_the_application_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_no_references_and_try_to_visit_the_review_page
    visit candidate_interface_references_review_path
  end

  def then_i_am_redirected_to_the_start_page
    expect(page).to have_current_path candidate_interface_references_start_path
  end

  def when_i_view_my_application
    visit candidate_interface_application_form_path
  end

  def then_the_references_section_is_incomplete
    when_i_view_my_application
    within '#add-your-references-badge-id' do
      expect(page).to have_content 'Incomplete'
    end
  end

  def then_the_references_section_is_still_incomplete
    when_i_view_my_application
    within '#manage-your-references-badge-id' do
      expect(page).to have_content 'In progress'
    end
  end

  def when_i_have_added_references
    application_form = current_candidate.current_application
    @complete_reference = create(:reference, :feedback_provided, application_form: application_form)
    @not_sent_reference = create(:reference, :not_requested_yet, application_form: application_form)
    @requested_reference = create(:reference, :feedback_requested, application_form: application_form)
    @refused_reference = create(:reference, :feedback_refused, application_form: application_form)
    @cancelled_reference = create(:reference, :cancelled, application_form: application_form)
    @bounced_reference = create(:reference, :cancelled, application_form: application_form)
  end

  def when_enough_references_have_been_given
    create(:reference, :feedback_provided, application_form: current_candidate.current_application)
  end

  def then_the_references_section_is_complete
    when_i_view_my_application
    within '#review-your-references-badge-id' do
      expect(page).to have_content 'Complete'
    end
  end

  def and_i_can_review_my_references_before_submission
    click_link 'Review your references'
    expect(page).to have_current_path candidate_interface_references_review_path

    within '#references_given' do
      expect(page).to have_content @complete_reference.email_address
      expect(page).not_to have_link 'Change'
      expect(page).to have_link 'Delete reference'
    end

    within '#references_waiting_to_be_sent' do
      expect(page).to have_content @not_sent_reference.email_address
      expect(page).not_to have_link 'Change'
      expect(page).to have_link 'Delete referee'
    end

    within '#references_sent' do
      expect(all('.app-summary-card')[0].text).to have_content @requested_reference.email_address
      expect(all('.app-summary-card')[0]).not_to have_link 'Change'
      expect(all('.app-summary-card')[0]).not_to have_link 'Delete'
      expect(all('.app-summary-card')[1].text).to have_content @refused_reference.email_address
      expect(all('.app-summary-card')[1]).not_to have_link 'Change'
      expect(all('.app-summary-card')[1]).to have_link 'Delete request'
      expect(all('.app-summary-card')[2].text).to have_content @cancelled_reference.email_address
      expect(all('.app-summary-card')[2]).not_to have_link 'Change'
      expect(all('.app-summary-card')[2]).to have_link 'Delete request'
      expect(all('.app-summary-card')[3].text).to have_content @bounced_reference.email_address
      expect(all('.app-summary-card')[3]).not_to have_link 'Change'
      expect(all('.app-summary-card')[3]).to have_link 'Delete request'
    end
  end

  def and_i_can_delete_a_reference
    within '#references_waiting_to_be_sent' do
      click_link 'Delete referee'
    end
    click_button 'Yes I’m sure'

    expect(page).to have_current_path candidate_interface_references_review_path
    expect(page).not_to have_css('#references_waiting_to_be_sent')
  end

  def and_i_can_delete_a_reference_request
    within '#references_sent' do
      click_link 'Delete request', match: :first
    end
    click_button 'Yes I’m sure'

    expect(page).to have_current_path candidate_interface_references_review_path
    expect(page).not_to have_content @refused_reference.name
  end

  def and_i_can_cancel_a_sent_reference
    within '#references_sent' do
      click_link 'Cancel request'
    end
    click_button 'Yes I’m sure'

    expect(page).to have_current_path candidate_interface_references_review_path
    expect(page).to have_content("Reference request cancelled for #{@requested_reference.name}")
    expect(page).to have_content('Request cancelled')
  end

  def and_referee_receives_email_about_reference_cancellation
    open_email(@requested_reference.email_address)

    expect(current_email.subject).to include 'Reference request cancelled by'
    expect(current_email.text).to include 'The candidate has cancelled their request.'
  end

  def and_i_can_return_to_the_application_page
    click_link t('continue')
    expect(page).to have_current_path candidate_interface_application_form_path
  end
end
