require 'rails_helper'

RSpec.feature 'Editing application details' do
  include DfESignInHelpers

  scenario 'Support user edits applicant details' do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_the_phone_number
    and_i_supply_a_new_phone_number

    then_i_should_see_a_flash_message
    and_i_should_see_the_new_phone_number
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:completed_application_form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_the_phone_number
    within('[data-qa="personal-details"]') do
      click_on 'Change'
    end
  end

  def and_i_supply_a_new_phone_number
    fill_in 'support_interface_application_forms_edit_applicant_details_form[phone_number]', with: '0891 50 50 50'

    click_button 'Update'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'Applicant details updated'
  end

  def and_i_should_see_the_new_phone_number
    expect(page).to have_content '0891 50 50 50'
  end
end
