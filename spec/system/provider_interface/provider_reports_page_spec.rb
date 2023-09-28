require 'rails_helper'

RSpec.feature 'Provider reports page' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'the application data and HESA export pages are linked correctly' do
    given_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_reports_page
    then_i_should_see_a_link_to_the_hesa_export_page
    and_the_page_contains_breadcrumbs_including_the_reports_page

    when_i_visit_the_reports_page_and_i_click_the_export_data_link
    then_i_should_be_on_the_data_export_page
    and_the_page_contains_breadcrumbs_including_the_reports_page

    when_i_visit_the_reports_page
    then_i_should_see_links_for_all_the_provider_status_application_records

    when_i_visit_the_reports_page
    then_i_should_see_new_links_for_all_the_provider_reports

    given_there_are_mid_cycle_reports
    when_i_visit_the_reports_page
    then_i_should_see_new_links_for_all_providers_mid_cycle_reports
  end

  def given_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    provider_exists_in_dfe_sign_in
    @provider_user = provider_user_exists_in_apply_database
  end

  def when_i_visit_the_reports_page_and_i_click_the_export_data_link
    visit provider_interface_reports_path
    click_link 'Export application data'
  end

  def when_i_visit_the_reports_page
    visit provider_interface_reports_path
  end

  def then_i_should_see_a_link_to_the_data_export_page
    expect(page).to have_link('Export data for Higher Education Statistics Agency (HESA)')
    click_link('Export data for Higher Education Statistics Agency (HESA)')
    then_i_should_be_redirected_to_the_hesa_export_page
  end

  def then_i_should_see_a_link_to_the_hesa_export_page
    expect(page).to have_link('Export data for Higher Education Statistics Agency (HESA)')
    click_link('Export data for Higher Education Statistics Agency (HESA)')
    then_i_should_be_redirected_to_the_hesa_export_page
  end

  def and_the_page_contains_breadcrumbs_including_the_reports_page
    within '.govuk-breadcrumbs' do
      expect(page).to have_link('Reports')
    end
  end

  def then_i_should_be_redirected_to_the_hesa_export_page
    expect(page).to have_current_path(provider_interface_reports_hesa_exports_path)
  end

  def then_i_should_be_on_the_data_export_page
    expect(page).to have_current_path(provider_interface_new_application_data_export_path)
    expect(page).to have_content('Export application data (CSV)')
  end

  def then_i_should_see_links_for_all_the_provider_status_application_records
    @provider_user.providers.each do |provider|
      expect(page).to have_content(provider.name)
      expect(page).to have_link('Status of active applications', href: provider_interface_reports_provider_status_of_active_applications_path(provider_id: provider))
    end
  end

  def then_i_should_see_new_links_for_all_the_provider_reports
    @provider_user.providers.each do |provider|
      expect(page).to have_content(provider.name)
      expect(page).to have_link('Status of active applications', href: provider_interface_reports_provider_status_of_active_applications_path(provider_id: provider))
      expect(page).to have_link('Sex, disability, ethnicity and age of candidates', href: provider_interface_reports_provider_diversity_report_path(provider_id: provider))
      expect(page).to have_link('Withdrawals', href: provider_interface_reports_provider_withdrawal_report_path(provider_id: provider))
    end
  end

  def given_there_are_mid_cycle_reports
    create(
      :provider_mid_cycle_report,
      provider: @provider_user.providers.first,
      publication_date: Date.new(2023, 6, 1),
    )
  end

  def then_i_should_see_new_links_for_all_providers_mid_cycle_reports
    expect(page).to have_link(
      '2022 to 2023 recruitment cycle performance',
      href: provider_interface_reports_provider_mid_cycle_report_path(provider_id: @provider_user.providers.first),
    )
    expect(page).not_to have_link(
      '2022 to 2023 recruitment cycle performance',
      href: provider_interface_reports_provider_mid_cycle_report_path(provider_id: @provider_user.providers.last),
    )
  end
end
