require 'rails_helper'

RSpec.feature 'Validation errors candidate summary' do
  include CandidateHelper
  include DfESignInHelpers

  scenario 'Review validation error summary' do
    given_i_am_a_candidate
    and_i_enter_invalid_contact_details

    given_i_am_a_support_user

    when_i_navigate_to_the_validation_errors_summary_page
    then_i_should_see_numbers_for_the_past_week_month_and_all_time

    when_i_click_on_link_to_drilldown_contact_details_form_errors
    then_i_should_see_errors_for_contact_details_form_only
  end

  def given_i_am_a_candidate
    create_and_sign_in_candidate
  end

  def and_i_enter_invalid_contact_details
    visit candidate_interface_application_form_path
    click_link t('page_titles.contact_information')
    fill_in t('application_form.contact_details.phone_number.label'), with: 'ABCDEF'
    click_button t('save_and_continue')
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_navigate_to_the_validation_errors_summary_page
    visit support_interface_path
    click_link 'Performance'
    click_link 'Validation errors'
    click_link 'Candidate validation errors'
    click_link 'Validation error summary'
  end

  def then_i_should_see_numbers_for_the_past_week_month_and_all_time
    expect(find('table').all('tr')[2].text).to eq 'Contact details form Phone number 1 1 1 1 1 1'
  end

  def when_i_click_on_link_to_drilldown_contact_details_form_errors
    click_link 'Contact details form'
  end

  def then_i_should_see_errors_for_contact_details_form_only
    expect(page).to have_current_path(
      support_interface_validation_errors_candidate_search_path(form_object: 'CandidateInterface::ContactDetailsForm'),
    )
  end
end
