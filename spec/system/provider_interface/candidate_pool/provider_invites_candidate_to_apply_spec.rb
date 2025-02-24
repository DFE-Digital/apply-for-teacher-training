require 'rails_helper'

RSpec.describe 'Providers invites candidates' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }
  let(:first_course) { current_provider.courses.first }
  let(:last_course) { current_provider.courses.last }

  scenario 'Invite candidate and edit course' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_provider_has_courses(3)
    and_there_are_candidates_for_candidate_pool
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_candidate_pool_show_page
    when_i_click('Invite to apply')

    then_i_am_redirected_to_the_new_invite_form
    when_i_click('Continue')
    then_i_get_an_error('Select a course')

    when_i_select_a_course(first_course)
    when_i_click('Continue')

    then_i_am_redirected_to_the_review_page(first_course)

    when_i_click_change_course
    then_i_am_redirected_to_the_edit_page

    when_i_select_a_course(last_course)
    when_i_click('Continue')
    then_i_am_redirected_to_the_review_page(last_course)

    when_i_click('Send invitation')
    then_i_am_on_the_candidate_pool_page(last_course)
  end

  scenario 'Invite candidate to apply for a provider with over 20 courses' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_provider_has_courses(21)
    and_there_are_candidates_for_candidate_pool
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_candidate_pool_show_page
    when_i_click('Invite to apply')

    then_i_am_redirected_to_the_new_invite_form
    when_i_select_a_course_from_dropdown(first_course)
    when_i_click('Continue')

    then_i_am_redirected_to_the_review_page(first_course)

    when_i_click('Send invitation')
    then_i_am_on_the_candidate_pool_page(first_course)
  end

  scenario 'Invite candidate to apply but course becomes unavailable' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_provider_has_courses(3)
    and_there_are_candidates_for_candidate_pool
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_candidate_pool_show_page
    when_i_click('Invite to apply')

    when_i_select_a_course(first_course)
    when_i_click('Continue')

    then_i_am_redirected_to_the_review_page(first_course)
    when_the_course_becomes_unavailable(first_course)

    when_i_click('Send invitation')
    then_i_get_an_error('Course is not available')

    when_i_select_a_course(last_course)
    when_i_click('Continue')

    then_i_am_redirected_to_the_review_page(last_course)

    when_i_click('Send invitation')
    then_i_am_on_the_candidate_pool_page(last_course)
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_provider_user_exists
    provider_user_exists_in_apply_database(provider_code: current_provider.code)
  end

  def and_provider_has_courses(courses_number)
    create_list(:course, courses_number, :open, provider: current_provider)
  end

  def and_there_are_candidates_for_candidate_pool
    @candidate = create(:candidate, pool_status: 'opt_in')
    rejected_candidate_form = create(
      :application_form,
      :completed,
      candidate: @candidate,
      submitted_at: 1.day.ago,
    )
    create(:application_choice, :rejected, application_form: rejected_candidate_form)
  end

  def and_provider_is_opted_in_to_candidate_pool
    create(:candidate_pool_provider_opt_in, provider: current_provider)
  end

  def when_i_visit_the_candidate_pool_show_page
    visit provider_interface_candidate_pool_candidate_path(@candidate)
  end

  def when_i_click(button)
    click_link_or_button button
  end

  def then_i_am_redirected_to_the_new_invite_form
    expect(page).to have_current_path(
      new_provider_interface_candidate_pool_candidate_draft_invite_path(@candidate),
      ignore_query: true,
    )
  end

  def when_i_select_a_course(course)
    choose course.name_code_and_course_provider
  end

  def then_i_am_redirected_to_the_review_page(course)
    pool_invite = Pool::Invite.where(provider_id: current_provider.id).last

    expect(page).to have_current_path(
      provider_interface_candidate_pool_candidate_draft_invite_path(@candidate, pool_invite.id),
      ignore_query: true,
    )
    expect(page).to have_content(course.name_code_and_course_provider)
  end

  def when_i_click_change_course
    within '.govuk-summary-list__row:nth-of-type(2)' do
      click_link_or_button 'Change'
    end
  end

  def then_i_am_redirected_to_the_edit_page
    pool_invite = Pool::Invite.where(provider_id: current_provider.id).last

    expect(page).to have_current_path(
      edit_provider_interface_candidate_pool_candidate_draft_invite_path(@candidate, pool_invite.id),
      ignore_query: true,
    )
  end

  def then_i_am_on_the_candidate_pool_page(course)
    expect(page).to have_current_path(
      provider_interface_candidate_pool_root_path,
      ignore_query: true,
    )

    expect(page).to have_content "You have invited #{@candidate.redacted_full_name_current_cycle} to apply to #{course.name_code_and_course_provider}"
  end

  def then_i_get_an_error(message)
    expect(page).to have_content(message)
  end

  def when_i_select_a_course_from_dropdown(course)
    select course.name_code_and_course_provider, from: 'provider_interface_pool_invite_form[course_id]'
  end

  def when_the_course_becomes_unavailable(course)
    course.update(exposed_in_find: false)
  end
end
