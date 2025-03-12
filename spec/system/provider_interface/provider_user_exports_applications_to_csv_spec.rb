require 'rails_helper'

RSpec.describe 'Provider user exporting applications to a csv', mid_cycle: false do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'downloads a CSV of application data' do
    given_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_export_applications_page
    and_i_fill_in_the_form_incorrectly
    then_i_get_validation_errors

    when_i_visit_the_export_applications_page
    and_i_fill_out_the_form_for_applications_this_year_of_any_status_for_the_first_provider
    then_the_downloaded_file_includes_applications_this_year_of_any_status_for_the_first_provider

    when_i_visit_the_export_applications_page
    and_i_fill_out_the_form_for_applications_all_years_of_deferred_and_accepted_offers_for_the_first_provider
    then_the_downloaded_file_includes_applications_all_years_of_deferred_and_accepted_offers_for_the_first_provider
  end

  scenario 'downloads a CSV of old applications' do
    given_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    and_my_organisation_has_old_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_export_applications_page

    and_i_fill_out_the_form_for_2022_applications
    then_the_downloaded_file_includes_2022_applications
  end

  scenario 'experiences an error during the download' do
    given_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface
    and_there_is_an_error_lurking_in_the_export

    when_i_visit_the_export_applications_page
    and_i_fill_out_the_form_for_applications_this_year_of_any_status_for_the_first_provider
    then_the_team_have_received_an_error_notification
  end

  scenario 'disconnects during the download' do
    given_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface
    and_client_disconnect_during_the_export

    when_i_visit_the_export_applications_page
    and_i_fill_out_the_form_for_applications_this_year_of_any_status_for_the_first_provider
    then_the_application_handle_the_disconnect_gracefully
  end

  scenario 'io error during the download' do
    given_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface
    and_there_is_an_io_error_during_the_export

    when_i_visit_the_export_applications_page
    and_i_fill_out_the_form_for_applications_this_year_of_any_status_for_the_first_provider
    then_the_application_handle_the_disconnect_gracefully
  end

  def given_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_courses_with_applications
    @current_provider_user = ProviderUser.last
    providers = @current_provider_user.providers
    course = create(:course, provider: providers.first)
    course_option = create(:course_option, course:)

    @application_accepted = create(:application_choice, :accepted, course_option:)
    @application_deferred = create(:application_choice, :offer_deferred, course_option:)
    @application_declined = create(:application_choice, :declined, course_option:)
    @application_withdrawn = create(:application_choice, :offer_withdrawn, course_option:)

    course_previous_year = create(:course, :previous_year, provider: providers.first)
    @application_accepted_previous_cycle = create(:application_choice,
                                                  :accepted,
                                                  course_option: create(:course_option, course: course_previous_year))

    course_second_provider = create(:course, provider: providers.second)
    @application_second_provider = create(:application_choice,
                                          :accepted,
                                          course_option: create(:course_option, course: course_second_provider))

    @application_deferred_submitted_previous_cycle_offered_current_cycle =
      create(:application_choice,
             :accepted,
             course_option: create(:course_option, course: course_previous_year),
             current_course_option: create(:course_option, course: course))
  end

  def and_my_organisation_has_old_courses_with_applications
    @current_provider_user = ProviderUser.last
    providers = @current_provider_user.providers
    course_2022 = create(:course, provider: providers.first, recruitment_cycle_year: 2022)
    course_option = create(:course_option, course: course_2022)

    @application_accepted_2022 = create(:application_choice, :accepted, course_option:)

    course_2021 = create(:course, recruitment_cycle_year: 2021, provider: providers.first)
    @application_deferred_submitted_2021_previous_cycle_offered_2022 =
      create(:application_choice,
             :accepted,
             course_option: create(:course_option, course: course_2021),
             current_course_option: create(:course_option, course: course_2022))
  end

  def when_i_visit_the_export_applications_page
    visit provider_interface_new_application_data_export_path
  end

  def click_export_data
    click_link_or_button 'Export application data (CSV)'
  end

  def and_i_fill_in_the_form_incorrectly
    click_export_data
  end

  def then_i_get_validation_errors
    expect(page).to have_content('Select at least one year')
    expect(page).to have_content('Select at least one organisation')
    expect(page).to have_content('Select a status type')
  end

  def and_i_fill_out_the_form_for_applications_this_year_of_any_status_for_the_first_provider
    check RecruitmentCycleTimetable.current_year.to_s
    choose 'All statuses'
    check @current_provider_user.providers.first.name

    click_export_data
  end

  def and_i_fill_out_the_form_for_2022_applications
    check 2022
    choose 'All statuses'
    check @current_provider_user.providers.first.name

    click_export_data
  end

  def then_the_downloaded_file_includes_applications_this_year_of_any_status_for_the_first_provider
    csv_data = CSV.parse(page.body, headers: true)
    expect_export_to_include_data_for_application(csv_data, @application_accepted)
    expect_export_to_include_data_for_application(csv_data, @application_deferred)
    expect_export_to_include_data_for_application(csv_data, @application_declined)
    expect_export_to_include_data_for_application(csv_data, @application_withdrawn)
    expect_export_to_include_data_for_application(csv_data, @application_deferred_submitted_previous_cycle_offered_current_cycle)
    expect(csv_data['Application number']).not_to include(@application_accepted_previous_cycle.id.to_s)
    expect(csv_data['Application number']).not_to include(@application_second_provider.id.to_s)
  end

  def then_the_downloaded_file_includes_2022_applications
    csv_data = CSV.parse(page.body, headers: true)
    expect_export_to_include_data_for_application(csv_data, @application_accepted_2022)
    expect_export_to_include_data_for_application(csv_data, @application_deferred_submitted_2021_previous_cycle_offered_2022)
  end

  def and_i_fill_out_the_form_for_applications_all_years_of_deferred_and_accepted_offers_for_the_first_provider
    RecruitmentCycleTimetable.years_visible_to_providers.each do |year|
      check "#{year - 1} to #{year}"
    end
    choose 'Specific statuses'
    check 'Deferred'
    check 'Conditions pending'
    check @current_provider_user.providers.first.name

    click_export_data
  end

  def then_the_downloaded_file_includes_applications_all_years_of_deferred_and_accepted_offers_for_the_first_provider
    csv_data = CSV.parse(page.body, headers: true)
    expect_export_to_include_data_for_application(csv_data, @application_accepted)
    expect_export_to_include_data_for_application(csv_data, @application_deferred)
    expect_export_to_include_data_for_application(csv_data, @application_accepted_previous_cycle)
    expect_export_to_include_data_for_application(csv_data, @application_deferred_submitted_previous_cycle_offered_current_cycle)
    expect(csv_data['Application number']).not_to include(@application_declined.id.to_s)
    expect(csv_data['Application number']).not_to include(@application_withdrawn.id.to_s)
    expect(csv_data['Application number']).not_to include(@application_second_provider.id.to_s)
  end

  def expect_export_to_include_data_for_application(csv_data, application)
    expect(csv_data['Application number']).to include(application.id.to_s)
    expect(csv_data['Email address']).to include(application.application_form.candidate.email_address)
    expect(csv_data['Training provider code']).to include(application.provider.code)
    expect(csv_data['Course code']).to include(application.current_course.code)
  end

  def and_there_is_an_error_lurking_in_the_export
    allow(ProviderInterface::ApplicationDataExport).to receive(:export_row).and_call_original
    allow(ProviderInterface::ApplicationDataExport).to receive(:export_row).with(@application_deferred).and_raise(ActionController::BadRequest)

    allow(Sentry).to receive(:capture_exception)
  end

  def and_client_disconnect_during_the_export
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ActionDispatch::Response::Buffer).to receive(:write).and_raise(ActionController::Live::ClientDisconnected.new('Client disconnected during streaming'))
    # rubocop:enable RSpec/AnyInstance
  end

  def and_there_is_an_io_error_during_the_export
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ActionDispatch::Response::Buffer).to receive(:write).and_raise(IOError.new('Client disconnected during streaming'))
    # rubocop:enable RSpec/AnyInstance
  end

  def then_the_team_have_received_an_error_notification
    expect(ProviderInterface::ApplicationDataExport).to have_received(:export_row).with(@application_deferred)
    expect(Sentry).to have_received(:capture_exception).with(instance_of(ActionController::BadRequest), anything)
  end

  def then_the_application_handle_the_disconnect_gracefully
    expect(page.status_code).to be(200)
  end
end
