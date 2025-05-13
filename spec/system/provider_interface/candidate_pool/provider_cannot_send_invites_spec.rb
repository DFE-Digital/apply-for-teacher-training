require 'rails_helper'

RSpec.describe 'Providers cannot send invites to candidates' do
  include CourseOptionHelpers
  include DfESignInHelpers

  before do
    given_i_am_a_provider_user_with_dfe_sign_in_with_many_providers
    and_those_providers_have_courses_for_the_pool
    and_there_are_candidates_for_candidate_pool
  end

  scenario 'User cannot make decisions views the find candidates page' do
    given_provider_user_cannot_make_decisions_for_any_of_their_courses
    when_i_sign_in_to_the_provider_interface
    and_i_navigate_to_a_candidate
    then_i_do_not_see_the_invite_button

    when_i_visit_the_invite_page_directly
    then_i_am_redirected_to_the_find_candidate_page
  end

  scenario 'User can make decisions for one of its providers' do
    given_provider_user_can_make_decisions_for_just_one_of_its_providers
    when_i_sign_in_to_the_provider_interface
    and_i_navigate_to_a_candidate
    and_i_click_the_invite_button
    then_i_only_see_courses_that_i_have_permission_to_make_decisions_form
  end

  scenario 'User cannot edit an invite unless they can make decisions' do
    given_provider_user_can_make_decisions_for_just_one_of_its_providers
    and_an_invite_exists_for_the_other_provider
    when_i_sign_in_to_the_provider_interface
    and_i_directly_visit_the_edit_page
    then_i_am_redirected_to_the_find_candidate_page
  end

private

  def given_i_am_a_provider_user_with_dfe_sign_in_with_many_providers
    @provider_user = provider_user_exists_in_apply_database
    user_exists_in_dfe_sign_in(
      email_address: @provider_user.email_address,
      dfe_sign_in_uid: @provider_user.dfe_sign_in_uid,
    )
  end

  def and_those_providers_have_courses_for_the_pool
    @provider_user.providers.each do |provider|
      create_list(:course, 3, :open, provider:)
      create(:candidate_pool_provider_opt_in, provider:)
    end
  end

  def and_there_are_candidates_for_candidate_pool
    @candidate = create(:candidate)
    create(:candidate_preference, candidate: @candidate)
    rejected_candidate_form = create(
      :application_form,
      :completed,
      first_name: 'Candidate',
      last_name: 'Candidate',
      candidate: @candidate,
      submitted_at: 1.day.ago,
    )
    create(:application_choice, :rejected, application_form: rejected_candidate_form)
  end

  def given_provider_user_cannot_make_decisions_for_any_of_their_courses
    @provider_user.provider_permissions.update_all(make_decisions: false)
  end

  def given_provider_user_can_make_decisions_for_just_one_of_its_providers
    @provider_user.provider_permissions.update_all(make_decisions: false)
    @can_make_decisions_provider = @provider_user.providers.first
    @cannot_make_decisions_provider = @provider_user.providers.second

    @provider_user.provider_permissions.where(provider: @can_make_decisions_provider).update(make_decisions: true)
    @provider_user.provider_permissions.where(provider: @cannot_make_decisions_provider).update(make_decisions: false)
  end

  def and_an_invite_exists_for_the_other_provider
    @invite = create(
      :pool_invite,
      provider: @cannot_make_decisions_provider,
      course: @cannot_make_decisions_provider.courses.first,
    )
  end

  def and_i_directly_visit_the_edit_page
    visit provider_interface_candidate_pool_candidate_draft_invite_path(candidate_id: @candidate.id, id: @invite.id)
  end

  def and_i_navigate_to_a_candidate
    click_on 'Find candidates'
    click_on @candidate.redacted_full_name_current_cycle
  end

  def and_i_click_the_invite_button
    click_on 'Invite to apply'
  end

  def then_i_only_see_courses_that_i_have_permission_to_make_decisions_form
    @can_make_decisions_provider.courses.open.each do |course|
      expect(page).to have_content(course.name_code_and_course_provider)
    end

    @cannot_make_decisions_provider.courses.open.each do |course|
      expect(page).to have_no_content(course.name_code_and_course_provider)
    end
  end

  def then_i_do_not_see_the_invite_button
    expect(page).to have_content "Candidate #{@candidate.id}"
    expect(page).to have_no_content 'Invite to apply'
  end

  def when_i_visit_the_invite_page_directly
    visit new_provider_interface_candidate_pool_candidate_draft_invite_path(@candidate)
  end

  def then_i_am_redirected_to_the_find_candidate_page
    expect(page).to have_content 'Candidates can choose to share their application details.'
    expect(page).to have_no_content 'Select a course to invite C***** C***** to apply to'
  end
end
