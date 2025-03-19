require 'rails_helper'

RSpec.describe 'Provider with two providers reports index' do
  include DfESignInHelpers

  scenario 'when provider user has multiple provider with performance report', time: mid_cycle do
    given_a_provider_user_with_two_providers_exists
    and_a_provider_has_a_recruitment_performance_report
    and_i_am_signed_in_as_provider_user
    when_i_visit_the_reports_index
    then_the_page_has_the_right_content
  end

  def when_i_visit_the_reports_index
    visit provider_interface_reports_path
    expect(page).to have_current_path('/provider/reports', ignore_query: true)
  end

  def and_a_provider_has_a_recruitment_performance_report
    @report = create(
      :provider_recruitment_performance_report,
      recruitment_cycle_year: current_year,
      provider: @provider,
    )
  end

  def given_a_provider_user_with_two_providers_exists
    @provider_user = create(:provider_user, :with_dfe_sign_in, email_address: 'email@provider.ac.uk')
    @provider = @provider_user.providers.first
    @second_provider = create(:provider)
    @provider_user.providers << @second_provider
  end

  def then_the_page_has_the_right_content
    expect(page).to have_css('h1', text: 'Reports')
    expect(page).to have_css('h2', text: 'Weekly recruitment performance report')
    expect(page).to have_link("Weekly report for week ending #{@report.reporting_end_date.to_fs(:govuk_date)}", href: provider_interface_reports_provider_recruitment_performance_report_path(@provider))
    expect(page).to have_css('h2', text: 'Application data for this recruitment cycle')
    expect(page).to have_link('Export application data', href: provider_interface_new_application_data_export_path)
    expect(page).to have_link('Export data for Higher Education Statistics Agency (HESA)', href: provider_interface_reports_hesa_exports_path)
    expect(page).to have_css('h3', text: @provider.name)
    expect(page).to have_link('Status of active applications', href: provider_interface_reports_provider_status_of_active_applications_path(provider_id: @provider))
    expect(page).to have_link('Sex, disability, ethnicity and age of candidates', href: provider_interface_reports_provider_diversity_report_path(provider_id: @provider))
    expect(page).to have_link('Withdrawals', href: provider_interface_reports_withdrawal_reports_path).twice
    expect(page).to have_css('h3', text: @second_provider.name)
    expect(page).to have_link('Status of active applications', href: provider_interface_reports_provider_status_of_active_applications_path(provider_id: @second_provider))
    expect(page).to have_link('Sex, disability, ethnicity and age of candidates', href: provider_interface_reports_provider_diversity_report_path(provider_id: @second_provider))
    expect(page).to have_css('h2', text: 'Download and export')
    expect(page).to have_link('Export application data', href: provider_interface_new_application_data_export_path)
    expect(page).to have_link('Export data for Higher Education Statistics Agency (HESA)', href: provider_interface_reports_hesa_exports_path)
  end

  def and_i_am_signed_in_as_provider_user
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
    expect(page).to have_current_path('/provider/applications', ignore_query: true)
  end
end
