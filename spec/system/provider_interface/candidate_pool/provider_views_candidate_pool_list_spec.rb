require 'rails_helper'

RSpec.describe 'Providers views candidate pool list' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }
  let(:client) { instance_double(GoogleMapsAPI::Client) }
  let(:api_response) { [{ name: 'Manchester', place_id: }] }
  let(:place_id) { 'test_id' }

  before do
    set_rejected_candidate_form
    set_declined_candidate_form
    set_visa_sponsorship_candidate_form
    set_withdrawn_no_longer_want_to_train_form

    allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:autocomplete).and_return(api_response)
  end

  scenario 'View candidates' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_find_candidates_page

    then_i_expect_to_see_eligible_candidates_order_by_application_form_submitted_at
    and_i_expect_to_see_the_total_results_count

    when_i_filter_by_location
    then_i_expect_to_see_filtered_candidates([@declined_candidate_form, @rejected_candidate_form, @visa_sponsorship_form])
    when_i_filter_by_visa_sponsorship
    then_i_expect_to_see_filtered_candidates([@visa_sponsorship_form])
    and_i_expect_to_see_the_updated_results_count

    when_i_add_all_remaining_filters
    then_i_expect_all_the_filters_to_be_applied
    when_i_remove_some_filters
    then_i_expect_the_only_the_remaining_filter_to_be_applied

    when_i_visit_applications_page
    and_i_go_back_to_find_a_candidate
    then_i_expect_the_only_the_remaining_filter_to_be_applied

    when_i_click('Clear filters')
    then_i_expect_to_see_eligible_candidates_order_by_application_form_submitted_at
    and_i_expect_to_see_the_total_results_count
  end

  context 'with wrong location filter' do
    let(:place_id) { 'wrong_location' }

    scenario 'Provider inputs a wrong location in the filters' do
      given_i_am_a_provider_user_with_dfe_sign_in
      and_provider_user_exists
      and_provider_is_opted_in_to_candidate_pool
      and_i_sign_in_to_the_provider_interface

      when_i_visit_the_find_candidates_page
      when_i_add_a_invalid_location

      then_i_see_an_error
    end
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
    create(:pool_eligible_application_form, application_form: @declined_candidate_form)
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
    create(:pool_eligible_application_form, application_form: @rejected_candidate_form)
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
    create(:pool_eligible_application_form, application_form: @visa_sponsorship_form)
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
    create(:pool_eligible_application_form, application_form: @withdrawn_no_longer_wants_to_train_form)
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
  alias_method(:and_i_go_back_to_find_a_candidate, :when_i_visit_the_find_candidates_page)

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
    fill_in('location', with: 'Manchester')
    click_link_or_button('Apply filters')
  end

  def when_i_filter_by_visa_sponsorship
    check('Needs a visa')
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

  def and_i_expect_to_see_the_total_results_count
    expect(page).to have_content('3 candidates found')
  end

  def and_i_expect_to_see_the_updated_results_count
    expect(page).to have_content('1 candidate found')
  end

  def first_subject
    @first_subject ||= Subject.select("name, string_agg(id::text, ',') as id").group(:name).order(:name).first
  end

  def last_subject
    @last_subject ||= Subject.select("name, string_agg(id::text, ',') as id").group(:name).order(:name).last
  end

  def when_i_add_all_remaining_filters
    check(first_subject.name)
    check(last_subject.name)
    check('Full time')
    check('Part time')
    check('Undergraduate')
    check('Postgraduate')
    check('Does not need a visa')
    click_link_or_button('Apply filters')
  end

  def then_i_expect_all_the_filters_to_be_applied
    within('.moj-filter__selected') do
      expect(page).to have_link 'Remove candidate location preference filter Manchester'
      expect(page).to have_link "Remove subject filter #{first_subject.name}"
      expect(page).to have_link "Remove subject filter #{last_subject.name}"
      expect(page).to have_link 'Remove study type filter Full time'
      expect(page).to have_link 'Remove study type filter Part time'
      expect(page).to have_link 'Remove course type filter Undergraduate'
      expect(page).to have_link 'Remove course type filter Postgraduate'
      expect(page).to have_link 'Remove visa sponsorship filter Needs a visa'
      expect(page).to have_link 'Remove visa sponsorship filter Does not need a visa'
    end
  end

  def when_i_remove_some_filters
    within('.moj-filter__selected') do
      click_link_or_button('Remove candidate location preference filter Manchester')
      click_link_or_button("Remove subject filter #{last_subject.name}")
      click_link_or_button('Part time')
      click_link_or_button('Undergraduate')
      click_link_or_button('Needs a visa')
    end
  end

  def then_i_expect_the_only_the_remaining_filter_to_be_applied
    filters = page.all('.moj-filter__selected a').map(&:text)
    expect(filters).to match([
      'Clear filters',
      "Remove subject filter #{first_subject.name}",
      'Remove study type filter Full time',
      'Remove course type filter Postgraduate',
      'Remove visa sponsorship filter Does not need a visa',
    ])
  end

  def when_i_add_a_invalid_location
    fill_in('location', with: 'wrong location')
    click_link_or_button('Apply filters')
  end

  def then_i_see_an_error
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Town, city or postcode must be in the United Kingdom')
    expect(page).to have_title('Error: Find candidates - Manage teacher training applications - GOV.UK')
  end

  def when_i_visit_applications_page
    visit provider_interface_applications_path
  end
end
