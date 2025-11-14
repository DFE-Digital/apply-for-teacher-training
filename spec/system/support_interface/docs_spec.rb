require 'rails_helper'

RSpec.describe 'Docs' do
  include DfESignInHelpers

  scenario 'Support user visits process documentation' do
    given_i_am_a_support_user
    when_i_visit_the_process_documentation
    then_the_application_state_diagram_is_generated
    and_i_see_the_provider_flow_documentation
    and_it_contains_documentation_for_all_emails

    when_i_click_on_candidate_flow_documentation
    then_the_candidate_flow_diagram_is_generated
    and_i_see_the_candidate_flow_documentation

    when_i_click_on_qualifications_documentation
    then_i_can_see_all_qualifications_data
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_process_documentation
    allow(ApplicationStateChange).to receive(:workflow_spec).and_return(Struct.new(:states).new({}))

    visit support_interface_docs_provider_flow_path
  end

  def then_the_application_state_diagram_is_generated
    expect(ApplicationStateChange).to have_received(:workflow_spec).exactly(3).times
  end

  def and_i_see_the_provider_flow_documentation
    expect(page).to have_title 'Provider application flow'
  end

  def and_it_contains_documentation_for_all_emails
    emails_outside_of_states = %w[
      provider_mailer-fallback_sign_in_email
      candidate_mailer-eoc_first_deadline_reminder
      candidate_mailer-eoc_second_deadline_reminder
      candidate_mailer-application_deadline_has_passed
      candidate_mailer-reject_by_default_explainer
      candidate_mailer-respond_to_offer_before_deadline
      candidate_mailer-new_cycle_has_started
      candidate_mailer-duplicate_match_email
      candidate_mailer-find_has_opened
      candidate_mailer-unconditional_offer_accepted
      candidate_mailer-conditions_statuses_changed
      candidate_mailer-change_course
      candidate_mailer-change_course_pending_conditions
      provider_mailer-unconditional_offer_accepted
      provider_mailer-confirm_sign_in
      provider_mailer-organisation_permissions_set_up
      provider_mailer-organisation_permissions_updated
      provider_mailer-apply_service_is_now_open
      provider_mailer-find_service_is_now_open
      provider_mailer-respond_to_applications_before_reject_by_default_date
      provider_mailer-set_up_organisation_permissions
      provider_mailer-permissions_granted
      provider_mailer-permissions_removed
      provider_mailer-permissions_updated
      provider_mailer-reference_received
      candidate_mailer-application_rejected
      candidate_mailer-application_choice_submitted
      candidate_mailer-offer_10_day
      candidate_mailer-offer_20_day
      candidate_mailer-offer_30_day
      candidate_mailer-offer_40_day
      candidate_mailer-offer_50_day
      candidate_mailer-candidate_invite
      candidate_mailer-invites_chaser
      candidate_mailer-pool_opt_in
      candidate_mailer-pool_opt_out
      candidate_mailer-pool_opt_out_after_opting_in
      candidate_mailer-pool_re_opt_in
      candidate_mailer-visa_sponsorship_deadline_reminder
      candidate_mailer-visa_sponsorship_deadline_change
    ]

    # extract all the emails that we send into a list of strings like "referee_mailer-reference_request_chaser_email"
    emails_sent = [CandidateMailer, ProviderMailer, RefereeMailer].flat_map { |k| k.public_instance_methods(false).map { |m| "#{k.name.underscore}-#{m}" } }
    documented_application_choice_emails = I18n.t('events').flat_map { |_name, attrs| attrs[:emails] }.compact.uniq
    documented_chaser_emails = I18n.t('application_states').flat_map { |_name, attrs| attrs[:emails] }.compact.uniq

    emails_documented = documented_application_choice_emails + documented_chaser_emails + emails_outside_of_states

    expect(emails_documented).to match_array(emails_sent)
  end

  def when_i_click_on_candidate_flow_documentation
    allow(CandidateFlow).to receive(:workflow_spec).and_return(Struct.new(:states).new({}))

    click_link_or_button 'Candidate flow'
  end

  def then_the_candidate_flow_diagram_is_generated
    expect(CandidateFlow).to have_received(:workflow_spec).exactly(3).times
  end

  def and_i_see_the_candidate_flow_documentation
    expect(page).to have_title 'Candidate application flow'
  end

  def when_i_click_on_qualifications_documentation
    click_link_or_button 'Qualifications'
  end

  def then_i_can_see_all_qualifications_data
    expect(page).to have_content('These lists are a reference for the values used throughout the service.')
    expect(page).to have_content('Degree grades (with HESA codes)')
    expect(page).to have_content('Degree types')
  end
end
