require 'rails_helper'

RSpec.describe 'Providers views candidate pool list' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  before do
    set_rejected_candidate_form
    set_declined_candidate_form
    set_visa_sponsorship_candidate_form
    set_withdrawn_no_longer_want_to_train_form
  end

  scenario 'View candidates' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_find_candidates_page

    then_i_expect_to_see_eligible_candidates_order_by_application_form_submitted_at

    when_i_filter_by_location
    then_i_expect_to_see_filtered_candidates([@rejected_candidate_form, @visa_sponsorship_form])
    when_i_filter_by_visa_sponsorship
    then_i_expect_to_see_filtered_candidates([@visa_sponsorship_form])

    when_i_click('Clear filters')
    then_i_expect_to_see_eligible_candidates_order_by_application_form_submitted_at
  end

  scenario 'Provider cannot view candidates if not invited' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
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

  def set_declined_candidate_form
    declined_candidate = create(:candidate)
    create(:candidate_preference, candidate: declined_candidate)
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
      recruitment_cycle_year: previous_year,
      submitted_at: 1.year.ago,
      candidate: declined_candidate,
    )
    create(:application_choice, :declined, application_form: previous_cycle_form)
  end

  def set_rejected_candidate_form
    rejected_candidate = create(:candidate)
    candidate_preference = create(:candidate_preference, candidate: rejected_candidate)
    create(:candidate_location_preference, :manchester, candidate_preference:)
    @rejected_candidate_form = create(
      :application_form,
      :completed,
      candidate: rejected_candidate,
      submitted_at: 1.day.ago,
    )
    course_option = create(
      :course_option,
      course: create(:course, provider: current_provider),
    )
    create(
      :application_choice,
      :rejected,
      application_form: @rejected_candidate_form,
      course_option:,
    )
  end

  def set_visa_sponsorship_candidate_form
    visa_sponsorship_candidate = create(:candidate)
    candidate_preference = create(:candidate_preference, candidate: visa_sponsorship_candidate)
    create(:candidate_location_preference, :manchester, candidate_preference:)
    @visa_sponsorship_form = create(
      :application_form,
      :completed,
      candidate: visa_sponsorship_candidate,
      submitted_at: 6.hours.ago,
      right_to_work_or_study: :no,
    )
    course_option = create(
      :course_option,
      course: create(:course, provider: current_provider),
    )
    create(
      :application_choice,
      :rejected,
      application_form: @visa_sponsorship_form,
      course_option:,
    )
  end

  def set_withdrawn_no_longer_want_to_train_form
    no_longer_wants_to_train_candidate = create(:candidate)
    create(:candidate_preference, candidate: no_longer_wants_to_train_candidate)
    @withdrawn_no_longer_wants_to_train_form = create(
      :application_form,
      :completed,
      candidate: no_longer_wants_to_train_candidate,
      submitted_at: 3.hours.ago,
    )
    course_option = create(
      :course_option,
      course: create(:course, provider: current_provider),
    )
    withdrawn_choice = create(
      :application_choice,
      :withdrawn,
      application_form: @withdrawn_no_longer_wants_to_train_form,
      course_option:,
    )
    create(
      :withdrawal_reason,
      application_choice: withdrawn_choice,
      reason: 'do-not-want-to-train-anymore.personal-circumstances-have-changed',
    )
  end

  def and_provider_is_opted_in_to_candidate_pool
    create(:candidate_pool_provider_opt_in, provider: current_provider)
  end

  def when_i_visit_the_find_candidates_page
    visit provider_interface_candidate_pool_root_path
  end

  def then_i_expect_to_see_eligible_candidates_order_by_application_form_submitted_at
    candidates = page.all('.govuk-table__body .govuk-table__row td:first-child').map(&:text)

    expected_candidates = [
      candidate_name(@rejected_candidate_form),
      candidate_name(@declined_candidate_form),
      candidate_name(@visa_sponsorship_form),
    ]

    expected_candidates.each do |candidate_text|
      expect(candidates).to have_text(candidate_text)
    end

    expect(page).to have_no_text(candidate_name(@withdrawn_no_longer_wants_to_train_form))
  end

  def then_i_am_redirected_to_the_applications_page
    expect(page).to have_current_path(provider_interface_applications_path, ignore_query: true)
  end

  def and_find_candidates_is_not_in_my_navigation
    within('#service-navigation') do
      expect(page).to have_no_css('li', text: 'Find candidates')
    end
  end

  def when_i_filter_by_location
    fill_in('original_location', with: 'Manchester')
    click_link_or_button('Apply filters')
  end

  def when_i_filter_by_visa_sponsorship
    check('visa_sponsorship-required')
    click_link_or_button('Apply filters')
  end

  def then_i_expect_to_see_filtered_candidates(application_forms)
    candidates = page.all('.govuk-table__body .govuk-table__row td:first-child').map(&:text)
    candidate_names = application_forms.map { |form| candidate_name(form) }

    candidate_names.each do |name|
      expect(candidates).to have_text(name)
    end
  end

  def when_i_click(button)
    click_link_or_button button
  end

  def candidate_name(application_form)
    "#{application_form.redacted_full_name} (#{application_form.candidate_id})"
  end
end
