require 'rails_helper'

RSpec.feature 'Providers should be able to filter applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider, :with_signed_agreement, code: 'ABC', name: 'Hoth Teacher Training') }
  let(:second_provider) { create(:provider, :with_signed_agreement, code: 'DEF', name: 'Caladan University') }
  let(:third_provider) { create(:provider, :with_signed_agreement, code: 'GHI', name: 'University of Arrakis') }

  scenario 'can filter applications by status and provider' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_from_multiple_providers
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page

    then_i_expect_to_see_the_filter_dialogue
    then_i_expect_to_see_the_search_input

    when_i_search_for_candidate_name
    then_only_applications_of_that_name_should_be_visible
    and_the_name_should_appear_in_search_field

    when_i_clear_the_filters
    then_i_expect_all_applications_to_be_visible

    when_i_search_for_part_of_a_candidate_name
    then_only_applications_of_that_name_should_be_visible
    and_the_part_of_the_name_should_appear_in_search_field

    when_i_search_for_candidate_name_with_odd_casing
    then_only_applications_of_that_name_should_be_visible

    when_i_clear_the_filters
    then_i_filter_for_withdrawn_and_offered_applications
    then_only_withdrawn_and_offered_applications_should_be_visible
    then_i_search_for_candidate_name
    then_only_withdrawn_and_offered_applications_of_that_name_should_be_visible

    when_i_clear_the_filters
    when_i_search_for_a_candidate_that_does_not_exist
    then_i_should_see_the_no_filter_results_error_message

    when_i_clear_the_filters

    when_i_filter_by_provider
    then_i_only_see_applications_for_a_given_provider
    and_candidates_name_tags_should_not_be_visible

    then_i_search_for_candidate_name
    then_only_applications_of_that_name_and_provider_should_be_visible
    then_the_relevant_tag_headings_should_be_visible
    and_the_relevant_tags_should_be_visible
  end

  def when_i_search_for_part_of_a_candidate_name
    fill_in 'Search by candidate name or reference', with: 'ame'
    click_button('Search')
  end

  def and_the_part_of_the_name_should_appear_in_search_field
    expect(page).to have_field('candidate_name', with: 'ame')
  end

  def and_the_name_should_appear_in_search_field
    expect(page).to have_field('candidate_name', with: 'Jim James')
  end

  def and_candidates_name_tags_should_not_be_visible
    expect(page).not_to have_css('.moj-filter__selected', text: 'Candidate’s name')
  end

  def then_only_withdrawn_and_offered_applications_should_be_visible
    cards = find(:css, '.app-application-cards')
    expect(cards).to have_text('Application withdrawn')
    expect(cards).to have_text('Offered')
  end

  def and_the_relevant_tags_should_be_visible
    tags = find(:css, '.moj-filter-tags:nth-of-type(2)')
    expect(tags).to have_text('Hoth Teacher Training')
    expect(tags).to have_text('Caladan University')
  end

  def then_the_relevant_tag_headings_should_be_visible
    selected_filters = find(:css, '.moj-filter__selected')
    expect(selected_filters).to have_text('Courses run by')
  end

  def then_only_withdrawn_and_offered_applications_of_that_name_should_be_visible
    then_only_applications_of_that_name_and_status_should_be_visible
  end

  def then_i_expect_all_applications_to_be_visible
    cards = find(:css, '.app-application-cards')
    expect(cards).to have_text('Rejected')
    expect(cards).to have_text('Offered')
    expect(cards).to have_text('Application withdrawn')
    expect(cards).to have_text('Declined')
  end

  def then_i_only_see_applications_for_a_given_provider
    cards = find(:css, '.app-application-cards')
    expect(cards).to have_text('Hoth Teacher Training')
    expect(cards).to have_text('Caladan University')
  end

  def then_only_applications_of_that_name_and_provider_should_be_visible
    cards = find(:css, '.app-application-cards')
    expect(cards).to have_text('Hoth Teacher Training')
    then_only_applications_of_that_name_should_be_visible
  end

  def when_i_search_for_candidate_name
    fill_in 'Search by candidate name or reference', with: 'Jim James'
    click_button('Search')
  end

  def when_i_search_for_a_candidate_that_does_not_exist
    fill_in 'Search by candidate name or reference', with: 'Simon Says'
    click_button('Search')
  end

  def then_i_search_for_candidate_name
    when_i_search_for_candidate_name
  end

  def then_i_filter_for_withdrawn_and_offered_applications
    find(:css, '#status-withdrawn').set(true)
    find(:css, '#status-offer').set(true)
    click_button('Apply filters')
  end

  def when_i_search_for_candidate_name_with_odd_casing
    fill_in 'Search by candidate name or reference', with: 'jiM JAmeS'
    click_button('Search')
  end

  def then_only_applications_of_that_name_and_status_should_be_visible
    cards = find(:css, '.app-application-cards')
    expect(cards).to have_text('Jim James')
    expect(cards).to have_text('Application withdrawn')
  end

  def then_only_applications_of_that_name_should_be_visible
    cards = find(:css, '.app-application-cards')
    expect(cards).to have_text('Jim James')
  end

  def then_i_expect_to_see_the_search_input
    expect(page).to have_content('Search by candidate name or reference')
  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def then_i_expect_to_see_the_filter_dialogue
    expect(page).to have_button('Apply filters')
  end

  def when_i_clear_the_filters
    click_link('Clear search')
  end

  def and_i_am_permitted_to_see_applications_from_multiple_providers
    provider_user_exists_in_apply_database_with_multiple_providers
  end

  def and_my_organisation_has_courses_with_applications
    course_option_one = course_option_for_provider(provider: current_provider, course: build(:course, name: 'Alchemy', provider: current_provider))
    course_option_two = course_option_for_provider(provider: current_provider, course: build(:course, name: 'Divination', provider: current_provider))
    course_option_three = course_option_for_provider(provider: current_provider, course: build(:course, name: 'English', provider: current_provider))

    course_option_four = course_option_for_provider(provider: second_provider, course: build(:course, name: 'Science', provider: second_provider))
    course_option_five = course_option_for_provider(provider: second_provider, course: build(:course, name: 'History', provider: second_provider))

    course_option_six = course_option_for_provider(provider: third_provider, course: build(:course, name: 'Maths', provider: third_provider))
    course_option_seven = course_option_for_provider(provider: third_provider, course: build(:course, name: 'Engineering', provider: third_provider))

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_one, status: 'withdrawn', application_form:
           build(:application_form, first_name: 'Jim', last_name: 'James'), updated_at: 1.day.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer', application_form:
           build(:application_form, first_name: 'Adam', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'rejected', application_form:
           build(:application_form, first_name: 'Tom', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_three, status: 'declined', application_form:
           build(:application_form, first_name: 'Bill', last_name: 'Bones'), updated_at: 3.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_four, status: 'offer', application_form:
           build(:application_form, first_name: 'Greg', last_name: 'Taft'), updated_at: 4.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_five, status: 'rejected', application_form:
           build(:application_form, first_name: 'Paul', last_name: 'Atreides'), updated_at: 5.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_six, status: 'withdrawn', application_form:
           build(:application_form, first_name: 'Duncan', last_name: 'Idaho'), updated_at: 6.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_seven, status: 'declined', application_form:
           build(:application_form, first_name: 'Luke', last_name: 'Smith'), updated_at: 7.days.ago)
  end

  def then_i_should_see_the_no_filter_results_error_message
    expect(page).to have_content("There are no results for 'Simon Says' and the selected filter.")
  end

  def when_i_filter_by_provider
    find(:css, "#provider-#{current_provider.id}").set(true)
    find(:css, "#provider-#{second_provider.id}").set(true)
    click_button('Apply filters')
  end
end
