require 'rails_helper'

RSpec.describe 'Providers views candidate pool details' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  scenario 'View a candidate' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_there_are_candidates_for_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_find_candidates_page
    then_i_see_the_rejected_candidate_as('New')
    and_i_click_on_a_candidate

    then_i_am_redirected_to_view_that_candidate
    and_i_can_view_their_details
    when_i_click('Back')

    then_i_am_redirected_to_find_a_candidate
    then_i_see_the_rejected_candidate_as('Viewed')
    when_the_rejected_candidate_exits_and_enters_the_pool_again
    then_i_see_the_rejected_candidate_as('Viewed')
  end

  scenario 'Viewing a page out of range' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_there_are_candidates_for_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_find_candidates_page_with_bad_pagination
    and_i_see_candidates_in_the_pool
  end

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

  def when_i_visit_the_find_candidates_page
    visit provider_interface_candidate_pool_root_path
  end

  def when_i_visit_the_find_candidates_page_with_bad_pagination
    visit provider_interface_candidate_pool_root_path(page: 10)
  end

  def and_i_see_candidates_in_the_pool
    expect(page).to have_content '2 candidates found'
  end

  def then_i_see_the_rejected_candidate_as(status)
    within("#candidate_#{@rejected_candidate.id}") do
      expect(page).to have_content status
    end
  end

  def and_i_click_on_a_candidate
    click_on @rejected_candidate.redacted_full_name_current_cycle
  end

  def then_i_am_redirected_to_view_that_candidate
    expect(page).to have_current_path(provider_interface_candidate_pool_candidate_path(@rejected_candidate), ignore_query: true)
  end

  def and_i_can_view_their_details
    expect(page).to have_content(@rejected_candidate.redacted_full_name_current_cycle)
    expect(page).to have_content('Right to work or study in the UK')
    expect(page).to have_content('Qualifications')
    expect(page).to have_content('Applications submitted')
    expect(page).to have_content('Most recent Personal statement')
    expect(page).to have_content('Criminal record and professional misconduct')
    expect(page).to have_content('Work history and unpaid experience')
    expect(page).to have_content('Qualifications')
    expect(page).to have_content('A levels and other qualifications')
    expect(page).to have_content('Criminal record and professional misconduct')
  end

  def when_i_click(button)
    click_link_or_button(button)
  end

  def then_i_am_redirected_to_find_a_candidate
    expect(page).to have_current_path(provider_interface_candidate_pool_root_path(page: 1))
  end

  def when_the_rejected_candidate_exits_and_enters_the_pool_again
    CandidatePoolApplication.find_by(application_form: @rejected_candidate_form).delete
    create(:candidate_pool_application, application_form: @rejected_candidate_form)
  end
end
