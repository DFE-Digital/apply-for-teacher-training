require 'rails_helper'

RSpec.describe 'Candidate adds preferences' do
  include CandidateHelper

  let(:provider) { create(:provider) }

  before { FeatureFlag.activate(:candidate_preferences) }

  scenario 'Candidate opts in to find a candidate with specific locations' do
    given_i_am_signed_in
    given_i_have_a_duplicate_preference_form
    given_i_am_on_the_share_details_page

    when_i_click('Change your sharing and location settings')
    then_i_am_redirected_to_opt_in_page
    and_i_see_that_opt_in_selected

    when_i_click('Continue')
    then_i_am_redirected_to_training_locations
    and_i_see_my_previously_training_locations

    when_i_click('Continue')
    then_i_am_redirected_to_location_preferences
    and_i_see_my_previously_selected_location_preferences

    when_i_click('Continue')
    then_i_am_redirected_to_the_dynamic_locations_page
    and_i_see_my_previously_selected_dynamic_locations_page

    when_i_click('Continue')
    then_i_am_redirected_funding_type_page
    and_i_see_my_previously_selected_funding_type

    when_i_click('Continue')

    then_i_am_redirected_to_review_page

    when_i_click('Submit preferences')
    then_i_am_redirected_to_application_choices_with_success_message
    and_my_duplicate_preference_is_published
  end

  def given_i_have_a_duplicate_preference_form
    @duplicate_preference = create(:candidate_preference, :duplicated, :specific_locations, funding_type: 'salary', application_form: @application)
    create(:candidate_location_preference, :manchester, candidate_preference: @duplicate_preference)
  end

  def given_i_am_signed_in(funding_type: 'salary')
    given_i_am_signed_in_with_one_login
    @application = create(
      :application_form,
      :completed,
      candidate: @current_candidate,
    )
    site = create(
      :site,
      latitude: 53.4807593,
      longitude: -2.2426305,
      provider:,
    )
    course = create(:course, provider:, funding_type:)
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

  def when_i_click(button)
    click_link_or_button(button)
  end
  alias_method :and_i_click, :when_i_click

  def then_i_am_redirected_to_location_preferences
    expect(page).to have_content('Areas you can train in')
  end

  def and_i_see_my_previously_selected_location_preferences
    expect(page).to have_content '10.0 miles'
    expect(page).to have_content 'Manchester'
  end

  def then_i_am_redirected_to_the_dynamic_locations_page
    expect(page).to have_content 'Add the locations of courses you apply to'
    expect(page.title).to include 'Add the locations of courses you apply to'
  end

  def and_i_see_my_previously_selected_dynamic_locations_page
    dynamic_locations_opt_in = page.find_field('Yes')
    expect(dynamic_locations_opt_in).to be_checked
  end

  def then_i_am_redirected_to_review_page
    expect(page).to have_content('Check your application sharing preferences')

    summary_list = [
      {
        label: 'Do you want to be invited to apply to similar courses?',
        value: 'Yes',
      },
      { label: 'Where can you train?',
        value: 'In specific locations' },
      {
        label: 'Areas you can train in',
        value: 'Within 10.0 miles of Manchester',
      },
      {
        label: 'Add the locations of courses you apply to',
        value: 'Yes',
      },
      {
        label: 'Would you consider fee-funded courses?',
        value: 'No',
      },
    ]

    summary_list.each_with_index do |item, index|
      within ".govuk-summary-list__row:nth-of-type(#{index + 1})" do
        expect(page).to have_content(item[:label])
        expect(page).to have_content(item[:value])
      end
    end
  end

  def then_i_am_redirected_to_application_choices_with_success_message
    expect(page).to have_current_path(candidate_interface_application_choices_path)
    expect(page).to have_content('You are sharing your application details with providers you have not applied to')
  end

  def and_my_duplicate_preference_is_published
    expect(@duplicate_preference.reload.status).to eq 'published'
  end

  def given_i_am_on_the_share_details_page
    visit candidate_interface_share_details_path

    expect(page).to have_content('Increase your chances of success by sharing your application details')
  end

  def then_i_am_redirected_to_opt_in_page
    expect(page).to have_content('Do you want to make your application details visible to other training providers?')
  end

  def and_i_see_that_opt_in_selected
    opt_in = page.find_field('Yes')
    expect(opt_in).to be_checked
  end

  def then_i_am_redirected_to_training_locations
    expect(page).to have_content 'Where can you train?'
  end

  def and_i_see_my_previously_training_locations
    specific_locations = page.find_field('In specific locations')
    expect(specific_locations).to be_checked
  end

  def then_i_am_redirected_funding_type_page
    expect(page).to have_content('Would you consider fee-funded courses?')
  end

  def and_i_see_my_previously_selected_funding_type
    only_salaried = page.find_field('No, I am only interested in salaried or apprenticeship routes into teaching')
    expect(only_salaried).to be_checked
  end
end
