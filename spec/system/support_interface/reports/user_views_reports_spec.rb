require 'rails_helper'

RSpec.describe 'User views the reports pages' do
  include DfESignInHelpers

  let!(:provider) { create(:provider) }
  let!(:another_provider) { create(:provider) }

  scenario 'support user views the reports index' do
    given_it_is_during_report_season
    sign_in_as_support_user
    when_i_navigate_to_the_reports_page_in_support
    then_i_see_the_reports_for_the_current_and_previous_recruitment_cycles
    and_i_see_links_to_the_reports_in_the_reports_section
  end

  scenario 'support user views the reports index for a provider' do
    given_it_is_during_report_season
    sign_in_as_support_user
    when_i_navigate_to_the_provider_reports_page_in_support
    then_i_see_the_reports_for_the_current_and_previous_recruitment_cycles
    and_i_see_links_to_the_reports_in_the_providers_reports_section
  end

  scenario 'support user follows the report links from the reports index' do
    given_it_is_during_report_season
    and_reports_have_been_generated
    and_the_withdrawal_reasons_report_has_been_generated
    sign_in_as_support_user

    when_i_navigate_to_the_reports_page_in_support
    when_i_follow_the_recruitment_performance_report_link(current_year)
    then_i_see_the_recruitment_performance_report(current_year)

    when_i_navigate_to_the_reports_page_in_support
    click_on 'Status of active applications'
    then_i_see_the_status_of_active_applications_report

    when_i_navigate_to_the_reports_page_in_support
    click_on 'Withdrawal reasons'
    then_i_see_the_withdrawal_reasons_report

    when_i_navigate_to_the_reports_page_in_support
    when_i_follow_the_recruitment_performance_report_link(previous_year)
    then_i_see_the_recruitment_performance_report(previous_year)
  end

  scenario 'support user follows the report links from the provider reports index' do
    given_it_is_during_report_season
    and_reports_have_been_generated
    and_the_withdrawal_reasons_report_has_been_generated
    sign_in_as_support_user

    when_i_navigate_to_the_provider_reports_page_in_support
    when_i_follow_the_recruitment_performance_report_link(current_year)
    then_i_see_the_recruitment_performance_report(current_year)

    when_i_navigate_to_the_provider_reports_page_in_support
    click_on 'Status of active applications'
    then_i_see_the_status_of_active_applications_report

    when_i_navigate_to_the_provider_reports_page_in_support
    click_on 'Withdrawal reasons'
    then_i_see_the_withdrawal_reasons_report

    when_i_navigate_to_the_provider_reports_page_in_support
    when_i_follow_the_recruitment_performance_report_link(previous_year)
    then_i_see_the_recruitment_performance_report(previous_year)
  end

  scenario 'support user changes the provider using the dropdown', :js do
    given_it_is_during_report_season
    and_reports_have_been_generated
    and_the_withdrawal_reasons_report_has_been_generated
    sign_in_as_support_user

    when_i_navigate_to_the_reports_page_in_support
    when_i_follow_the_recruitment_performance_report_link(current_year)
    then_i_see_the_recruitment_performance_report(current_year)
    when_i_select_another_provider_from_the_dropdown
    then_i_see_the_report_for_another_provider

    when_i_navigate_to_the_reports_page_in_support
    click_on 'Status of active applications'
    then_i_see_the_status_of_active_applications_report
    when_i_select_another_provider_from_the_dropdown
    then_i_see_the_report_for_another_provider

    when_i_navigate_to_the_reports_page_in_support
    click_on 'Withdrawal reasons'
    then_i_see_the_withdrawal_reasons_report
    when_i_select_another_provider_from_the_dropdown
    then_i_see_the_report_for_another_provider

    when_i_navigate_to_the_reports_page_in_support
    when_i_follow_the_recruitment_performance_report_link(previous_year)
    then_i_see_the_recruitment_performance_report(previous_year)
    when_i_select_another_provider_from_the_dropdown
    then_i_see_the_report_for_another_provider
  end

