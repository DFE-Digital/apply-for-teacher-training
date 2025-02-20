require 'rails_helper'

RSpec.describe 'Providers views candidate pool list' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  scenario 'View candidates' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_there_are_candidates_for_candidate_pool
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_find_candidates_page

    then_i_expect_to_see_eligible_candidates_order_by_application_form_submitted_at
  end

  scenario 'Provider cannot view candidates if not invited' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_there_are_candidates_for_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_find_candidates_page

    then_i_am_redirected_to_the_applications_page
    and_find_candidates_is_not_in_my_navigation
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_provider_user_exists
    provider_user_exists_in_apply_database(provider_code: current_provider.code)
  end

  def and_there_are_candidates_for_candidate_pool
    rejected_candidate = create(:candidate, pool_status: 'opt_in')
    @rejected_candidate_form = create(
      :application_form,
      :completed,
      candidate: rejected_candidate,
      submitted_at: 1.day.ago,
    )
    create(:application_choice, :rejected, application_form: @rejected_candidate_form)

    declined_candidate = create(:candidate, pool_status: 'opt_in')
    @declined_candidate_form = create(
      :application_form,
      :completed,
      candidate: declined_candidate,
      submitted_at: Time.zone.today,
    )
    create(:application_choice, :declined, application_form: @declined_candidate_form)

    previous_cycle_form = create(
      :application_form,
      :completed,
      first_name: 'test',
      last_name: 'test',
      recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
      submitted_at: 1.year.ago,
      candidate: declined_candidate,
    )
    create(:application_choice, :declined, application_form: previous_cycle_form)
  end

  def and_provider_is_opted_in_to_candidate_pool
    create(:candidate_pool_provider_opt_in, provider: current_provider)
  end

  def when_i_visit_the_find_candidates_page
    visit provider_interface_candidate_pool_root_path
  end

  def then_i_expect_to_see_eligible_candidates_order_by_application_form_submitted_at
    candidates = page.all('.govuk-table__body .govuk-table__row td:first-child').map(&:text)

    expect(candidates).to eq([
      @rejected_candidate_form.redacted_full_name,
      @declined_candidate_form.redacted_full_name,
    ])
  end

  def then_i_am_redirected_to_the_applications_page
    expect(page).to have_current_path(provider_interface_applications_path, ignore_query: true)
  end

  def and_find_candidates_is_not_in_my_navigation
    within('#service-navigation') do
      expect(page).to have_no_css('li', text: 'Find candidates')
    end
  end
end
