require 'rails_helper'

RSpec.describe 'Invited candidate list' do
  include DfESignInHelpers

  let(:submitted_application_choice) { create(:application_choice, :awaiting_provider_decision) }
  let(:current_provider) { submitted_application_choice.provider }

  let(:invite_with_application) do
    create(
      :pool_invite,
      :sent_to_candidate,
      course: submitted_application_choice.course,
      application_form: submitted_application_choice.application_form,
    )
  end

  let(:declined_invite) do
    create(
      :pool_invite,
      :sent_to_candidate,
      candidate_decision: 'declined',
      course: create(:course),
      application_form: create(:application_form),
      provider: current_provider,
    )
  end

  let(:rejected_application_choice_for_opt_out) { create(:application_choice, :rejected) }
  let(:opted_out_preference) { create(:candidate_preference, pool_status: 'opt_out', candidate: rejected_application_choice_for_opt_out.application_form.candidate) }
  let(:invite_with_opted_out_candidate) { create(:pool_invite, :sent_to_candidate, course: build(:course, provider: current_provider), application_form: rejected_application_choice_for_opt_out.application_form) }

  let(:rejected_application_choice_for_opt_in) { create(:application_choice, :rejected) }
  let(:opted_in_preference) { create(:candidate_preference, :anywhere_in_england, pool_status: 'opt_in', candidate: rejected_application_choice_for_opt_in.candidate) }
  let(:invite_with_candidate_in_pool) { create(:pool_invite, :sent_to_candidate, application_form: rejected_application_choice_for_opt_in.application_form, course: build(:course, provider: current_provider)) }
  let(:second_invite_with_candidate_in_pool) { create(:pool_invite, :sent_to_candidate, application_form: rejected_application_choice_for_opt_in.application_form, course: build(:course, provider: current_provider)) }

  before do
    opted_out_preference
    opted_in_preference
    invite_with_application
    invite_with_opted_out_candidate
    declined_invite
    invite_with_candidate_in_pool
    second_invite_with_candidate_in_pool

    FindACandidate::PopulatePoolWorker.new.perform
  end

  scenario 'I can navigate to a candidate that is currently in the pool' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_invited_candidates_page
    then_i_see_a_list_of_invited_candidates

    when_i_click_on_candidate_in_the_pool
    then_i_see_their_pool_profile

    when_i_click_back
    then_i_see_a_list_of_invited_candidates
    and_the_path_has_pagination

    when_i_click_on_candidate_not_in_the_pool
    then_i_see_the_not_in_pool_page

    when_i_click_back
    then_i_see_a_list_of_invited_candidates
    and_the_path_has_pagination
  end

  scenario 'Provider user with existing filters views list of candidates' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface
    and_i_have_an_existing_filter

    when_i_visit_the_invited_candidates_page
    then_i_see_a_list_of_filtered_candidates
  end

  scenario 'Visiting a page that is out of range' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_invited_candidates_page_with_bad_pagination
    then_i_see_a_list_of_invited_candidates
  end

private

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_provider_user_exists
    provider_user_exists_in_apply_database(provider_code: current_provider.code)
  end

  def and_provider_is_opted_in_to_candidate_pool
    create(:candidate_pool_provider_opt_in, provider: current_provider)
  end

  def when_i_visit_the_invited_candidates_page
    visit provider_interface_candidate_pool_root_path
    click_on 'Invited'
  end

  def then_i_see_a_list_of_invited_candidates
    expect(page).to have_title 'Find candidates - Invited'
    expect(page).to have_content 'Find candidates'
    expect(page).to have_content '4 candidates invited'
  end

  def and_the_path_has_pagination
    expect(page).to have_current_path(provider_interface_candidate_pool_invites_path(page: 1))
  end

  def when_i_click_on_candidate_in_the_pool
    redacted_name = invite_with_candidate_in_pool.candidate.current_application.redacted_full_name
    click_on redacted_name
  end

  def when_i_click_on_candidate_not_in_the_pool
    redacted_name = invite_with_opted_out_candidate.candidate.current_application.redacted_full_name
    click_on redacted_name
  end

  def then_i_see_the_not_in_pool_page
    candidate_id = invite_with_opted_out_candidate.candidate_id
    expect(page).to have_title 'Candidate details no longer available'
    expect(page).to have_content "Candidate number: #{candidate_id}"
    expect(page).to have_content 'You cannot see this candidate’s profile information.'
  end

  def then_i_see_their_pool_profile
    candidate_id = invite_with_candidate_in_pool.candidate_id
    expect(page).to have_title 'Candidate details'
    expect(page).to have_content "Candidate number: #{candidate_id}"
  end

  def when_i_click_back
    click_on 'Back'
  end

  def and_i_have_an_existing_filter
    create(
      :provider_user_filter,
      :find_candidates_invited,
      provider_user: ProviderUser.find_by(email_address: 'email@provider.ac.uk'),
      filters: { status: %w[application_received declined] },
    )
  end

  def then_i_see_a_list_of_filtered_candidates
    expect(page).to have_content '2 candidates invited'
  end

  def when_i_visit_the_invited_candidates_page_with_bad_pagination
    visit provider_interface_candidate_pool_invites_path(page: 10)
  end

  def and_i_can_view_the_application
    click_on 'Application received'
    expect(page).to have_content 'Application details'
  end
end
