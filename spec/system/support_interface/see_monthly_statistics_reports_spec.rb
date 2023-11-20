require 'rails_helper'

RSpec.feature 'See monthly statistics in support interface' do
  include DfESignInHelpers

  before { TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2023, 11, 20)) }

  scenario 'Reports list' do
    given_i_am_a_support_user
    and_monthly_statistics_reports_were_generated
    when_i_enter_on_monthly_statistics_support_page
    then_i_should_see_all_generated_monthly_statistics_reports

    when_i_click_on_the_report_not_published_yet
    then_i_should_see_the_draft_report

    when_i_enter_on_monthly_statistics_support_page
    and_i_click_on_the_published_report
    then_i_should_see_the_published_report

    when_i_enter_on_monthly_statistics_support_page
    and_i_click_on_the_report_from_old_cycle
    then_i_should_see_the_old_cycle_published_report
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
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
    click_link 'Performance'
    click_link 'Monthly Statistics reports'
  end

  def then_i_should_see_all_generated_monthly_statistics_reports
    expect(page).to have_content('September 2023')
    expect(page).to have_content('October 2023')
    expect(page).to have_content('November 2023')
    expect(page).to have_content('Draft')
  end

  def when_i_click_on_the_report_not_published_yet
    click_link 'November 2023'
  end

  def then_i_should_see_the_draft_report
    expect(page).to have_current_path(publications_monthly_report_at_path('2023-11'))
  end

  def and_i_click_on_the_published_report
    click_link 'October 2023'
  end

  def then_i_should_see_the_published_report
    expect(page).to have_current_path(publications_monthly_report_at_path('2023-10'))
  end

  def and_i_click_on_the_report_from_old_cycle
    click_link 'September 2023'
  end

  def then_i_should_see_the_old_cycle_published_report
    expect(page).to have_current_path(publications_monthly_report_at_path('2023-09'))
  end
end
