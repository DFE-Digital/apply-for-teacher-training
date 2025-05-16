require 'rails_helper'

RSpec.describe 'Editing degree' do
  include DfESignInHelpers

  scenario 'Support user edits uk degree', :with_audited do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_the_first_degree
    then_i_see_a_prepopulated_form

    when_i_update_the_form
    and_i_submit_the_form
    then_i_see_a_flash_message
    and_i_see_the_new_details
    and_i_see_my_details_comment_in_the_audit_log
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:completed_application_form)
    create(:degree_qualification, subject: 'maths', start_year: '1995', award_year: '1999', application_form: @form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_the_first_degree
    within('[data-qa="degree-qualification"]') do
      click_link_or_button 'Change'
    end
  end

  def then_i_see_a_prepopulated_form
    expect(page).to have_content('Edit Maths degree')
    expect(page).to have_css("input[value='1999']")

    expect(page).to have_no_content 'Does the candidate have an ENIC reference number?'
  end

  def when_i_update_the_form
    fill_in 'Award year', with: '2001'
    fill_in 'Start year', with: '1996'
    fill_in 'Audit log comment', with: 'Got to change it'
  end

  def and_i_submit_the_form
    click_link_or_button 'Update'
  end

  def then_i_see_a_flash_message
    expect(page).to have_content 'Degree updated'
  end

  def and_i_see_the_new_details
    within('.app-qualification') do
      expect(page).to have_content '1996'
      expect(page).to have_content '2001'
    end
  end

  def and_i_see_my_details_comment_in_the_audit_log
    click_link_or_button 'History'
    expect(page).to have_content 'Got to change it'
  end
end
