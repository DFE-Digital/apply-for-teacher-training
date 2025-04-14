require 'rails_helper'

RSpec.describe 'Candidate edits published preference' do
  after { FeatureFlag.deactivate(:candidate_preferences) }

  scenario 'Candidate edits share preferences' do
    given_i_am_signed_in
    and_feature_flag_is_enabled

    given_i_am_on_the_application_choices_page
    when_i_click('Change your sharing and location settings')
    then_i_am_redirected_to_preference_review_page

    when_i_click_change_share_preference
    and_i_choose_not_to_share_my_details

    when_i_click('Continue')
    then_i_am_redirected_on_the_application_choices_page
    and_the_candidate_preference_id_is_changed
  end

  scenario 'Candidate edits location_preferences' do
    given_i_am_signed_in
    and_feature_flag_is_enabled

    given_i_am_on_the_application_choices_page
    when_i_click('Change your sharing and location settings')
    then_i_am_redirected_to_preference_review_page

    when_i_click_dynamic_locations
    and_i_untick_dynamic_locations

    when_i_click('Continue')
    then_i_am_redirected_to_preference_review_page
    when_i_click('Submit preferences')
    then_i_am_redirected_on_the_application_choices_page
    and_the_candidate_preference_id_is_changed
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application = create(
      :application_form,
      :completed,
      candidate: @current_candidate,
    )
    @choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application,
    )
    @existing_candidate_preference = create(
      :candidate_preference,
      candidate: @current_candidate,
      status: 'published',
    )
    _location_preferences = create(
      :candidate_location_preference,
      candidate_preference: @existing_candidate_preference,
    )
  end

  def and_feature_flag_is_enabled
    FeatureFlag.activate(:candidate_preferences)
  end

  def given_i_am_on_the_application_choices_page
    visit candidate_interface_application_choices_path
  end

  def when_i_click(button)
    click_link_or_button(button)
  end

  def then_i_am_redirected_to_preference_review_page
    expect(page).to have_content('Check your application sharing preferences')
  end

  def when_i_click_change_share_preference
    first('a', text: 'Change').click
  end

  def and_i_choose_not_to_share_my_details
    choose 'No'
  end

  def then_i_am_redirected_on_the_application_choices_page
    expect(page).to have_current_path(candidate_interface_application_choices_path)
  end

  def and_the_candidate_preference_id_is_changed
    @current_candidate.published_preferences.last != @existing_candidate_preference
  end

  def when_i_click_dynamic_locations
    all('a', text: 'Change').last.click
  end

  def and_i_untick_dynamic_locations
    uncheck 'Add new course locations to my preferences when I apply to new courses'
  end
end
