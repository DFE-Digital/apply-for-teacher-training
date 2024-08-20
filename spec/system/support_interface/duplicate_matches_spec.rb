require 'rails_helper'

RSpec.describe 'See Duplicate candidate matches' do
  include DfESignInHelpers

  scenario 'Support agent visits Duplicate candidate matches page', :sidekiq do
    given_i_am_a_support_user
    and_i_go_to_duplicate_matches_page

    and_i_click_the_duplicate_matches_tab
    then_i_see_a_message_that_there_are_no_matches

    when_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_duplicate_matches_worker_has_run
    and_the_second_duplicate_match_is_resolved
    and_i_click_the_duplicate_matches_tab
    then_i_see_list_of_under_review_duplicates
    and_i_see_a_counter_for_under_review_duplicates

    when_i_search_for_a_duplicate_match_by_email
    and_i_click_on_a_match_that_is_not_resolved
    then_i_see_that_candidates_email_address
    and_i_click_the_back_link
    i_am_taken_to_the_under_review_view

    when_i_click_on_a_the_resolved_link
    when_i_search_for_a_resolved_duplicate_match_by_email
    and_click_on_a_match_that_is_resolved
    and_i_click_the_back_link
    i_am_taken_to_the_resolved_view
    then_i_see_list_of_resolved_duplicates

    when_i_click_on_a_the_under_review_link
    and_i_click_on_a_duplicate
    then_i_see_the_details_for_each_duplicate_candidate

    when_i_click_on_resolve
    then_the_duplicate_match_is_resolved
  end

  scenario 'Old duplicates are shown in the dashboard', :sidekiq do
    given_i_am_a_support_user
    when_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_duplicate_match_was_created_last_recruitment_cycle
    and_i_go_to_duplicate_matches_page
    and_i_click_the_duplicate_matches_tab
    then_i_see_list_of_duplicates_from_last_recruitment_cycle
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_there_are_candidates_with_duplicate_applications_in_the_system
    @bob = create(:candidate, email_address: 'bob@example.com')
    @robert = create(:candidate, email_address: 'robert@example.com')
    @alice = create(:candidate, email_address: 'alice@example.com')
    @ali = create(:candidate, email_address: 'ali@example.com')

    @bobs_application_form = create(:application_form, candidate: @bob, first_name: 'Bob', last_name: 'Roberts', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: 7.days.ago)
    @roberts_application_form = create(:application_form, candidate: @robert, first_name: 'Robert', last_name: 'Roberts', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
    @alices_application_form = create(:application_form, candidate: @alice, first_name: 'Alice', last_name: 'Roberts', date_of_birth: '1999-10-12', postcode: 'W3 6ET', submitted_at: 10.days.ago)
    @alis_application_form = create(:application_form, candidate: @ali, first_name: 'Ali', last_name: 'Roberts', date_of_birth: '1999-10-12', postcode: 'W3 6ET')
  end

  def and_the_duplicate_match_was_created_last_recruitment_cycle
    create(
      :duplicate_match,
      candidates: [@bob, @robert],
      recruitment_cycle_year: 2021,
      postcode: 'W6 9BH',
      last_name: 'Roberts',
      date_of_birth: '1998-08-08',
    )
  end

  def then_i_see_list_of_duplicates_from_last_recruitment_cycle
    expect(page).to have_content('2 candidates with postcode W6 9BH and DOB 8 Aug 1998')
  end

  def and_the_update_duplicate_matches_worker_has_run
    UpdateDuplicateMatchesWorker.perform_async
  end

  def and_the_second_duplicate_match_is_resolved
    @ali.reload.duplicate_match.update!(resolved: true)
  end

  def and_i_go_to_duplicate_matches_page
    visit support_interface_duplicate_matches_path
  end

  def and_i_click_the_duplicate_matches_tab
    click_link_or_button 'Candidates'
    click_link_or_button 'Duplicate candidate matches'
  end

  def then_i_see_list_of_under_review_duplicates
    expect(page).to have_content('2 candidates with postcode W6 9BH and DOB 8 Aug 1998')
    expect(page).to have_no_link('2 candidates with postcode W3 6ET')
  end

  def and_i_click_on_a_match_that_is_not_resolved
    click_link_or_button '2 candidates with postcode W6 9BH and DOB 8 Aug 1998'
  end

  def and_i_click_the_back_link
    click_link_or_button 'Back'
  end

  def when_i_click_on_a_the_resolved_link
    click_link_or_button 'Resolved'
  end

  def when_i_search_for_a_duplicate_match_by_email
    fill_in :query, with: @bob.email_address
    click_link_or_button 'Apply filters'
  end

  def when_i_search_for_a_resolved_duplicate_match_by_email
    fill_in :query, with: @alice.email_address
    click_link_or_button 'Apply filters'
  end

  def when_i_click_on_resolve
    click_link_or_button 'Mark as resolved'
  end

  def when_i_click_on_a_the_under_review_link
    click_link_or_button 'Under review'
  end

  def and_i_click_on_a_duplicate
    click_link_or_button '2 candidates with postcode W6 9BH and DOB 8 Aug 1998'
  end

  def i_am_taken_to_the_under_review_view
    expect(page).to have_current_path(support_interface_duplicate_matches_path(resolved: @bob.reload.duplicate_match.resolved))
  end

  def and_click_on_a_match_that_is_resolved
    click_link_or_button '2 candidates with postcode W3 6ET and DOB 12 Oct 1999'
  end

  def i_am_taken_to_the_resolved_view
    expect(page).to have_current_path(support_interface_duplicate_matches_path(resolved: @ali.reload.duplicate_match.resolved))
  end

  def and_i_see_a_counter_for_under_review_duplicates
    expect(page.find('span.app-count').text).to eq('1')
  end

  def then_i_see_the_details_for_each_duplicate_candidate
    expect(page).to have_content('2 candidates with postcode W6 9BH and DOB 8 Aug 1998')
    expect(page).to have_button('Mark as resolved')
  end

  def then_the_duplicate_match_is_resolved
    expect(@bob.reload.duplicate_match.resolved).to be(true)
    expect(page).to have_button('Mark as unresolved')
  end

  def then_i_see_that_candidates_email_address
    expect(page).to have_content(@bob.email_address)
  end

  def then_i_see_a_message_that_there_are_no_matches
    expect(page).to have_content 'There are currently no duplicate applications'
  end

  def then_i_see_list_of_resolved_duplicates
    expect(page).to have_content('2 candidates with postcode W3 6ET and DOB 12 Oct 1999')
    expect(page).to have_no_link('2 candidates with postcode W6 9BH')
  end
end
