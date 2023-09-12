require 'rails_helper'

RSpec.feature 'Editing GCSE' do
  include DfESignInHelpers

  scenario 'Support user edits GCSE constituent grade', :with_audited do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_the_first_gcse
    then_i_should_see_a_prepopulated_form

    when_i_provide_an_invalid_grade
    and_i_submit_the_form
    then_i_see_an_error_message

    when_i_update_the_form
    and_i_submit_the_form
    then_i_should_see_a_flash_message
    and_i_should_see_the_new_details
    and_i_should_see_my_details_comment_in_the_audit_log
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:completed_application_form)
    create(:gcse_qualification, :science_triple_award, application_form: @form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_the_first_gcse
    within page.find('.app-qualification__value', text: 'Chemistry') do
      click_link 'Change grade'
    end
  end

  def then_i_should_see_a_prepopulated_form
    expect(page).to have_content('Edit Science triple award GCSE')
    expect(page).to have_selector("input[value='B']")
  end

  def when_i_provide_an_invalid_grade
    fill_in 'Grade', with: ''
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_an_error_message
    expect(page).to have_content 'Enter the grade'
  end

  def when_i_update_the_form
    fill_in 'Grade', with: 'C'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_submit_the_form
    click_button 'Update'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'GCSE grade updated'
  end

  def and_i_should_see_the_new_details
    expect(page).to have_content('C (Chemistry)')
  end

  def and_i_should_see_my_details_comment_in_the_audit_log
    click_link 'History'
    expect(page).to have_content 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end
end
