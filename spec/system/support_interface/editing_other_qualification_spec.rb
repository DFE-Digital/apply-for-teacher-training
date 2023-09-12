require 'rails_helper'

RSpec.feature 'Editing other qualification' do
  include DfESignInHelpers

  scenario 'Support user edits award year and grade', :with_audited do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_the_first_qualification
    then_i_should_see_a_prepopulated_form_for_award_year

    when_i_provide_an_invalid_award_year
    and_i_submit_the_form
    then_i_see_an_error_message

    when_i_update_the_form
    and_i_submit_the_form
    then_i_should_see_a_flash_message
    and_i_should_see_the_new_details
    and_i_should_see_my_details_comment_in_the_audit_log

    when_i_click_the_change_grade_link_next_to_the_first_qualification
    then_i_should_see_a_prepopulated_form_for_grade

    when_i_provide_an_invalid_grade
    and_i_submit_the_form
    then_i_am_told_to_enter_a_valid_grade

    when_i_enter_a_valid_grade
    and_i_submit_the_form
    then_i_should_see_a_flash_message_telling_me_the_grade_has_been_updated
    and_i_should_see_the_new_grade
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:completed_application_form)
    create(:other_qualification, subject: 'Forensic Science', award_year: 1.year.ago, application_form: @form, grade: 'C')
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_the_first_qualification
    within('[data-qa="qualifications-table-a-levels-and-other-qualifications"]') do
      click_link 'Change award year'
    end
  end

  def then_i_should_see_a_prepopulated_form_for_award_year
    expect(page).to have_content('Edit Forensic science qualification details')
    expect(page).to have_selector("input[value='#{1.year.ago}']")
  end

  def when_i_provide_an_invalid_award_year
    fill_in 'Award year', with: '201'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_an_error_message
    expect(page).to have_content 'Enter a real award year'
  end

  def when_i_update_the_form
    fill_in 'Award year', with: Time.zone.now.year
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_submit_the_form
    click_button 'Update'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'Qualification award year updated'
  end

  def and_i_should_see_the_new_details
    within('[data-qa="qualifications-table-a-levels-and-other-qualifications"]') do
      expect(page).to have_content Time.zone.now.year
    end
  end

  def and_i_should_see_my_details_comment_in_the_audit_log
    click_link 'History'
    expect(page).to have_content 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def when_i_click_the_change_grade_link_next_to_the_first_qualification
    visit support_interface_application_form_path(@form)
    within('[data-qa="qualifications-table-a-levels-and-other-qualifications"]') do
      click_link 'Change grade'
    end
  end

  def then_i_should_see_a_prepopulated_form_for_grade
    expect(page).to have_content('Edit Forensic science qualification details')
    expect(page).to have_selector("input[value='C']")
  end

  def when_i_provide_an_invalid_grade
    fill_in 'Grade', with: 'hello'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_am_told_to_enter_a_valid_grade
    expect(page).to have_content 'Enter a valid grade'
  end

  def when_i_enter_a_valid_grade
    fill_in 'Grade', with: 'A'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_should_see_a_flash_message_telling_me_the_grade_has_been_updated
    expect(page).to have_content 'Qualification grade updated'
  end

  def and_i_should_see_the_new_grade
    within('[data-qa="qualifications-table-a-levels-and-other-qualifications"]') do
      expect(page).to have_content 'A'
    end
  end
end
