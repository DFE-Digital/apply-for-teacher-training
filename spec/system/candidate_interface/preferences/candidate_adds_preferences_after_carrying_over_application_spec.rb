require 'rails_helper'

RSpec.describe 'Candidate adds preferences' do
  include CandidateHelper

  let(:provider) { create(:provider) }

  before { FeatureFlag.activate(:candidate_preferences) }

  scenario 'Candidate opts in to find a candidate with specific locations' do
    given_i_am_signed_in
    given_i_have_a_duplicate_preference_form
    given_i_am_on_the_share_details_page
    and_i_click('Back')

    when_i_click('Update your preferences')
    then_i_am_redirected_to_review_page
    when_i_click('Submit preferences')
    then_i_am_redirected_to_confirmation_page
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
        label: 'What funding types are you interested in?',
        value: 'Salaried courses only',
      },
    ]

    summary_list.each_with_index do |item, index|
      within ".govuk-summary-list__row:nth-of-type(#{index + 1})" do
        expect(page).to have_content(item[:label])
        expect(page).to have_content(item[:value])
      end
    end
  end

  def then_i_am_redirected_to_confirmation_page
    expect(page).to have_current_path(show_candidate_interface_pool_opt_ins_path)
    expect(page).to have_content('You have chosen to share your application details')
  end

  def and_my_duplicate_preference_is_published
    expect(@duplicate_preference.reload.status).to eq 'published'
  end

  def given_i_am_on_the_share_details_page
    visit candidate_interface_share_details_path

    expect(page).to have_content('Application sharing How application sharing works')
  end
end
