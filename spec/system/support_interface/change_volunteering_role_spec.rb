require 'rails_helper'

RSpec.feature 'Change volunteering role' do
  include DfESignInHelpers

  scenario 'Change an individual volunteering role on an application form', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_with_a_volunteering_role

    when_i_visit_the_application_page
    and_i_click_to_change_volunteering_role

    when_i_click_update
    then_i_see_an_audit_comment_validation_error

    when_i_add_the_invalid_details
    and_i_click_update
    then_i_see_validation_errors

    when_i_add_the_valid_details
    and_i_click_update
    then_i_see_the_success_message
    and_i_can_see_the_updated_volunteering_role
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_with_a_volunteering_role
    @application_form = create(:application_form, :submitted)
    @volunteering_role = create(
      :application_volunteering_experience,
      application_form: @application_form,
      currently_working: true,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_form)
  end

  def and_i_click_to_change_volunteering_role
    click_link(href: support_interface_application_form_edit_volunteering_role_path(@application_form, @volunteering_role))
  end

  def when_i_click_update
    click_button 'Update details'
  end
  alias_method :and_i_click_update, :when_i_click_update

  def then_i_see_an_audit_comment_validation_error
    expect(page).to have_content('Enter a Zendesk ticket URL')
  end

  def when_i_add_the_invalid_details
    fill_in 'Your role', with: ''
    fill_in 'Organisation where you gained experience or volunteered', with: ''
  end

  def then_i_see_validation_errors
    expect(page).to have_content('Enter your role')
    expect(page).to have_content('Enter the organisation where you gained experience or volunteered')
  end

  def when_i_add_the_valid_details
    fill_in 'Your role', with: 'Senior role'
    fill_in 'Organisation where you gained experience or volunteered', with: 'New employer'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_the_success_message
    expect(page).to have_content('Volunteering role updated')
  end

  def and_i_can_see_the_updated_volunteering_role
    expect(page).to have_content('Senior role')
    expect(page).to have_content('New employer')
  end
end
