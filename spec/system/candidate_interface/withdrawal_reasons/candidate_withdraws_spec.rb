require 'rails_helper'

RSpec.describe 'A candidate withdraws their application', :bullet do
  include CandidateHelper
  include WithdrawalReasonsTestHelpers

  scenario 'successful withdrawal', time: mid_cycle do
    given_i_am_signed_in_with_one_login
    and_i_have_multiple_application_choice_awaiting_provider_decision

    when_i_visit_my_applications
    and_i_click_the_withdraw_link_on_my_first_choice
    and_i_select_some_reasons_and_confirm

    then_the_provider_has_received_an_email

    when_i_try_to_visit_the_withdraw_page
    then_i_see_the_page_not_found

    when_i_visit_my_applications
    and_i_click_the_withdraw_link_on_my_final_choice
    and_i_select_some_reasons_and_confirm

    then_the_candidate_has_received_an_email
  end

  scenario 'withdrawing after the apply deadline', time: after_apply_deadline do
    given_i_am_signed_in_with_one_login
    and_i_have_one_application_choice_awaiting_provider_decision

    when_i_visit_my_applications
    and_i_click_the_withdraw_link_on_my_first_choice
    and_i_select_some_reasons_and_confirm

    then_i_see_the_carry_over_content
    and_i_can_carry_over_my_application
  end

  scenario 'withdrawal for application choice with interviewing status', time: mid_cycle do
    given_i_am_signed_in_with_one_login
    and_i_have_an_application_choice_with_the_status_interviewing

    when_i_visit_my_applications
    and_i_click_the_withdraw_link_on_my_application_choice_with_the_status_interviewing
    and_i_select_the_level_one_reason('Other')
    and_i_enter_other_details
    and_i_click_on('Continue')
    and_i_click_on('Yes I’m sure – withdraw this application')
    then_i_have_withdrawn_from_the_course(@interviewing_application_choice)
    and_the_interviews_have_been_cancelled
  end

  def and_i_have_multiple_application_choice_awaiting_provider_decision
    form = create(:completed_application_form, :with_completed_references, candidate: current_candidate)
    @application_choice = create(:application_choice, :awaiting_provider_decision, application_form: form)
    @second_application_choice = create(:application_choice, :awaiting_provider_decision, application_form: form)
    @provider_user = create(:provider_user, :with_notifications_enabled)
    create(:provider_permissions, provider_id: @application_choice.provider.id, provider_user_id: @provider_user.id)
  end

  def and_i_have_one_application_choice_awaiting_provider_decision
    form = create(:completed_application_form, :with_completed_references, candidate: current_candidate)
    @application_choice = create(:application_choice, :awaiting_provider_decision, application_form: form)
  end

  def and_i_have_an_application_choice_with_the_status_interviewing
    form = create(:completed_application_form, :with_completed_references, candidate: current_candidate)
    @interviewing_application_choice = create(:application_choice, :interviewing, application_form: form)
  end

  def and_i_click_the_withdraw_link_on_my_first_choice
    when_i_click_to_view_my_application
    when_i_click_to_withdraw_my_application
  end

  def and_i_click_the_withdraw_link_on_my_final_choice
    click_link_or_button @second_application_choice.course.provider.name
    when_i_click_to_withdraw_my_application
  end

  def and_i_click_the_withdraw_link_on_my_application_choice_with_the_status_interviewing
    click_link_or_button @interviewing_application_choice.course.provider.name
    when_i_click_to_withdraw_my_application
  end

  def and_i_enter_other_details
    fill_in 'Details', with: 'Some details'
  end

  def and_the_interviews_have_been_cancelled
    @interviewing_application_choice.reload.interviews.each do |interview|
      expect(interview.cancelled_at).not_to be_nil
      expect(interview.cancellation_reason).to eq 'You withdrew your application.'
    end
  end

  def when_i_try_to_visit_the_withdraw_page
    visit candidate_interface_withdrawal_reasons_level_one_reason_new_path(id: @application_choice.id)
  end

  def then_i_see_the_page_not_found
    expect(page).to have_content('Page not found')
  end

  def then_the_provider_has_received_an_email
    open_email(@provider_user.email_address)
    expect(current_email.subject).to have_content "#{@application_choice.application_form.full_name} withdrew their application"
  end

  def then_i_see_the_carry_over_content
    expect(page).to have_current_path candidate_interface_application_choices_path

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      expect(page).to have_button 'Update your details'
    end
  end

  def and_i_can_carry_over_my_application
    click_on 'Update your details'
    expect(page).to have_current_path candidate_interface_details_path
  end

  def then_the_candidate_has_received_an_email
    open_email(@application_choice.application_form.candidate.email_address)
    expect(current_email.subject).to have_content 'You have withdrawn your application'
  end
end
