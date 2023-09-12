require 'rails_helper'

RSpec.feature 'Editing reference' do
  include DfESignInHelpers
  include CandidateHelper

  scenario 'Support user edits reference', :with_audited do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_on_subject_knowledge
    then_i_should_see_a_prepopulated_subject_knowledge_form

    when_i_submit_the_form
    then_i_should_see_blank_audit_comment_error_message

    when_i_complete_the_form
    and_i_submit_the_form
    then_i_should_be_told_i_updated_the_section
    and_i_should_see_the_new_subject_knowledge
    and_i_should_see_my_comment_in_the_audit_log
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @application_form = create(:completed_application_form, created_at: ApplicationForm::SINGLE_PERSONAL_STATEMENT_FROM - 1.day, subject_knowledge: 'I know a little.')
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_form)
  end

  def and_i_click_the_change_link_on_subject_knowledge
    within('#personal-statement-section') do
      all('a').last.click
    end
  end

  def then_i_should_see_a_prepopulated_subject_knowledge_form
    expect(page).to have_content('Edit subject knowledge')
    expect(page).to have_selector('#support-interface-application-forms-edit-subject-knowledge-form-subject-knowledge-field', text: 'I know a little.')
  end

  def when_i_submit_the_form
    click_button 'Update'
  end

  def then_i_should_see_blank_audit_comment_error_message
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_subject_knowledge_form.attributes.audit_comment.blank')
  end

  def when_i_complete_the_form
    fill_in 'Edit subject knowledge', with: 'I know a lot.'
    fill_in 'Audit log comment', with: 'Updated as part of Zen Desk ticket #12345'
  end

  def and_i_submit_the_form
    when_i_submit_the_form
  end

  def then_i_should_be_told_i_updated_the_section
    expect(page).to have_content 'Subject knowledge updated'
  end

  def and_i_should_see_the_new_subject_knowledge
    expect(page).to have_content 'I know a lot.'
  end

  def and_i_should_see_my_comment_in_the_audit_log
    click_on 'History'
    expect(page).to have_content 'Updated as part of Zen Desk ticket #12345'
  end
end
