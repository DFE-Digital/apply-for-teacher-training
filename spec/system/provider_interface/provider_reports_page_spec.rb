require 'rails_helper'

RSpec.feature 'Provider reports page' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'the application data and HESA export pages are linked correctly' do
    given_the_application_data_export_feature_flag_is_on
    and_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_reports_page
    then_i_should_see_a_link_to_the_hesa_export_page
    and_the_page_contains_breadcrumbs_including_the_reports_page

    given_the_data_export_feature_flag_is_on

    when_i_visit_the_reports_page_and_i_click_the_export_data_link
    then_i_should_be_on_the_data_export_page
    and_the_page_contains_breadcrumbs_including_the_reports_page
  end

  def given_the_application_data_export_feature_flag_is_on
    FeatureFlag.activate(:export_application_data)
  end

  def and_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def when_i_visit_the_reports_page_and_i_click_the_export_data_link
    visit provider_interface_reports_path
    click_on 'Export application data'
  end

  def when_i_visit_the_reports_page
    visit provider_interface_reports_path
  end

  def then_i_should_see_a_link_to_the_data_export_page
    expect(page).to have_link('Export data for Higher Education Statistics Agency (HESA)')
    click_on('Export data for Higher Education Statistics Agency (HESA)')
    then_i_should_be_redirected_to_the_hesa_export_page
  end

  def then_i_should_see_a_link_to_the_hesa_export_page
    expect(page).to have_link('Export data for Higher Education Statistics Agency (HESA)')
    click_on('Export data for Higher Education Statistics Agency (HESA)')
    then_i_should_be_redirected_to_the_hesa_export_page
  end

  def and_the_page_contains_breadcrumbs_including_the_reports_page
    within '.govuk-breadcrumbs' do
      expect(page).to have_link('Reports')
    end
  end

  def given_the_data_export_feature_flag_is_on
    FeatureFlag.activate(:export_application_data)
  end

  def then_i_should_be_redirected_to_the_hesa_export_page
    expect(page).to have_current_path(provider_interface_reports_hesa_exports_path)
  end

  def then_i_should_be_on_the_data_export_page
    expect(page).to have_current_path(provider_interface_new_application_data_export_path)
    expect(page).to have_content('Export application data (CSV)')
    expect(page).to have_content('Sex, disability and ethnicity information will be marked as confidential')
  end
end
