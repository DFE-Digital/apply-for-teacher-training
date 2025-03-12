require 'rails_helper'

RSpec.describe 'Revert a withdrawn application choice' do
  include DfESignInHelpers

  scenario 'Support user can reverse a course choice that has been withdrawn in error' do
    given_i_am_a_support_user
    and_there_is_a_withdrawn_application_in_the_system
    and_i_visit_the_support_page

    when_i_click_on_an_application
    and_i_am_on_the_correct_application_page
    then_i_see_the_withdrawn_course_choice

    when_i_click_on_the_revert_withdrawal_link
    then_i_see_the_revert_withdrawal_page
    when_i_click_continue
    then_i_am_told_to_confirm_i_have_followed_the_guidance

    when_i_confirm_reverting_a_withdrawal
    and_i_click_continue
    when_i_provide_an_invalid_zendesk_ticket_link
    and_i_click_continue
    then_i_am_told_that_i_need_to_provide_a_valid_zendesk_ticket_link

    when_i_provide_a_valid_zendesk_ticket
    and_i_confirm_reverting_a_withdrawal
    and_i_click_continue
    then_i_am_redirected_to_the_application_form_page
    and_i_see_the_choice_is_awaiting_provider_decision
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_withdrawn_application_in_the_system
    @application_form = create(:completed_application_form)

    @application_choice = create(
      :application_choice,
      :withdrawn,
      application_form: @application_form,
    )
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application
    click_link_or_button @application_form.full_name
  end

  def and_i_am_on_the_correct_application_page
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
  end

  def then_i_see_the_withdrawn_course_choice
    within(first('.app-summary-card__body')) do
      expect(page).to have_content('Withdrawn')
    end
  end

  def when_i_click_on_the_revert_withdrawal_link
    click_link_or_button 'Revert withdrawal'
  end

  def then_i_see_the_revert_withdrawal_page
    expect(page).to have_current_path support_interface_application_form_application_choice_revert_withdrawal_path(@application_form.id, @application_choice.id)
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_am_told_to_confirm_i_have_followed_the_guidance
    expect(page).to have_content 'Select that you have read the guidance'
  end

  def when_i_confirm_reverting_a_withdrawal
    check 'I have read the guidance'
  end
  alias_method :and_i_confirm_reverting_a_withdrawal, :when_i_confirm_reverting_a_withdrawal

  def when_i_provide_an_invalid_zendesk_ticket_link
    fill_in('Zendesk ticket URL', with: 'This wont work')
  end

  def then_i_am_told_that_i_need_to_provide_a_valid_zendesk_ticket_link
    expect(page).to have_content 'Enter a valid Zendesk ticket URL'
  end

  def when_i_provide_a_valid_zendesk_ticket
    fill_in('Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/example')
  end

  def then_i_am_redirected_to_the_application_form_page
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
  end

  def and_i_see_the_choice_is_awaiting_provider_decision
    within(first('.app-summary-card__body')) do
      expect(page).to have_content('Awaiting provider decision')
    end
  end
end
