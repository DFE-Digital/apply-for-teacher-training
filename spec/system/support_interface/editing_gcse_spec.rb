require 'rails_helper'

RSpec.feature 'Editing GCSE' do
  include DfESignInHelpers

  scenario 'Support user edits GCSE', with_audited: true do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_the_first_gcse
    then_i_should_see_a_prepopulated_form

    when_i_provide_an_invalid_award_year
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
    create(:gcse_qualification, subject: 'maths', award_year: '1999', application_form: @form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_the_first_gcse
    within('[data-qa="gcse-qualification"]') do
      click_link 'Change'
    end
  end

  def then_i_should_see_a_prepopulated_form
    expect(page).to have_content('Edit Maths GCSE')
    expect(page).to have_selector("input[value='1999']")
  end

  def when_i_provide_an_invalid_award_year
    fill_in 'Award year', with: '201'
    fill_in 'Audit log comment', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_an_error_message
    expect(page).to have_content 'Enter a valid award year (for exmaple, 2001)'
  end

  def when_i_update_the_form
    fill_in 'Award year', with: '2001'
    fill_in 'Audit log comment', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_submit_the_form
    click_button 'Update'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'GCSE award year updated'
  end

  def and_i_should_see_the_new_details
    within('.app-qualification') do
      expect(page).to have_content '2001'
    end
  end

  def and_i_should_see_my_details_comment_in_the_audit_log
    click_link 'History'
    expect(page).to have_content 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end
end
