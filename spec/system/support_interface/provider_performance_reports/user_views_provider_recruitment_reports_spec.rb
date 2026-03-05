require 'rails_helper'

RSpec.describe 'User views sections when reports have been generated' do
  include DfESignInHelpers

  scenario 'before reports are available to providers (ie, before report season), reports generated' do
    given_it_is_before_report_season
    and_a_provider_exists
    and_national_and_provider_reports_have_been_generated
    and_regional_and_provider_reports_have_been_generated
    sign_in_as_support_user
    when_i_navigate_to_the_providers_report_page_in_support
    then_i_see_the_report_data
    and_i_can_navigate_to_report_sections

    and_i_see_the_text_that_providers_do_not_yet_see_the_report
    when_i_set_london_as_my_region
    and_i_see_the_text_that_providers_do_not_yet_see_the_report
    and_i_can_navigate_to_report_sections(report_region: 'Providers in London')

    when_i_go_to_set_my_comparison_area
    then_the_london_option_is_ticked
  end

  scenario 'before reports are available to providers (ie, before report season), reports not generated' do
    given_it_is_before_report_season
    and_a_provider_exists
    sign_in_as_support_user
    when_i_navigate_to_the_providers_report_page_in_support
    then_i_see_the_explanation_about_when_reports_are_available
  end

  scenario 'when reports are available to provider (ie, during report season) reports generated' do
    given_it_is_during_report_season
    and_a_provider_exists

    and_national_and_provider_reports_have_been_generated
    and_regional_and_provider_reports_have_been_generated
    and_edi_report_has_been_generated

    sign_in_as_support_user
    when_i_navigate_to_the_providers_report_page_in_support
    and_i_do_not_see_the_text_that_providers_do_not_yet_see_the_report

    then_i_see_the_report_data
    when_i_set_london_as_my_region

    and_i_do_not_see_the_text_that_providers_do_not_yet_see_the_report
    then_i_see_the_report_data
  end

  scenario 'when reports are available to provider (ie, during report season) reports not generated' do
    given_it_is_during_report_season
    and_a_provider_exists
    sign_in_as_support_user
    when_i_navigate_to_the_providers_report_page_in_support
    then_i_see_not_available_text
    when_i_set_london_as_my_region
    then_i_see_not_available_text
  end

  scenario 'when I try to visit the report page without signing in' do
    given_it_is_during_report_season
    and_national_and_provider_reports_have_been_generated
    when_i_visit_the_report_page
    then_i_see_a_prompt_to_sign_in
  end

