require 'rails_helper'

RSpec.describe 'Provider user navigates the FAC tabs' do
  include CourseOptionHelpers
  include DfESignInHelpers

  before do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_is_opted_in_to_candidate_pool
    set_viewed_application_form
    set_not_seen_application_form
    set_invited_application_form
  end

  scenario 'View candidates' do
    when_i_sign_in_to_the_provider_interface
    when_i_visit_the_find_candidates_page

    then_i_see_all_candidates
    when_i_apply_study_mode_filter
    then_i_expect_the_study_mode_filter_to_be_applied

    when_i_click_on_new_tab
    then_i_see_not_seen_candidates
    then_i_expect_the_study_mode_filter_to_be_applied
    when_i_click_on_candidate(@not_seen_application_form)
    when_i_click_on('Back')
    then_i_expect_the_study_mode_filter_to_be_applied
    and_i_there_are_no_not_seen_candidates
    when_i_apply_course_type_filters

    when_i_click_on_all_tab
    then_i_see_all_candidates
    and_i_see_all_applied_filters
  end

  def set_viewed_application_form
    candidate = create(:candidate)
    @viewed_application_form = create(
      :application_form,
      :completed,
      candidate:,
    )
    create(:candidate_pool_application, application_form: @viewed_application_form)
    create(
      :provider_pool_action,
      status: 'viewed',
      application_form: @viewed_application_form,
      provider_user: @provider_user,
    )
  end

  def set_not_seen_application_form
    candidate = create(:candidate)
    @not_seen_application_form = create(
      :application_form,
      :completed,
      candidate:,
    )
    create(:candidate_pool_application, application_form: @not_seen_application_form)
  end

  def set_invited_application_form
    candidate = create(:candidate)
    @invited_application_form = create(
      :application_form,
      :completed,
      candidate:,
    )
    create(
      :pool_invite,
      status: 'published',
      candidate:,
      provider: @provider_user.providers.last,
      invited_by: @provider_user,
      application_form: @invited_application_form,
      course: create(:course),
    )
    create(:candidate_pool_application, application_form: @invited_application_form)
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    @provider_user ||= provider_user_exists_in_apply_database
    user_exists_in_dfe_sign_in(
      email_address: @provider_user.email_address,
      dfe_sign_in_uid: @provider_user.dfe_sign_in_uid,
    )
  end

  def and_provider_is_opted_in_to_candidate_pool
    @provider_user.providers.each do |provider|
      create(:candidate_pool_provider_opt_in, provider:)
    end
  end

  def when_i_visit_the_find_candidates_page
    visit provider_interface_candidate_pool_root_path
  end

  def then_i_see_all_candidates
    expect(page).to have_content('3 candidates found')
    candidates = page.all('.govuk-table__body .govuk-table__row td:first-child').map(&:text)

    expected_candidates = [
      candidate_name(@viewed_application_form),
      candidate_name(@not_seen_application_form),
      candidate_name(@invited_application_form),
    ]

    expected_candidates.each do |candidate_text|
      expect(candidates).to have_text(candidate_text)
    end
  end

  def candidate_name(application_form)
    "#{application_form.redacted_full_name} (#{application_form.candidate_id})"
  end

  def when_i_apply_study_mode_filter
    check('Full time')
    check('Part time')
    first('.govuk-button', text: 'Apply filters').click
  end

  def then_i_expect_the_study_mode_filter_to_be_applied
    within('.moj-filter__selected') do
      expect(page).to have_link 'Remove study type filter Full time'
      expect(page).to have_link 'Remove study type filter Part time'
    end
  end

  def when_i_click_on_new_tab
    within '.app-tab-navigation' do
      click_link_or_button 'New'
    end
  end

  def then_i_see_not_seen_candidates
    expect(page).to have_content('1 new candidate found')
    candidates = page.all('.govuk-table__body .govuk-table__row td:first-child').map(&:text)

    expected_candidates = [candidate_name(@not_seen_application_form)]

    expected_candidates.each do |candidate_text|
      expect(candidates).to have_text(candidate_text)
    end
  end

  def when_i_click_on_candidate(application_form)
    click_link_or_button application_form.redacted_full_name
  end

  def when_i_click_on(button)
    click_link_or_button button
  end

  def and_i_there_are_no_not_seen_candidates
    expect(page).to have_content('No candidates')
  end

  def when_i_apply_course_type_filters
    travel_temporarily_to(10.minutes.from_now) do
      check('Postgraduate')
      check('Undergraduate')
      first('.govuk-button', text: 'Apply filters').click
    end
  end

  def when_i_click_on_all_tab
    within '.app-tab-navigation' do
      click_link_or_button 'All candidates'
    end
  end

  def and_i_see_all_applied_filters
    within('.moj-filter__selected') do
      expect(page).to have_link 'Remove study type filter Full time'
      expect(page).to have_link 'Remove study type filter Part time'
      expect(page).to have_link 'Remove course type filter Postgraduate'
      expect(page).to have_link 'Remove course type filter Undergraduate'
    end
  end
end
