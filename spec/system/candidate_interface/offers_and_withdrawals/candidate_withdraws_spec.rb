require 'rails_helper'

RSpec.feature 'A candidate withdraws her application' do
  include CandidateHelper

  # bullet complains about wanting an includes on associated objects.
  # You cannot call includes on a build_stubbed object.
  # Our mailer previews are reliant on build_stubbed so we need to exclude this test.

  before do
    Bullet.raise = false
  end

  after do
    Bullet.raise = true
  end

  scenario 'successful withdrawal' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_multiple_application_choice_awaiting_provider_decision

    when_i_visit_the_application_dashboard
    and_i_click_the_withdraw_link_on_my_first_choice
    then_i_see_a_confirmation_page

    when_i_click_to_confirm_withdrawal
    then_i_see_the_withdraw_choice_feedback_page
    and_my_application_should_be_withdrawn
    and_the_provider_has_received_an_email

    when_i_submit_the_questionnaire_without_choosing_options
    then_i_am_told_i_need_to_choose_whether_i_want_to_provide_feedback
    and_i_am_asked_if_i_can_be_contacted_about_my_feeedback

    when_i_fill_in_my_feedback
    and_i_click_continue
    then_i_see_my_application_dashboard
    and_i_am_thanked_for_my_feedback

    when_i_try_to_visit_the_withdraw_page
    then_i_see_the_page_not_found

    when_i_visit_the_application_dashboard
    and_i_click_the_withdraw_link_on_my_final_choice
    then_i_see_a_confirmation_page

    when_i_click_to_confirm_withdrawal
    then_my_application_should_be_withdrawn
    and_the_candidate_has_received_an_email_with_information_on_apply_again
  end

  def given_i_am_signed_in_as_a_candidate
    create_and_sign_in_candidate
  end

  def and_i_have_multiple_application_choice_awaiting_provider_decision
    form = create(:completed_application_form, :with_completed_references, candidate: current_candidate)
    @application_choice = create(:application_choice, :awaiting_provider_decision, application_form: form)
    @application_choice2 = create(:application_choice, :awaiting_provider_decision, application_form: form)
    @provider_user = create(:provider_user, :with_notifications_enabled)
    create(:provider_permissions, provider_id: @application_choice.provider.id, provider_user_id: @provider_user.id)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_form_path
  end

  def and_i_click_the_withdraw_link_on_my_first_choice
    click_link 'Withdraw', match: :first
  end

  def and_i_click_the_withdraw_link_on_my_final_choice
    and_i_click_the_withdraw_link_on_my_first_choice
  end

  def then_i_see_a_confirmation_page
    expect(page).to have_content('Are you sure you want to withdraw this course choice?')
  end

  def when_i_click_to_confirm_withdrawal
    click_button 'Yes I’m sure – withdraw this course choice'
  end

  def then_i_see_the_withdraw_choice_feedback_page
    expect(page).to have_current_path candidate_interface_withdrawal_feedback_path(@application_choice.id)
  end

  def and_my_application_should_be_withdrawn
    expect(page).to have_content('Course choice withdrawn')
  end

  def then_my_application_should_be_withdrawn
    and_my_application_should_be_withdrawn
  end

  def when_i_try_to_visit_the_withdraw_page
    visit candidate_interface_withdraw_path(id: @application_choice.id)
  end

  def then_i_see_the_page_not_found
    expect(page).to have_content('Page not found')
  end

  def and_the_provider_has_received_an_email
    open_email(@provider_user.email_address)
    expect(current_email.subject).to have_content "#{@application_choice.application_form.full_name} (#{@application_choice.application_form.support_reference}) withdrew their application"
  end

  def when_i_submit_the_questionnaire_without_choosing_options
    click_button t('continue')
  end

  def then_i_am_told_i_need_to_choose_whether_i_want_to_provide_feedback
    expect(page).to have_content 'Will you give a reason for withdrawing your course choice?'
  end

  def and_i_am_asked_if_i_can_be_contacted_about_my_feeedback
    expect(page).to have_content 'Can we contact you about your feedback?'
  end

  def when_i_fill_in_my_feedback
    choose 'Yes, I’d like to share my reason with the Department for Education'
    fill_in 'candidate-interface-withdrawal-feedback-form-explanation-field', with: 'I do not want to go there.'
    choose 'Yes, you can contact me'
    fill_in 'candidate-interface-withdrawal-feedback-form-contact-details-field', with: 'Anytime, 012345 678900'
  end

  def and_i_click_continue
    click_button t('continue')
  end

  def then_i_see_my_application_dashboard
    expect(page).to have_current_path candidate_interface_application_complete_path
  end

  def and_i_am_thanked_for_my_feedback
    expect(page).to have_content 'Thank you for your feedback.'
  end

  def and_the_candidate_has_received_an_email_with_information_on_apply_again
    open_email(@application_choice.application_form.candidate.email_address)
    expect(current_email.subject).to have_content 'You’ve withdrawn your application'
  end
end
