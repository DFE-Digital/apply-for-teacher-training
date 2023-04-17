require 'rails_helper'

RSpec.feature 'Delete a candidate application (by anonymising all of their data)' do
  include DfESignInHelpers

  scenario 'Delete a candidate application', with_audited: true do
    given_i_am_a_support_user
    and_there_is_an_unsubmitted_application

    when_i_visit_the_application_page
    then_i_see_a_delete_application_link

    when_i_click_delete_application
    then_i_see_a_confirmation_page_prompting_for_an_audit_comment

    when_i_click_continue
    then_i_see_a_validation_error

    # when_i_add_an_audit_comment_and_click_continue
    # then_i_see_the_application_page
    # and_the_application_is_now_deleted
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_unsubmitted_application
    @application_form = create(
      :application_form,
      :completed,
      application_choices_count: 3,
      submitted_at: nil,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_form.id)
  end

  def then_i_see_a_delete_application_link
    expect(page).to have_button('Delete all application data')
  end

  def when_i_click_delete_application
    click_button('Delete all application data')
  end

  def then_i_see_a_confirmation_page_prompting_for_an_audit_comment
    expect(page).to have_current_path(
      support_interface_confirm_delete_application_form_path(
        application_form_id: @application_form.id,
      ),
    )
    expect(page).to have_content('Are you sure you want to delete all the personal information associated with this application?')
    expect(page).to have_content('This operation cannot be undone.')
  end

  def when_i_click_continue
    click_on 'Continue'
  end

  def then_i_see_a_validation_error
    expect(page).to have_current_path(
      support_interface_delete_application_form_path(application_form_id: @application_form.id),
    )
    expect(page).to have_content('Enter a Zendesk ticket URL')
    expect(page).to have_content('Select that you have read the guidance')
  end

  def when_i_add_an_audit_comment_and_click_continue
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/123'
    check 'I have read the guidance'
    click_on 'Continue'
  end

  def then_i_see_the_application_page
    expect(page).to have_current_path(support_interface_application_form_path(@application_choice.application_form_id))
  end

  def and_the_application_is_now_deleted
    
  end
end
