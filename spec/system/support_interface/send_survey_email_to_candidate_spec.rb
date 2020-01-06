require 'rails_helper'

RSpec.feature 'Send survey email to candidate', with_audited: true do
  include DfESignInHelpers

  scenario 'Support agent sends a survey email to a candidate' do
    given_i_am_a_support_user
    and_there_is_an_application
    and_i_visit_the_support_page

    when_i_click_on_the_application
    then_i_should_be_on_the_view_application_page

    when_i_click_on_request_feedback
    then_i_see_a_confirmation_page

    when_i_click_to_confirm_sending_the_survey_email
    then_i_see_the_survey_email_is_successfully_sent
    and_i_am_sent_back_to_the_application_form_with_a_flash
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application
    @application = create(:completed_application_form, first_name: 'Darlene', last_name: 'Alderson')
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_the_application
    click_on @application.candidate.email_address
  end

  def then_i_should_be_on_the_view_application_page
    expect(page).to have_content @application.candidate.email_address
  end

  def when_i_click_on_request_feedback
    click_link(t('survey_emails.send.link'))
  end

  def then_i_see_a_confirmation_page
    expect(page).to have_content(t('survey_emails.send.confirm', candidate_name: 'Darlene Alderson'))
  end

  def when_i_click_to_confirm_sending_the_survey_email
    click_button t('survey_emails.send.button')
  end

  def then_i_see_the_survey_email_is_successfully_sent
    open_email(@application.candidate.email_address)

    expect(current_email.subject).to have_content(t('survey_emails.subject.initial'))
  end

  def and_i_am_sent_back_to_the_application_form_with_a_flash
    expect(page).to have_content(t('survey_emails.send.success'))
  end
end
