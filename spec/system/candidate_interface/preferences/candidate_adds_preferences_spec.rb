require 'rails_helper'

RSpec.describe 'Candidate adds preferences' do
  let(:provider) { create(:provider) }
  let(:location_preferences) { [home_location, choice_location] }
  let(:home_location) { { within: 10.0, name: 'BN1 1AA' } }
  let(:choice_location) { { within: 10.0, name: 'BN1 2AA' } }
  let(:new_location) { { within: 10.0, name: 'BN1 3AA' } }
  let(:updated_location) { { within: 20.0, name: 'BN1 3AA' } }
  let(:new_locations) { [home_location, choice_location, new_location] }
  let(:updated_locations) { [home_location, choice_location, updated_location] }
  let(:client) { instance_double(GoogleMapsAPI::Client) }
  let(:api_response) do
    [
      { name: 'BN1 3AA', place_id: 'test_id' },
    ]
  end

  before do
    allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:autocomplete).and_return(api_response)
  end

  after { FeatureFlag.deactivate(:candidate_preferences) }

  scenario 'Candidate opts in to find a candidate' do
    given_i_am_signed_in
    and_feature_flag_is_enabled
    given_i_am_on_the_share_details_page

    when_i_click('Continue')
    then_i_am_redirected_to_opt_in_page
    when_i_click('Continue')
    then_i_get_an_error('Select weather to make your application details visible to other training providers')

    and_i_opt_in_to_find_a_candidate
    when_i_click('Continue')

    then_i_am_redirected_to_location_preferences(location_preferences)

    when_i_click('Back')
    then_i_am_redirected_to_opt_in

    when_i_click('Continue')
    then_i_am_redirected_to_location_preferences(location_preferences)

    when_i_click('Add another location')
    and_i_input_a_location
    when_i_click('Add location')
    then_i_am_redirected_to_location_preferences(new_locations)

    when_i_click_change_on_the_last_location
    and_i_edit_a_location
    when_i_click('Update location')
    then_i_am_redirected_to_location_preferences(updated_locations)

    when_i_check_dynamic_locations
    when_i_click('Continue')
    then_i_am_redirected_to_review_page

    when_i_click('Back')
    then_i_am_redirected_to_location_preferences(updated_locations)
    and_the_dynamic_locations_is_checked

    when_i_click('Continue')
    then_i_am_redirected_to_review_page

    when_i_click('Submit preferences')
    then_i_am_redirected_application_choices_with_success_message
  end

  scenario 'Candidate opts in to find a candidate without any locations' do
    given_i_am_signed_in
    and_feature_flag_is_enabled
    given_i_am_on_the_share_details_page

    when_i_click('Continue')
    then_i_am_redirected_to_opt_in_page
    when_i_click('Continue')
    then_i_get_an_error('Select weather to make your application details visible to other training providers')

    and_i_opt_in_to_find_a_candidate
    when_i_click('Continue')

    then_i_am_redirected_to_location_preferences(location_preferences)

    when_i_remove_all_locations
    then_i_am_redirected_to_location_preferences_without_locations

    when_i_check_dynamic_locations
    when_i_click('Continue')

    then_i_am_redirected_to_review_page_without_locations

    when_i_click('Submit preferences')
    then_i_am_redirected_application_choices_with_success_message
  end

  scenario 'Candidate opts out of find a candidate' do
    given_i_am_signed_in
    and_feature_flag_is_enabled

    visit new_candidate_interface_pool_opt_in_path
    and_i_opt_out_to_find_a_candidate
    when_i_click('Continue')

    then_i_am_redirected_to_application_choices
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application = create(
      :application_form,
      :completed,
      postcode: home_location[:name],
      candidate: @current_candidate,
    )
    site = create(
      :site,
      postcode: choice_location[:name],
      latitude: 53.4807593,
      longitude: -2.2426305,
      provider:,
    )
    course = create(:course, provider:)
    course_option = create(
      :course_option,
      site:,
      course:,
    )
    @choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application,
      course_option:,
    )
  end

  def and_i_opt_in_to_find_a_candidate
    choose 'Yes'
  end

  def and_i_opt_out_to_find_a_candidate
    choose 'No'
  end

  def when_i_click(button)
    click_link_or_button(button)
  end

  def then_i_am_redirected_to_location_preferences(location_preferences)
    expect(page).to have_content('Location preferences')

    location_preferences.each_with_index do |location, index|
      within ".govuk-table__body .govuk-table__row:nth-of-type(#{index + 1})" do
        expect(page).to have_content(location[:name])
        expect(page).to have_content(location[:within])
      end
    end
  end

  def then_i_am_redirected_to_location_preferences_without_locations
    expect(page).to have_content('Location preferences')
    expect(page).to have_content('You have no location preferences')
  end

  def then_i_am_redirected_to_application_choices
    expect(page).to have_current_path(candidate_interface_application_choices_path)
    expect(page).to have_content('You are not sharing your application details with providers you have not applied to')
  end

  def then_i_am_redirected_to_opt_in
    expect(page).to have_content('Do you want to make your application details visible to other training providers?')

    yes_option = find_by_id('candidate-interface-pool-opt-ins-form-pool-status-opt-in-field')
    expect(yes_option).to be_checked
  end

  def when_i_check_dynamic_locations
    check 'Add new locations to my preferences when I apply to new courses'
  end

  def then_i_am_redirected_to_review_page
    expect(page).to have_content('Check your application sharing preferences')

    locations = [
      "Within #{home_location[:within]} miles of #{home_location[:name]}",
      "Within #{choice_location[:within]} miles of #{choice_location[:name]} (#{provider.name})",
      "Within #{updated_location[:within]} miles of #{updated_location[:name]}",
    ].join(' ')

    summary_list = [
      {
        label: 'Do you want to make your application details visible to other training providers?',
        value: 'Yes',
      },
      {
        label: 'Preferred locations',
        value: locations,
      },
      {
        label: 'Add new locations to my preferences when I apply to new course',
        value: 'Yes',
      },
    ]

    summary_list.each_with_index do |item, index|
      within ".govuk-summary-list__row:nth-of-type(#{index + 1})" do
        expect(page).to have_content(item[:label])
        expect(page).to have_content(item[:value])
      end
    end
  end

  def then_i_am_redirected_to_review_page_without_locations
    expect(page).to have_content('Check your application sharing preferences')
    expect(page).to have_content('You have no location preferences')
  end

  def and_the_dynamic_locations_is_checked
    dynamic_locations = find_by_id('candidate-interface-preferences-form-dynamic-location-preferences-true-field')
    expect(dynamic_locations).to be_checked
  end

  def then_i_am_redirected_application_choices_with_success_message
    expect(page).to have_current_path(candidate_interface_application_choices_path)
    expect(page).to have_content('You are sharing your application details with providers you have not applied to')
  end

  def then_i_get_an_error(error_message)
    within '.govuk-error-summary' do
      expect(page).to have_content(error_message)
      expect(page).to have_css('.govuk-error-summary__list li', count: 1)
    end
  end

  def when_i_click_remove_location
    first('a', text: 'Remove').click
  end

  def then_i_am_redirected_to_remove_location_page
    expect(page).to have_content('Do you want to remove this location?')
  end

  def when_i_remove_all_locations
    location_preferences.each do
      when_i_click_remove_location
      then_i_am_redirected_to_remove_location_page
      when_i_click('Yes, remove location')
    end
  end

  def and_i_input_a_location
    fill_in('Within', with: new_location[:within])
    fill_in('of city, town or postcode', with: new_location[:name])
  end

  def and_i_edit_a_location
    fill_in('Within', with: updated_location[:within])
    fill_in('of city, town or postcode', with: updated_location[:name])
  end

  def and_feature_flag_is_enabled
    FeatureFlag.activate(:candidate_preferences)
  end

  def given_i_am_on_the_share_details_page
    visit candidate_interface_share_details_path

    expect(page).to have_content('Increase your chances of success by sharing your application details')
  end

  def then_i_am_redirected_to_opt_in_page
    expect(page).to have_content('Do you want to make your application details visible to other training providers?')
  end

  def when_i_click_change_on_the_last_location
    all('a', text: 'Change').last.click
  end
end
