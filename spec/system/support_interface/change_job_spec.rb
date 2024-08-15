require 'rails_helper'

RSpec.describe 'Change job' do
  include DfESignInHelpers

  scenario 'Change an individual job on an application form', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_with_a_job

    when_i_visit_the_application_page
    and_i_click_to_change_job

    when_i_click_update
    then_i_see_an_audit_comment_validation_error

    when_i_add_the_invalid_details
    and_i_click_update
    then_i_see_validation_errors

    when_i_add_the_valid_details
    and_i_click_update
    then_i_see_the_success_message
    and_i_can_see_the_updated_job
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_with_a_job
    @application_form = create(:application_form, :submitted)
    @job = create(
      :application_work_experience,
      experienceable: @application_form,
      currently_working: true,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_form)
  end

  def and_i_click_to_change_job
    click_link_or_button(text: 'Change role details')
  end

  def when_i_click_update
    click_link_or_button 'Update details'
  end
  alias_method :and_i_click_update, :when_i_click_update

  def then_i_see_an_audit_comment_validation_error
    expect(page).to have_content('Enter a Zendesk ticket URL')
  end

  def when_i_add_the_invalid_details
    fill_in 'Name of employer', with: ''
    fill_in 'Job title or role', with: ''
  end

  def then_i_see_validation_errors
    expect(page).to have_content('Enter name of employer')
    expect(page).to have_content('Enter job title or role')
  end

  def when_i_add_the_valid_details
    fill_in 'Name of employer', with: 'New employer'
    fill_in 'Job title or role', with: 'Senior role'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_the_success_message
    expect(page).to have_content('Job updated')
  end

  def and_i_can_see_the_updated_job
    expect(page).to have_content('New employer')
    expect(page).to have_content('Senior role')
  end
end
