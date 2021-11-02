require 'rails_helper'

RSpec.feature 'A candidate withdraws with upcoming interviews' do
  include CandidateHelper

  scenario 'successful withdrawal' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_an_application_choice_with_an_upcoming_interview

    when_i_visit_the_application_dashboard
    and_i_click_the_withdraw_link_on_my_first_choice
    then_i_see_a_confirmation_page

    when_i_click_to_confirm_withdrawal
    then_my_application_should_be_withdrawn
    and_the_provider_has_received_an_email
    and_the_interview_has_been_cancelled
    and_i_received_an_interview_cancelled_email
  end

  def given_i_am_signed_in_as_a_candidate
    create_and_sign_in_candidate
  end

  def and_i_have_an_application_choice_with_an_upcoming_interview
    form = create(:completed_application_form, :with_completed_references, candidate: current_candidate)
    @application_choice = create(:application_choice, :with_scheduled_interview, application_form: form)
    create(:application_choice, :awaiting_provider_decision, application_form: form)
    @provider_user = create(:provider_user, :with_notifications_enabled)
    create(:provider_permissions, provider_id: @application_choice.provider.id, provider_user_id: @provider_user.id)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_form_path
  end

  def and_i_click_the_withdraw_link_on_my_first_choice
    click_link 'Withdraw', match: :first
  end

  def then_i_see_a_confirmation_page
    expect(page).to have_content('Are you sure you want to withdraw this course choice?')
  end

  def when_i_click_to_confirm_withdrawal
    click_button 'Yes I’m sure – withdraw this course choice'
  end

  def then_my_application_should_be_withdrawn
    expect(page).to have_content('Course choice withdrawn')
  end

  def and_the_provider_has_received_an_email
    open_email(@provider_user.email_address)
    expect(current_email.subject).to have_content "#{@application_choice.application_form.full_name} (#{@application_choice.application_form.support_reference}) withdrew their application"
  end

  def and_the_interview_has_been_cancelled
    interview = @application_choice.interviews.first.reload
    expect(interview.cancelled_at).not_to be_nil
    expect(interview.cancellation_reason).to eq('You withdrew your application.')
  end

  def and_i_received_an_interview_cancelled_email
    open_email(current_candidate.email_address)
    expect(current_email.subject).to have_content('Interview cancelled')
    expect(current_email.text).to have_content('You withdrew your application.')
  end
end
