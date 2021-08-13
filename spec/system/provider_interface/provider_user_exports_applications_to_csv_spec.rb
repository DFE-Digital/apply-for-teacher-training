require 'rails_helper'

RSpec.feature 'Provider user exports applications to a csv' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'download a CSV of application data' do
    given_the_application_data_export_feature_flag_is_on
    and_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
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

  def given_the_application_data_export_feature_flag_is_on
    FeatureFlag.activate(:export_application_data)
  end

  def and_i_am_a_provider_user_with_permissions_to_see_applications_for_my_provider
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_courses_with_applications
    @current_provider_user = ProviderUser.last
    providers = @current_provider_user.providers
    course = create(:course, provider: providers.first)
    course_option = create(:course_option, course: course)

    @application_accepted = create(:application_choice, :application_form_with_degree, :with_accepted_offer, course_option: course_option)
    @application_deferred = create(:application_choice, :application_form_with_degree, :with_deferred_offer, course_option: course_option)
    @application_declined = create(:application_choice, :application_form_with_degree, :with_declined_offer, course_option: course_option)
    @application_withdrawn = create(:application_choice, :application_form_with_degree, :with_withdrawn_offer, course_option: course_option)

    course_previous_year = create(:course, :previous_year, provider: providers.first)
    @application_accepted_previous_cycle = create(:application_choice,
                                                  :application_form_with_degree,
                                                  :with_accepted_offer,
                                                  course_option: create(:course_option, course: course_previous_year))

    course_second_provider = create(:course, provider: providers.second)
    @application_second_provider = create(:application_choice,
                                          :application_form_with_degree,
                                          :with_accepted_offer,
                                          course_option: create(:course_option, course: course_second_provider))
  end

  def when_i_visit_the_export_applications_page
    visit provider_interface_new_application_data_export_path
  end

  def click_export_data
    click_button 'Export application data (CSV)'
  end

  def and_i_fill_in_the_form_incorrectly
    choose 'All applications'

    click_export_data
  end

  def then_i_get_validation_errors
    expect(page).to have_content('Select at least one year')
    expect(page).to have_content('Select at least one organisation')
  end

  def and_i_fill_out_the_form_for_applications_this_year_of_any_status_for_the_first_provider
    check RecruitmentCycle::CYCLES[RecruitmentCycle.current_year.to_s]
    choose 'All applications'
    check @current_provider_user.providers.first.name

    click_export_data
  end

  def then_the_downloaded_file_includes_applications_this_year_of_any_status_for_the_first_provider
    csv_data = CSV.parse(page.body, headers: true)
    expect_export_to_include_data_for_application(csv_data, @application_accepted)
    expect_export_to_include_data_for_application(csv_data, @application_deferred)
    expect_export_to_include_data_for_application(csv_data, @application_declined)
    expect_export_to_include_data_for_application(csv_data, @application_withdrawn)
    expect(csv_data['application_choice_id']).not_to include(@application_accepted_previous_cycle.id.to_s)
    expect(csv_data['application_choice_id']).not_to include(@application_second_provider.id.to_s)
  end

  def and_i_fill_out_the_form_for_applications_all_years_of_deferred_and_accepted_offers_for_the_first_provider
    RecruitmentCycle.years_visible_to_providers.each do |year|
      check RecruitmentCycle::CYCLES[year.to_s]
    end
    choose 'Applications with a specific status'
    check 'Deferred'
    check 'Accepted'
    check @current_provider_user.providers.first.name

    click_export_data
  end

  def then_the_downloaded_file_includes_applications_all_years_of_deferred_and_accepted_offers_for_the_first_provider
    csv_data = CSV.parse(page.body, headers: true)
    expect_export_to_include_data_for_application(csv_data, @application_accepted)
    expect_export_to_include_data_for_application(csv_data, @application_deferred)
    expect_export_to_include_data_for_application(csv_data, @application_accepted_previous_cycle)
    expect(csv_data['application_choice_id']).not_to include(@application_declined.id.to_s)
    expect(csv_data['application_choice_id']).not_to include(@application_withdrawn.id.to_s)
    expect(csv_data['application_choice_id']).not_to include(@application_second_provider.id.to_s)
  end

  def expect_export_to_include_data_for_application(csv_data, application)
    expect(csv_data['application_choice_id']).to include(application.id.to_s)
    expect(csv_data['email']).to include(application.application_form.candidate.email_address)
    expect(csv_data['provider_code']).to include(application.provider.code)
    expect(csv_data['course_code']).to include(application.course.code)
  end
end