private

  def given_it_is_during_report_season
    report_season_starts = RecruitmentPerformanceReportTimetable.first_publication_date
    TestSuiteTimeMachine.travel_permanently_to(report_season_starts + 1.day)
  end

  def and_reports_have_been_generated
    GenerateRecruitmentPerformanceReports.call
  end

  def and_the_withdrawal_reasons_report_has_been_generated
    # rubocop:disable Style/CombinableLoops
    create_list(:application_form, 5).each do |application_form|
      accepted_application_choice = create(:application_choice, :accepted, application_form:, provider_ids: [provider.id])
      create(:withdrawal_reason, :published, application_choice: accepted_application_choice)
    end

    create_list(:application_form, 5).each do |application_form|
      withdrawn_application_choice = create(:application_choice, :withdrawn, application_form:, provider_ids: [provider.id])
      create(:withdrawal_reason, :published, application_choice: withdrawn_application_choice)
    end
    # rubocop:enable Style/CombinableLoops
  end

  def when_i_navigate_to_the_reports_page_in_support
    visit support_interface_path
    click_on 'Providers'
    click_on 'Reports'
  end

  def when_i_navigate_to_the_provider_reports_page_in_support
    visit support_interface_path
    click_on 'Providers'
    click_on provider.name_and_code
    click_on 'Reports'
  end

  def then_i_see_the_reports_for_the_current_and_previous_recruitment_cycles
    expect(page).to have_css('h2', text: "#{current_timetable.cycle_range_name} recruitment cycle")
    expect(page).to have_css('h2', text: "#{previous_timetable.cycle_range_name} recruitment cycle")
  end

  def and_i_see_links_to_the_reports_in_the_reports_section
    expect(page).to have_link(
      'Recruitment performance report',
      href: support_interface_reports_provider_recruitment_report_path(
        provider_id: provider.id,
        recruitment_cycle_year: current_year,
      ),
    )
    expect(page).to have_link(
      'Status of active applications',
      href: support_interface_reports_status_of_active_applications_path(provider_id: provider.id),
    )
    expect(page).to have_link(
      'Withdrawal reasons',
      href: support_interface_reports_withdrawal_reasons_report_path(provider_id: provider.id),
    )
    expect(page).to have_link(
      'Recruitment performance report',
      href: support_interface_reports_provider_recruitment_report_path(
        provider_id: provider.id,
        recruitment_cycle_year: previous_year,
      ),
    )
  end

  def and_i_see_links_to_the_reports_in_the_providers_reports_section
    expect(page).to have_link(
      'Recruitment performance report',
      href: support_interface_provider_recruitment_report_path(provider, recruitment_cycle_year: current_year),
    )
    expect(page).to have_link(
      'Status of active applications',
      href: support_interface_status_of_active_applications_path(provider),
    )
    expect(page).to have_link(
      'Withdrawal reasons',
      href: support_interface_withdrawal_reasons_report_path(provider),
    )
    expect(page).to have_link(
      'Recruitment performance report',
      href: support_interface_provider_recruitment_report_path(provider, recruitment_cycle_year: previous_year),
    )
  end

  def when_i_follow_the_recruitment_performance_report_link(recruitment_cycle_year)
    page.all(:link, 'Recruitment performance report').find do |link|
      link[:href].include?("recruitment_cycle_year=#{recruitment_cycle_year}")
    end.click
  end

  def then_i_see_the_recruitment_performance_report(recruitment_cycle_year)
    expect(page).to have_css('h1', text: "Recruitment performance report #{recruitment_cycle_year}")
  end

  def then_i_see_the_status_of_active_applications_report
    expect(page).to have_link(
      'Export data (CSV)',
      href: support_interface_status_of_active_applications_path(provider, format: :csv),
    )
  end

  def then_i_see_the_withdrawal_reasons_report
    expect(page).to have_css('th', text: 'Withdrawal reason')
    expect(page).to have_css('th', text: 'Before accepting')
    expect(page).to have_css('th', text: 'After accepting')
    expect(page).to have_css('th', text: 'Total')
  end

  def when_i_select_another_provider_from_the_dropdown
    select another_provider.name, from: 'Select provider'
  end

  def then_i_see_the_report_for_another_provider
    uri = URI.parse(page.current_url)

    expect(Rack::Utils.parse_nested_query(uri.query)['provider_id']).to eq(another_provider.id.to_s)
    expect(page).to have_select('Select provider', selected: another_provider.name)
  end
end
