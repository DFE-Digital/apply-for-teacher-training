require 'rails_helper'

RSpec.describe 'Cancelling a reference' do
  include CandidateHelper

  scenario 'candidate cancels a reference request after completing their application' do
    given_the_training_with_a_disability_flag_is_active
    and_i_have_completed_and_submitted_my_application
    and_the_candidate_can_cancel_reference_flag_is_active
    and_the_referee_type_flag_is_active

    when_i_visit_the_application_complete_page
    and_i_click_delete_on_my_first_reference
    then_i_should_see_the_confirm_cancel_page

    when_i_click_to_confirm_the_cancellation
    then_i_should_see_the_add_referee_type_page
    and_the_referee_should_be_sent_a_cancelation_email
    and_a_slack_notification_is_sent
  end

  def given_the_training_with_a_disability_flag_is_active
    FeatureFlag.activate('training_with_a_disability')
  end

  def and_i_have_completed_and_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_the_candidate_can_cancel_reference_flag_is_active
    FeatureFlag.activate('candidate_can_cancel_reference')
  end

  def and_the_referee_type_flag_is_active
    FeatureFlag.activate('referee_type')
  end

  def when_i_visit_the_application_complete_page
    visit candidate_interface_application_complete_path
  end

  def and_i_click_delete_on_my_first_reference
    @reference = ApplicationReference.first
    click_link "Cancel referee #{@reference.name}"
  end

  def then_i_should_see_the_confirm_cancel_page
    expect(page).to have_current_path(candidate_interface_confirm_cancel_referee_path(@reference.id))
  end

  def when_i_click_to_confirm_the_cancellation
    click_button t('application_form.referees.sure_cancel_entry')
  end

  def then_i_should_see_the_add_referee_type_page
    expect(page).to have_current_path(candidate_interface_additional_referee_type_path)
  end

  def and_the_referee_should_be_sent_a_cancelation_email
    open_email(@reference.email_address)

    expect(current_email.subject).to have_content(t('reference_cancelled_email.subject', candidate_name: ApplicationForm.first.full_name))
  end

  def and_a_slack_notification_is_sent
    expect_slack_message_with_text "Candidate #{@reference.application_form.first_name} has cancelled one of their references"
  end
end
