require 'rails_helper'

RSpec.describe 'Providers views new candidate in pool' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  before do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_there_are_candidates_for_candidate_pool
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface
  end

  scenario 'Viewing a candidate from the new tab' do
    when_i_visit_the_find_candidates_new_tab
    and_i_click_on_a_candidate
    then_i_click_back

    the_viewed_candidate_is_not_on_the_list
    the_not_viewed_candidate_is_on_the_list
    and_the_url_includes_pagination
  end

  scenario 'Viewing a page out of range' do
    when_i_visit_the_find_candidates_new_tab_with_bad_pagination
    then_i_see_the_list_of_candidates
  end

private

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_provider_user_exists
    provider_user_exists_in_apply_database(provider_code: current_provider.code)
  end

  def and_there_are_candidates_for_candidate_pool
    @rejected_candidate = create(:candidate)
    create(:candidate_preference, candidate: @rejected_candidate)
    @rejected_candidate_form = create(
      :application_form,
      :completed,
      first_name: 'Rejected',
      last_name: 'Candidate',
      candidate: @rejected_candidate,
      submitted_at: 1.day.ago,
    )
    create(:candidate_pool_application, application_form: @rejected_candidate_form)

    declined_candidate = create(:candidate)
    create(:candidate_preference, candidate: declined_candidate)
    @declined_candidate_form = create(
      :application_form,
      :completed,
      first_name: 'Declined',
      last_name: 'Candidate',
      candidate: declined_candidate,
      submitted_at: Time.zone.today,
    )
    create(:candidate_pool_application, application_form: @declined_candidate_form)

    _previous_cycle_form = create(
      :application_form,
      :completed,
      first_name: 'test',
      last_name: 'test',
      recruitment_cycle_year: previous_year,
      submitted_at: 1.year.ago,
      candidate: declined_candidate,
    )
  end

  def and_provider_is_opted_in_to_candidate_pool
    create(:candidate_pool_provider_opt_in, provider: current_provider)
  end

  def when_i_visit_the_find_candidates_new_tab
    visit provider_interface_candidate_pool_not_seen_index_path
  end

  def when_i_visit_the_find_candidates_new_tab_with_bad_pagination
    visit provider_interface_candidate_pool_not_seen_index_path(page: 10)
  end

  def then_i_see_the_list_of_candidates
    expect(page).to have_content '2 new candidates found'
  end

  def and_i_click_on_a_candidate
    click_on @declined_candidate_form.redacted_full_name
  end

  def then_i_click_back
    click_on 'Back'
  end

  def the_viewed_candidate_is_not_on_the_list
    expect(page).to have_no_content(@declined_candidate_form.redacted_full_name)
  end

  def the_not_viewed_candidate_is_on_the_list
    expect(page).to have_content('1 new candidate found')
    expect(page).to have_content(@rejected_candidate_form.redacted_full_name)
  end

  def and_the_url_includes_pagination
    expect(page).to have_current_path(provider_interface_candidate_pool_not_seen_index_path(page: 1))
  end
end
