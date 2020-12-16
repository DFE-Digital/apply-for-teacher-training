require 'rails_helper'

RSpec.feature 'Provider user navigates to the export data page' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'the application data and HESA export pages link together correctly' do
    given_the_hesa_and_application_data_export_feature_flags_are_on
    and_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_applications_page_and_i_click_the_export_data_tab
    then_i_should_see_a_link_to_the_hesa_export_page
    and_the_hesa_export_page_contains_breadcrumbs_including_the_application_data_page

    given_the_hesa_export_feature_flag_is_off

    when_i_visit_the_applications_page_and_i_click_the_export_data_tab
    then_i_should_not_see_a_link_to_the_hesa_export_page

    given_the_hesa_export_feature_flag_is_on_and_the_application_data_export_feature_flag_is_off

    when_i_visit_the_applications_page_and_i_click_the_export_data_tab
    then_i_should_be_redirected_to_the_hesa_export_page
  end

  def given_the_hesa_and_application_data_export_feature_flags_are_on
    FeatureFlag.activate(:export_application_data)
    FeatureFlag.activate(:export_hesa_data)
  end

  def and_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def when_i_visit_the_applications_page_and_i_click_the_export_data_tab
    visit provider_interface_applications_path
    click_on 'Export data'
  end

  def then_i_should_see_a_link_to_the_hesa_export_page
    expect(page).to have_content('Choose which data to export or')
    expected_link_text = 'export only the data needed by the Higher Education Statistics Agency (HESA)'
    expect(page).to have_link(expected_link_text)
    click_on expected_link_text
    then_i_should_be_redirected_to_the_hesa_export_page
  end

  def and_the_hesa_export_page_contains_breadcrumbs_including_the_application_data_page
    within '.govuk-breadcrumbs' do
      expect(page).to have_link('Export data')
    end
  end

  def given_the_hesa_export_feature_flag_is_off
    FeatureFlag.deactivate(:export_hesa_data)
  end

  def then_i_should_not_see_a_link_to_the_hesa_export_page
    expect(page).not_to have_content('HESA')
  end

  def given_the_hesa_export_feature_flag_is_on_and_the_application_data_export_feature_flag_is_off
    FeatureFlag.deactivate(:export_application_data)
    FeatureFlag.activate(:export_hesa_data)
  end

  def then_i_should_be_redirected_to_the_hesa_export_page
    expect(page).to have_current_path(provider_interface_new_hesa_export_path)
  end
end
