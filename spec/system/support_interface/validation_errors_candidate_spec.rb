require 'rails_helper'

RSpec.describe 'Validation errors Candidate' do
  include CandidateHelper
  include DfESignInHelpers

  scenario 'Review validation errors' do
    given_i_am_a_candidate
    and_i_enter_invalid_contact_details

    given_i_am_a_support_user

    when_i_navigate_to_the_validation_errors_page
    then_i_see_a_list_of_error_groups

    when_i_click_on_a_group
    then_i_see_a_list_of_individual_errors

    when_i_click_on_link_in_breadcrumb_trail
    then_i_be_back_on_index_page
  end

  def given_i_am_a_candidate
    create_and_sign_in_candidate
  end

  def and_i_enter_invalid_contact_details
    visit candidate_interface_details_path
    click_link_or_button t('page_titles.contact_information')
    fill_in t('application_form.contact_details.phone_number.label'), with: 'ABCDEF'
    click_link_or_button t('save_and_continue')
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_navigate_to_the_validation_errors_page
    visit support_interface_path
    click_link_or_button 'Performance'
    click_link_or_button 'Validation errors'
    click_link_or_button 'Candidate validation errors'
  end

  def then_i_see_a_list_of_error_groups
    @validation_error = ValidationError.last
    expect(page).to have_content('Contact details form: Phone number')
    expect(page).to have_content('1')
  end

  def when_i_click_on_a_group
    click_link_or_button('Phone number')
  end

  def then_i_see_a_list_of_individual_errors
    expect(page).to have_content(Time.zone.now.to_fs(:govuk_date_and_time))
    expect(page).to have_content('Showing errors on the Phone number field in Contact details form by all users')
    expect(page).to have_content('Contact details form: Phone number')
    expect(page).to have_content('ABCDEF')
  end

  def when_i_click_on_link_in_breadcrumb_trail
    click_link_or_button 'Validation errors'
  end

  def then_i_be_back_on_index_page
    expect(page).to have_current_path(support_interface_validation_errors_path)
  end
end
