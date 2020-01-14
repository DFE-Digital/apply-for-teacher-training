require 'rails_helper'

RSpec.feature 'Send new referee request to candidate', with_audited: true do
  include DfESignInHelpers

  scenario 'Support agent sends a new referee request email to a candidate' do
    given_i_am_a_support_user
    and_there_is_an_application
    and_send_reference_email_feature_flag_is_on
    and_i_am_on_the_application_support_page

    when_i_click_on_send_email
    and_i_choose_provide_alternative_referee
    and_i_choose_referee_has_not_responded
    and_i_click_on_continue
    then_i_see_a_confirmation_page_for_not_responded_email

    when_i_click_to_confirm_sending_the_new_referee_request_email
    then_i_see_the_candidate_email_is_successfully_sent
    and_i_am_sent_back_to_the_application_form_with_a_flash

    when_i_click_on_the_history_for_the_application
    then_i_see_a_comment_stating_not_responded_email_has_been_sent

    when_i_am_on_the_application_support_page
    and_i_click_on_send_email
    and_i_choose_provide_alternative_referee
    and_i_choose_referees_email_has_bounced
    and_i_click_on_continue
    then_i_see_a_confirmation_page_for_bounced_email

    when_i_click_to_confirm_sending_the_new_referee_request_email
    then_i_see_the_candidate_email_is_successfully_sent_for_bounced_email
    and_i_am_sent_back_to_the_application_form_with_a_flash

    when_i_click_on_the_history_for_the_application
    then_i_see_a_comment_stating_email_address_bounced_email_has_been_sent

    when_i_am_on_the_application_support_page
    and_i_click_on_send_email
    and_i_choose_provide_alternative_referee
    and_i_choose_referees_email_has_refused
    and_i_click_on_continue
    then_i_see_a_confirmation_page_for_refused_email

    when_i_click_to_confirm_sending_the_new_referee_request_email
    then_i_see_the_candidate_email_is_successfully_sent_for_refused_email
    and_i_am_sent_back_to_the_application_form_with_a_flash

    when_i_click_on_the_history_for_the_application
    then_i_see_a_comment_stating_refused_email_has_been_sent
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application
    @application = create(:completed_application_form)
    @candidate_name = "#{@application.first_name} #{@application.last_name}"
    @candidate_email = @application.candidate.email_address
    @referee = @application.application_references.first
  end

  def and_send_reference_email_feature_flag_is_on
    FeatureFlag.activate('send_reference_email_via_support')
  end

  def and_i_am_on_the_application_support_page
    visit support_interface_application_form_path(@application)
  end

  def when_i_click_on_send_email
    click_link "Send email for #{@referee.name}"
  end

  def and_i_choose_provide_alternative_referee
    choose t('new_referee_request.option')
  end

  def and_i_choose_referee_has_not_responded
    choose t('new_referee_request.not_responded.option')
  end

  def and_i_click_on_continue
    click_on 'Continue'
  end

  def then_i_see_a_confirmation_page_for_not_responded_email
    expect(page).to have_content(t('new_referee_request.confirm', candidate_name: @candidate_name))
    expect(page).to have_content(t('new_referee_request.not_responded.confirm_text', referee_name: @referee.name))
  end

  def when_i_click_to_confirm_sending_the_new_referee_request_email
    click_on t('new_referee_request.confirm_button')
  end

  def then_i_see_the_candidate_email_is_successfully_sent
    open_email(@candidate_email)

    expect(current_email.subject).to have_content(t('new_referee_request.not_responded.subject', referee_name: @referee.name))
  end

  def and_i_am_sent_back_to_the_application_form_with_a_flash
    expect(page).to have_content @candidate_email
    expect(page).to have_content(t('new_referee_request.success'))
  end

  def when_i_click_on_the_history_for_the_application
    click_link 'History'
  end

  def then_i_see_a_comment_stating_not_responded_email_has_been_sent
    within('tbody tr:eq(1)') do
      expect(page).to have_content 'Comment on Application Form'
      expect(page).to have_content t('new_referee_request.not_responded.audit_comment', candidate_email: @candidate_email)
    end
  end

  def when_i_am_on_the_application_support_page
    visit support_interface_application_form_path(@application)
  end

  def and_i_click_on_send_email
    when_i_click_on_send_email
  end

  def and_i_choose_referees_email_has_bounced
    choose t('new_referee_request.email_bounced.option')
  end

  def then_i_see_a_confirmation_page_for_bounced_email
    expect(page).to have_content(t('new_referee_request.confirm', candidate_name: @candidate_name))
    expect(page).to have_content(t('new_referee_request.email_bounced.confirm_text', referee_name: @referee.name))
  end

  def then_i_see_the_candidate_email_is_successfully_sent_for_bounced_email
    open_email(@candidate_email)

    expect(current_email.subject).to have_content(t('new_referee_request.email_bounced.subject', referee_name: @referee.name))
  end

  def then_i_see_a_comment_stating_email_address_bounced_email_has_been_sent
    within('tbody tr:eq(1)') do
      expect(page).to have_content 'Comment on Application Form'
      expect(page).to have_content t('new_referee_request.email_bounced.audit_comment', candidate_email: @candidate_email)
    end
  end

  def and_i_choose_referees_email_has_refused
    choose t('new_referee_request.refused.option')
  end

  def then_i_see_a_confirmation_page_for_refused_email
    expect(page).to have_content(t('new_referee_request.confirm', candidate_name: @candidate_name))
    expect(page).to have_content(t('new_referee_request.refused.confirm_text', referee_name: @referee.name))
  end

  def then_i_see_the_candidate_email_is_successfully_sent_for_refused_email
    open_email(@candidate_email)

    expect(current_email.subject).to have_content(t('new_referee_request.refused.subject', referee_name: @referee.name))
  end

  def then_i_see_a_comment_stating_refused_email_has_been_sent
    within('tbody tr:eq(1)') do
      expect(page).to have_content 'Comment on Application Form'
      expect(page).to have_content t('new_referee_request.refused.audit_comment', candidate_email: @candidate_email)
    end
  end
end
