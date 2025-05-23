require 'rails_helper'

RSpec.describe 'Support user views candidate pool list' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  before do
    set_rejected_candidate_form
    set_declined_candidate_form
    set_visa_sponsorship_candidate_form
  end

  scenario 'View candidates' do
    given_i_am_a_support_user
    and_i_visit_support_find_a_candidate

    then_i_expect_to_see_eligible_candidates_order_by_application_form_submitted_at
    and_i_expect_to_see_the_total_results_count

    when_i_filter_by_location
    then_i_expect_to_see_filtered_candidates([@declined_candidate_form, @rejected_candidate_form, @visa_sponsorship_form])
    when_i_filter_by_visa_sponsorship
    then_i_expect_to_see_filtered_candidates([@visa_sponsorship_form])
    and_i_expect_to_see_the_updated_results_count

    when_i_click('Clear filters')
    then_i_expect_to_see_eligible_candidates_order_by_application_form_submitted_at
    and_i_expect_to_see_the_total_results_count
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
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
    create(:candidate_pool_application, application_form: @rejected_candidate_form)
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
    create(:candidate_pool_application, application_form: @visa_sponsorship_form)
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

  def and_i_expect_to_see_the_total_results_count
    expect(page).to have_content('3 candidates found')
  end

  def and_i_expect_to_see_the_updated_results_count
    expect(page).to have_content('1 candidate found')
  end

  def and_i_visit_support_find_a_candidate
    visit support_interface_find_candidates_path
  end
end
