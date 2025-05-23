require 'rails_helper'

RSpec.describe 'See monthly statistics in support interface' do
  include DfESignInHelpers

  before { TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2023, 11, 20)) }

  scenario 'Reports list' do
    given_i_am_a_support_user
    and_monthly_statistics_reports_were_generated
    and_monthly_statistics_redirect_feature_flag_is_off
    when_i_enter_on_monthly_statistics_support_page
    then_i_see_all_generated_monthly_statistics_reports

    when_i_click_on_the_report_not_published_yet
    then_i_see_the_draft_report

    when_i_enter_on_monthly_statistics_support_page
    and_i_click_on_the_published_report
    then_i_see_the_published_report

    when_i_enter_on_monthly_statistics_support_page
    and_i_click_on_the_report_from_old_cycle
    then_i_see_the_old_cycle_published_report
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_monthly_statistics_redirect_feature_flag_is_off
    FeatureFlag.deactivate(:monthly_statistics_redirected)
  end

  def and_monthly_statistics_reports_were_generated
    @september_report = create(
      :monthly_statistics_report,
      :v1,
      generation_date: Time.zone.local(2023, 9, 18),
      publication_date: Time.zone.local(2023, 9, 25),
      month: '2023-09',
    )
    @october_report = create(
      :monthly_statistics_report,
      :v2,
      generation_date: Time.zone.local(2023, 10, 16),
      publication_date: Time.zone.local(2023, 10, 23),
      month: '2023-10',
    )
    @november_report = create(
      :monthly_statistics_report,
      :v2,
      generation_date: Time.zone.local(2023, 11, 20),
      publication_date: Time.zone.local(2023, 11, 27),
      month: '2023-11',
    )
  end

  def when_i_enter_on_monthly_statistics_support_page
    visit support_interface_path
    click_link_or_button 'Performance'
    click_link_or_button 'Monthly Statistics reports'
  end

  def then_i_see_all_generated_monthly_statistics_reports
    expect(page).to have_content('September 2023')
    expect(page).to have_content('October 2023')
    expect(page).to have_content('November 2023')
    expect(page).to have_content('Draft')
  end

  def when_i_click_on_the_report_not_published_yet
    click_link_or_button 'November 2023'
  end

  def then_i_see_the_draft_report
    expect(page).to have_current_path(support_interface_monthly_statistics_report_path(@november_report))
    expect(page).to have_content('This is currently a draft.')
    expect(page).to have_content('2. Candidate headline statistics')
    expect(page).to have_content('Initial teacher training applications for courses starting in the 2024 to 2025 academic year')
  end

  def and_i_click_on_the_published_report
    click_link_or_button 'October 2023'
  end

  def then_i_see_the_published_report
    expect(page).to have_current_path(publications_monthly_report_at_path('2023-10'))
    expect(page).to have_no_content('This is currently a draft.')
    expect(page).to have_content('2. Candidate headline statistics')
    expect(page).to have_content('Initial teacher training applications for courses starting in the 2024 to 2025 academic year')
  end

  def and_i_click_on_the_report_from_old_cycle
    click_link_or_button 'September 2023'
  end

  def then_i_see_the_old_cycle_published_report
    expect(page).to have_current_path(publications_monthly_report_at_path('2023-09'))
    expect(page).to have_content('Initial teacher training applications for courses starting in the 2023 to 2024 academic year')
    expect(page).to have_no_content('This is currently a draft.')
  end
end
