require 'rails_helper'

RSpec.describe 'Providers searches for candidates' do
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  scenario 'Provider searches list by candidate number' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface
    and_candidates_exist_for_the_pool

    when_i_visit_the_find_candidates_page
    and_i_search_with('3000')
    then_i_see_no_results_text('There are no candidates that match that candidate number. Check the candidate number and try again.')

    when_i_click_clear_search
    and_i_search_with('3000')
    and_i_filter_by_course_type
    then_i_see_no_results_text('There are no candidates that match that candidate number with the filters you have chosen. Remove some of your filters and try again.')

    when_i_click_clear_search
    and_i_click('Clear filters')
    and_i_search_with(@awaiting_decision_candidate.id)
    then_i_see_no_results_text('This candidate’s profile is not visible at the moment. They could have an active application, be unresponsive or have opted out.')

    when_i_click_clear_search
    and_i_search_with(@withdrawn_candidate.id)
    then_i_see_only_the_relevant_candidate_in_the_results
  end

private

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database(provider_code: current_provider.code)
  end

  def when_i_visit_the_find_candidates_page
    visit provider_interface_candidate_pool_root_path
  end

  def and_candidates_exist_for_the_pool
    @rejected_candidate = create(:candidate)
    @rejected_candidate_form = create(
      :application_form,
      :completed,
      first_name: 'Rejected',
      last_name: 'Candidate',
      candidate: @rejected_candidate,
      submitted_at: 1.day.ago,
    )
    create(:candidate_preference, application_form: @rejected_candidate_form)
    create(:candidate_pool_application, application_form: @rejected_candidate_form)

    @withdrawn_candidate = create(:candidate)
    @withdrawn_candidate_form = create(
      :application_form,
      :completed,
      first_name: 'Withdrawn',
      last_name: 'Candidate',
      candidate: @withdrawn_candidate,
      submitted_at: 1.day.ago,
    )
    create(:candidate_preference, application_form: @withdrawn_candidate_form)
    create(:candidate_pool_application, application_form: @withdrawn_candidate_form)

    @awaiting_decision_candidate = create(:candidate)
    @awaiting_decision_candidate_form = create(
      :application_form,
      :completed,
      first_name: 'Awaiting',
      last_name: 'Candidate',
      candidate: @awaiting_decision_candidate,
      submitted_at: 1.day.ago,
    )
    create(:candidate_preference, application_form: @awaiting_decision_candidate_form)
    create(:application_choice, :awaiting_provider_decision, application_form: @awaiting_decision_candidate_form)
  end

  def and_i_search_with(search_term)
    fill_in 'Search by candidate number', with: search_term
    click_on 'Search'
  end
  alias_method :when_i_search_with, :and_i_search_with

  def then_i_see_no_results_text(text)
    expect(page).to have_content(text)
  end

  def when_i_click(text)
    click_link_or_button text
  end
  alias_method :and_i_click, :when_i_click

  def when_i_click_clear_search
    click_link_or_button 'Clear search'
  end

  def and_i_filter_by_course_type
    check('Postgraduate')
    first(:link_or_button, 'Apply filters').click
  end

  def then_i_see_only_the_relevant_candidate_in_the_results
    expect(page).to have_no_content(@rejected_candidate.redacted_full_name_current_cycle)
    expect(page).to have_content(@withdrawn_candidate.redacted_full_name_current_cycle)
  end
end
