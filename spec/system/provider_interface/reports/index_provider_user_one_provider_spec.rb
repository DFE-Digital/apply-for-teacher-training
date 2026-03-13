require 'rails_helper'

RSpec.describe 'Provider reports index' do
  include DfESignInHelpers

  before do
    FeatureFlag.activate(:provider_edi_report)
  end

  after do
    FeatureFlag.deactivate(:provider_edi_report)
  end

  scenario 'when provider user has one provider', time: recruitment_performance_report_season do
    given_a_provider_and_provider_user_exists
    and_i_am_signed_in_as_provider_user
    generate_recruitment_reports
    when_i_visit_the_reports_index
    then_the_page_has_the_right_content
  end

  def when_i_visit_the_reports_index
    visit provider_interface_reports_path
    expect(page).to have_current_path('/provider/reports')
  end

  def given_a_provider_and_provider_user_exists
    @provider_user = create(:provider_user, :with_dfe_sign_in, email_address: 'email@provider.ac.uk')
    @provider = @provider_user.providers.first
  end

  def then_the_page_has_the_right_content
    expect(page).to have_css('h1', text: 'Reports')
    expect(page).to have_css('h2', text: "#{current_timetable.cycle_range_name} recruitment cycle")
    expect(page).to have_css('h2', text: "#{previous_timetable.cycle_range_name} recruitment cycle")
    expect(page).to have_link('Status of active applications', href: provider_interface_reports_provider_status_of_active_applications_path(provider_id: @provider))
    expect(page).to have_link('Withdrawal reasons', href: provider_interface_reports_provider_withdrawal_reasons_report_path(@provider))
    expect(page).to have_link(
      'Recruitment performance report',
      href: provider_interface_reports_provider_recruitment_performance_report_path(
        @provider.id,
        recruitment_cycle_year: current_timetable.recruitment_cycle_year,
      ),
    )
    expect(page).to have_link(
      'Recruitment performance report',
      href: provider_interface_reports_provider_recruitment_performance_report_path(
        @provider.id,
        recruitment_cycle_year: previous_timetable.recruitment_cycle_year,
      ),
    )
    expect(page).to have_css('h2', text: 'Download and export')
    expect(page).to have_link('Export application data', href: provider_interface_new_application_data_export_path)
    expect(page).to have_link('Export data for Higher Education Statistics Agency (HESA)', href: provider_interface_reports_hesa_exports_path)
  end

  def and_i_am_signed_in_as_provider_user
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
    expect(page).to have_current_path('/provider/applications')
  end

  def generate_recruitment_reports
    GenerateRecruitmentPerformanceReports.call
  end
end
