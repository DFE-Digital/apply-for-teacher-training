require 'rails_helper'

RSpec.feature 'Docs' do
  include DfESignInHelpers

  scenario 'Support user visits process documentation' do
    given_i_am_a_support_user
    when_i_visit_the_process_documentation
    then_the_application_state_diagram_is_generated
    and_i_see_the_provider_flow_documentation
    and_it_contains_documentation_for_all_emails

    when_i_click_on_candidate_flow_documentation
    then_the_process_state_diagram_is_generated
    and_i_see_the_candidate_flow_documentation
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_process_documentation
    allow(ApplicationStateChange).to receive(:workflow_spec).and_return(Struct.new(:states).new([]))

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
      provider_mailer-account_created
      provider_mailer-fallback_sign_in_email
      provider_mailer-ucas_match_initial_email_duplicate_applications
      candidate_mailer-apply_again_call_to_action
      candidate_mailer-course_unavailable_notification
      candidate_mailer-eoc_deadline_reminder
      candidate_mailer-new_cycle_has_started
      candidate_mailer-ucas_match_initial_email_duplicate_applications
      candidate_mailer-ucas_match_initial_email_multiple_acceptances
      candidate_mailer-ucas_match_reminder_email_duplicate_applications
      candidate_mailer-ucas_match_reminder_email_multiple_acceptances
      candidate_mailer-ucas_match_resolved_on_ucas_email
      candidate_mailer-ucas_match_resolved_on_ucas_at_our_request_email
      provider_mailer-ucas_match_resolved_on_ucas_email
      candidate_mailer-ucas_match_resolved_on_apply_email
      provider_mailer-ucas_match_resolved_on_apply_email
      provider_mailer-courses_open_on_apply
      candidate_mailer-unconditional_offer_accepted
      provider_mailer-unconditional_offer_accepted
      provider_mailer-confirm_sign_in
      provider_mailer-organisation_permissions_set_up
      provider_mailer-organisation_permissions_updated
    ]

    # extract all the emails that we send into a list of strings like "referee_mailer-reference_request_chaser_email"
    emails_sent = [CandidateMailer, ProviderMailer, RefereeMailer].flat_map { |k| k.public_instance_methods(false).map { |m| "#{k.name.underscore}-#{m}" } }
    documented_application_choice_emails = I18n.t('events').flat_map { |_name, attrs| attrs[:emails] }.compact.uniq
    documented_chaser_emails = I18n.t('application_states').flat_map { |_name, attrs| attrs[:emails] }.compact.uniq

    emails_documented = documented_application_choice_emails + documented_chaser_emails + emails_outside_of_states

    expect(emails_documented).to match_array(emails_sent)
  end

  def when_i_click_on_candidate_flow_documentation
    allow(ProcessState).to receive(:workflow_spec).and_return(Struct.new(:states).new([]))

    click_on 'Candidate flow'
  end

  def then_the_process_state_diagram_is_generated
    expect(ProcessState).to have_received(:workflow_spec).exactly(3).times
  end

  def and_i_see_the_candidate_flow_documentation
    expect(page).to have_title 'Candidate application flow'
  end
end