private

  def given_it_is_before_report_season
    report_season_starts = RecruitmentPerformanceReportTimetable.first_publication_date
    TestSuiteTimeMachine.travel_permanently_to(report_season_starts - 1.day)
  end

  def given_it_is_during_report_season
    report_season_starts = RecruitmentPerformanceReportTimetable.first_publication_date
    TestSuiteTimeMachine.travel_permanently_to(report_season_starts + 1.day)
  end

  def and_a_provider_exists
    @provider = create(:provider)
  end

  def and_national_and_provider_reports_have_been_generated
    and_a_provider_exists
    create(
      :national_recruitment_performance_report,
      recruitment_cycle_year: current_year,
      cycle_week: RecruitmentCycleTimetable.current_cycle_week,
      generation_date: DateTime.now,
      publication_date: DateTime.now,
    )
    create(
      :provider_recruitment_performance_report,
      provider: @provider,
      recruitment_cycle_year: current_year,
      cycle_week: RecruitmentCycleTimetable.current_cycle_week,
      generation_date: DateTime.now,
      publication_date: DateTime.now,
    )
  end

  def and_regional_and_provider_reports_have_been_generated
    create(
      :regional_recruitment_performance_report,
      recruitment_cycle_year: current_year,
      cycle_week: RecruitmentCycleTimetable.current_cycle_week,
      generation_date: DateTime.now,
      publication_date: DateTime.now,
    )
    if Publications::ProviderRecruitmentPerformanceReport.none?
      create(
        :provider_recruitment_performance_report,
        provider: @provider,
        recruitment_cycle_year: current_year,
        cycle_week: RecruitmentCycleTimetable.current_cycle_week,
        generation_date: DateTime.now,
        publication_date: DateTime.now,
      )
    end
  end

  def and_edi_report_has_been_generated
    create(
      :regional_edi_report,
      recruitment_cycle_year: current_year,
      cycle_week: RecruitmentCycleTimetable.current_cycle_week,
      generation_date: DateTime.now,
      publication_date: DateTime.now,
      region: :all_of_england,
    )
    create(
      :regional_edi_report,
      recruitment_cycle_year: current_year,
      cycle_week: RecruitmentCycleTimetable.current_cycle_week,
      generation_date: DateTime.now,
      publication_date: DateTime.now,
      region: :london,
    )
    create(
      :provider_edi_report,
      provider: @provider,
      recruitment_cycle_year: current_year,
      cycle_week: RecruitmentCycleTimetable.current_cycle_week,
      generation_date: DateTime.now,
      publication_date: DateTime.now,
    )
  end

  def when_i_navigate_to_the_providers_report_page_in_support
    visit support_interface_path
    click_on 'Providers'
    click_on @provider.name_and_code
    click_on 'Recruitment performance report'
  end

  def when_i_set_london_as_my_region
    click_on 'Set your comparison area'
    choose 'London'
    click_on 'Update comparison are'
  end

  def then_i_see_the_report_data
    year = current_year
    cycle_name = "#{year - 1} to #{year}"
    expect(page).to have_content('Recruitment performance report')
    description = "This report shows your organisation's cumulative recruitment data from the start of the #{cycle_name} cycle to the date displayed above. It compares your data to the same point in the previous cycle and to your chosen comparison region or England."
    expect(page).to have_content(description)
    expect(page).to have_content('Sex, disability, ethnicity and age of candidates')
  end

  def and_i_see_the_text_that_providers_do_not_yet_see_the_report
    date = RecruitmentPerformanceReportTimetable.first_publication_date.to_datetime.to_fs(:govuk_date)
    expect(page).to have_text("These reports are not available to providers until #{date}")
  end

  def and_i_do_not_see_the_text_that_providers_do_not_yet_see_the_report
    date = RecruitmentPerformanceReportTimetable.first_publication_date.to_datetime.to_fs(:govuk_date)
    expect(page).to have_no_text("These reports are not available to providers until #{date}")
  end

  def when_i_visit_the_report_page
    visit support_interface_provider_recruitment_report_path(provider_id: @provider.id)
  end

  def then_i_see_a_prompt_to_sign_in
    expect(page).to have_content 'You must sign in to use the support console'
  end

  def then_i_see_no_data_text_and_available_in_future_date
    expect(page).to have_content 'The reports for the 2025 to 2026 recruitment cycle are not available until 12 January 2026.'
  end

  def then_i_see_not_available_text
    expect(page).to have_text 'This report is not ready to view.'
  end

  def then_i_see_the_explanation_about_when_reports_are_available
    date = RecruitmentPerformanceReportTimetable.first_publication_date.to_datetime.to_fs(:govuk_date)
    "The reports for the #{current_timetable.cycle_range_name} recruitment cycle are not available until #{date}."
  end

  def and_i_do_see_the_performance_reports
    expect(page).to have_text('Recruitment performance report')
  end

  def and_i_can_navigate_to_report_sections(report_region: 'All providers')
    expect(page).to have_link(
      'Candidates who have submitted applications',
      href: '#candidates_who_have_submitted_applications',
    )
    expect(page).to have_css(
      'h2',
      text: '1. Candidates who have submitted applications',
      id: 'candidates_who_have_submitted_applications',
    )

    expect(page).to have_link('Candidates that received an offer', href: '#candidates_with_an_offer')
    expect(page).to have_css(
      'h2',
      text: '2. Candidates that received an offer',
      id: 'candidates_with_an_offer',
    )

    expect(page).to have_link('Proportion of candidates with an offer', href: '#proportion_of_candidates_with_an_offer')
    expect(page).to have_css(
      'h2',
      text: '3. Proportion of candidates with an offer',
      id: 'proportion_of_candidates_with_an_offer',
    )

    expect(page).to have_link('Offers accepted', href: '#offers_accepted')
    expect(page).to have_css(
      'h2',
      text: '4. Offers accepted',
      id: 'offers_accepted',
    )

    expect(page).to have_link('Deferrals', href: '#candidate_deferrals')
    expect(page).to have_css(
      'h2',
      text: '5. Deferrals',
      id: 'candidate_deferrals',
    )

    expect(page).to have_link('Candidates rejected', href: '#candidates_rejected')
    expect(page).to have_css(
      'h2',
      text: '6. Candidates rejected',
      id: 'candidates_rejected',
    )

    expect(page).to have_link(
      'Proportion of candidates who have waited more than 30 working days for a response',
      href: '#proportion_with_inactive_applications_table_component',
    )
    expect(page).to have_css(
      'h2',
      text: '7. Proportion of candidates who have waited more than 30 working days for a response',
      id: 'proportion_with_inactive_applications_table_component',
    )

    expect(page).to have_content(report_region)
  end

  def when_i_go_to_set_my_comparison_area
    click_on 'Set your comparison area'
  end

  def then_the_london_option_is_ticked
    expect(page).to have_checked_field('London')
  end
end
