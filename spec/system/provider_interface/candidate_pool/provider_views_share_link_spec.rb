require 'rails_helper'

RSpec.describe 'Providers views share link' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  before do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_there_are_candidates_for_candidate_pool
    and_i_sign_in_to_the_provider_interface
  end

  scenario 'View a candidate who is in the pool from share link' do
    when_i_visit_the_share_link_for(@rejected_candidate)
    then_i_see_the_relevant_candidate_page
  end

  scenario 'View a candidate who is no longer in the pool from share link' do
    when_i_visit_the_share_link_for(@awaiting_decision_candidate)
    then_i_see_the_not_in_pool_page
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

  def when_i_visit_the_share_link_for(candidate)
    visit provider_interface_candidate_pool_candidate_path(candidate)
  end

  def then_i_see_the_relevant_candidate_page
    expect(page).to have_content(@rejected_candidate.redacted_full_name_current_cycle)
    expect(page).to have_content('Share this candidate’s profile')
  end

  def then_i_see_the_not_in_pool_page
    expect(page).to have_content(@awaiting_decision_candidate.redacted_full_name_current_cycle)
    expect(page).to have_content('You cannot see this candidate’s profile information.')
  end
end
