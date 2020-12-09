require 'rails_helper'

RSpec.describe 'Candidate feedback form' do
  include CandidateHelper

  before do
    FeatureFlag.activate(:feedback_form)
  end

  scenario 'Candidate completes the feedback form' do
    given_i_complete_and_submit_my_application
    then_i_should_be_asked_to_give_feedback
    and_i_should_receive_the_application_submitted_email

    when_i_click_give_feedback
    then_i_should_see_the_feedback_form

    when_i_click_send_feedback
    then_i_should_see_a_validation_error

    when_i_choose_very_satisfied
    and_i_make_a_suggestion
    and_click_send_feedback
    then_i_see_the_thank_you_page
    and_my_feedback_should_reflect_my_inputs
  end

  def given_i_complete_and_submit_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def then_i_should_be_asked_to_give_feedback
    expect(page).to have_content('Your feedback will help us improve.')
  end

  def and_i_should_receive_the_application_submitted_email
    open_email(current_candidate.email_address)
    expect(current_email.subject).to have_content t('candidate_mailer.application_submitted.subject')
  end

  def when_i_click_give_feedback
    click_link 'Give feedback'
  end

  def then_i_should_see_the_feedback_form
    expect(page).to have_content(t('page_titles.your_feedback'))
  end

  def when_i_click_send_feedback
    click_button 'Send feedback'
  end
  alias_method :and_click_send_feedback, :when_i_click_send_feedback

  def then_i_should_see_a_validation_error
    expect(page).to have_current_path(candidate_interface_feedback_form_path)
    expect(page).to have_content('Choose how satisfied are you with this service')
  end

  def when_i_choose_very_satisfied
    choose 'Very satisfied'
  end

  def and_i_make_a_suggestion
    fill_in 'How could we improve this service?', with: 'More rainbows and unicorns'
  end

  def then_i_see_the_thank_you_page
    expect(page).to have_content(t('page_titles.thank_you'))
  end

  def and_my_feedback_should_reflect_my_inputs
    expect(ApplicationForm.last.feedback_satisfaction_level).to eq('very_satisfied')
  end
end
