require 'rails_helper'

RSpec.feature 'Docs' do
  include DfESignInHelpers

  scenario 'Support user visits process documentation' do
    given_i_am_a_support_user
    when_i_visit_the_process_documentation
    then_i_see_the_documentation
    and_it_contains_documentation_for_all_emails
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_process_documentation
    visit support_interface_process_path
  end

  def then_i_see_the_documentation
    expect(page).to have_content 'Process'
  end

  def and_it_contains_documentation_for_all_emails
    emails_outside_of_states = %w[
      candidate_mailer-new_referee_request
      candidate_mailer-survey_chaser_email
      candidate_mailer-survey_email
      referee_mailer-survey_chaser_email
      referee_mailer-survey_email
      candidate_mailer-reference_chaser_email
      referee_mailer-reference_request_chaser_email
    ]

    # extract all the emails that we send into a list of strings like "referee_mailer-reference_request_chaser_email"
    emails_sent = [CandidateMailer, RefereeMailer].flat_map { |k| k.public_instance_methods(false).map { |m| "#{k.name.underscore}-#{m}" } }

    emails_documented = I18n.t('events').flat_map { |_name, attrs| attrs[:emails] }.compact + emails_outside_of_states

    expect(emails_documented).to match_array(emails_sent)
  end
end
