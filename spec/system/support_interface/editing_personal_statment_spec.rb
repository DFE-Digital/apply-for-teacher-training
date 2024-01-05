require 'rails_helper'

RSpec.feature 'Editing reference' do
  include DfESignInHelpers
  include CandidateHelper

  scenario 'Support user edits reference', :with_audited do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_on_personal_statement
    then_i_should_see_a_prepopulated_personal_statement_form

    when_i_submit_the_update_form
    then_i_should_see_blank_audit_comment_error_message

    when_i_complete_the_form
    and_i_submit_the_form
    then_i_should_be_told_i_updated_the_section
    and_i_should_see_the_new_personal_statement
    and_i_should_see_my_comment_in_the_audit_log
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @application_form = create(:completed_application_form, becoming_a_teacher: 'i can spel real gud')
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_form)
  end

  def and_i_click_the_change_link_on_personal_statement
    within('#personal-statement-section') do
      click_link_or_button 'Change', match: :first
    end
  end

  def then_i_should_see_a_prepopulated_personal_statement_form
    expect(page).to have_content('Edit personal statement')
    expect(page).to have_css('#support-interface-application-forms-edit-becoming-a-teacher-form-becoming-a-teacher-field', text: 'i can spel real gud')
  end

  def when_i_submit_the_update_form
    click_link_or_button 'Update'
  end

  def then_i_should_see_blank_audit_comment_error_message
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_becoming_a_teacher_form.attributes.audit_comment.blank')
  end

  def when_i_complete_the_form
    fill_in 'Edit personal statement', with: 'My spelling is phenomenal.'
    fill_in 'Audit log comment', with: 'Updated as part of Zen Desk ticket #12345'
  end

  def and_i_submit_the_form
    when_i_submit_the_update_form
  end

  def then_i_should_be_told_i_updated_the_section
    expect(page).to have_content 'Personal statement updated'
  end

  def and_i_should_see_the_new_personal_statement
    expect(page).to have_content 'My spelling is phenomenal.'
  end

  def and_i_should_see_my_comment_in_the_audit_log
    click_link_or_button 'History'
    expect(page).to have_content 'Updated as part of Zen Desk ticket #12345'
  end
end
