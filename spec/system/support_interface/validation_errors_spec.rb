require 'rails_helper'

RSpec.feature 'Validation errors' do
  include CandidateHelper
  include DfESignInHelpers

  around do |example|
    Timecop.freeze(Time.zone.local(2020, 4, 24, 12, 35, 46)) do
      example.run
    end
  end

  scenario 'Review validation errors' do
    given_i_am_a_candidate
    and_the_track_validation_errors_feature_is_on
    and_i_enter_invalid_contact_details

    given_i_am_a_support_user

    when_i_navigate_to_the_validation_errors_page
    then_i_should_see_a_list_of_error_groups

    when_i_click_on_a_group
    then_i_should_see_a_list_of_individual_errors

    when_i_click_on_link_in_breadcrumb_trail
    then_i_should_be_back_on_index_page
  end

  def given_i_am_a_candidate
    create_and_sign_in_candidate
  end

  def and_the_track_validation_errors_feature_is_on
    FeatureFlag.activate('track_validation_errors')
  end

  def and_i_enter_invalid_contact_details
    visit candidate_interface_application_form_path
    click_link t('page_titles.contact_details')
    fill_in t('application_form.contact_details.phone_number.label'), with: 'ABCDEF'
    click_button t('application_form.contact_details.base.button')
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_navigate_to_the_validation_errors_page
    visit support_interface_path
    click_link 'Performance'
    click_link 'Validation errors'
  end

  def then_i_should_see_a_list_of_error_groups
    @validation_error = ValidationError.last
    expect(page).to have_content(@validation_error.form_object)
    expect(page).to have_content('1')
  end

  def when_i_click_on_a_group
    click_on(@validation_error.form_object)
  end

  def then_i_should_see_a_list_of_individual_errors
    expect(page).to have_current_path(support_interface_validation_error_path(@validation_error.form_object))
    expect(page).to have_content(@validation_error.request_path)
    expect(page).to have_content('24 April 2020 at 12:35pm')
    expect(page).to have_content(/Attribute\s+phone_number/)
    expect(page).to have_content(/Value\s+"ABCDEF"/)
    expect(page).to have_content(/Errors\s+Enter a phone number/)
  end

  def when_i_click_on_link_in_breadcrumb_trail
    click_link 'Validation errors'
  end

  def then_i_should_be_back_on_index_page
    expect(page).to have_current_path(support_interface_validation_errors_path)
  end
end
