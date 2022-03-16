require 'rails_helper'

RSpec.feature 'Editing immigration status' do
  include DfESignInHelpers

  scenario 'Support user edits immigration status', with_audited: true do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    i_should_not_see_the_residency_details_column

    when_i_click_the_change_link_next_right_to_work
    and_i_choose_yes
    and_i_continue
    i_should_see_the_residency_details_column

    when_i_click_change_residency_details
    and_i_choose_other_and_fill_in_the_details
    and_i_continue
    then_i_should_see_the_text_i_submitted
  end
end

def given_i_am_a_support_user
  sign_in_as_support_user
end

def and_an_application_exists
  @form = create(:completed_application_form, first_nationality: 'French', right_to_work_or_study: 'no')
end

def when_i_visit_the_application_page
  visit support_interface_application_form_path(@form)
end

def i_should_not_see_the_residency_details_column
  expect(page).not_to have_content 'Residency details'
end

def i_should_see_the_residency_details_column
  expect(page).to have_content 'Residency details'
end

def when_i_click_change_residency_details
  click_link 'Change residency details'
end

def when_i_click_the_change_link_next_right_to_work
  click_link('Change right to work or study')
end

def and_i_choose_yes
  choose 'Yes'
  fill_in 'support_interface_application_forms_immigration_right_to_work_form[audit_comment]', with: 'Updated as part of Zendesk ticket #12345'
end

def and_i_continue
  click_button 'Save and continue'
end

def and_i_choose_other_and_fill_in_the_details
  choose 'Other'
  fill_in 'support_interface_application_forms_immigration_status_form[right_to_work_or_study_details]', with: 'I live here forever'
  fill_in 'support_interface_application_forms_immigration_status_form[audit_comment]', with: 'Updated as part of Zendesk ticket #12345'
end

def then_i_should_see_the_text_i_submitted
  expect(page).to have_content 'I live here forever'
end
