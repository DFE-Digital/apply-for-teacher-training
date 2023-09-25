require 'rails_helper'

RSpec.feature 'Revert an application choice to pending conditions' do
  include DfESignInHelpers

  scenario 'Revert a recruited application and return it to the `pending_conditions` status', :with_audited do
    given_i_am_a_support_user
    and_there_is_a_recruited_application

    when_i_visit_the_application_page
    then_i_see_a_revert_to_pending_conditions_link

    when_i_click_revert_to_pending_conditions
    then_i_see_a_confirmation_page_prompting_for_an_audit_comment

    when_i_click_continue
    then_i_see_a_validation_error

    when_i_add_an_audit_comment_and_click_continue
    then_i_see_the_application_page
    and_the_application_is_now_pending_conditions
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_recruited_application
    @application_choice = create(:application_choice, :recruited)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_choice.application_form_id)
  end

  def then_i_see_a_revert_to_pending_conditions_link
    expect(page).to have_link('Revert to pending conditions')
  end

  def when_i_click_revert_to_pending_conditions
    click_link('Revert to pending conditions')
  end

  def then_i_see_a_confirmation_page_prompting_for_an_audit_comment
    expect(page).to have_current_path(
      support_interface_application_form_application_choice_revert_to_pending_conditions_path(
        application_form_id: @application_choice.application_form_id,
        application_choice_id: @application_choice.id,
      ),
    )
    expect(page).to have_content('Are you sure you want to revert this application to pending conditions?')
  end

  def when_i_click_continue
    click_button 'Continue'
  end

  def then_i_see_a_validation_error
    expect(page).to have_current_path(
      support_interface_application_form_application_choice_revert_to_pending_conditions_path(
        application_form_id: @application_choice.application_form_id,
        application_choice_id: @application_choice.id,
      ),
    )
    expect(page).to have_content('Enter a Zendesk ticket URL')
    expect(page).to have_content('Select that you have read the guidance')
  end

  def when_i_add_an_audit_comment_and_click_continue
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/123'
    check 'I have read the guidance'
    click_button 'Continue'
  end

  def then_i_see_the_application_page
    expect(page).to have_current_path(support_interface_application_form_path(@application_choice.application_form_id))
  end

  def and_the_application_is_now_pending_conditions
    expect(@application_choice.reload.pending_conditions?).to be true
  end
end
