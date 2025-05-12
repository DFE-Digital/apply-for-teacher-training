require 'rails_helper'

RSpec.describe 'Export applications in HESA format' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'download CSVs of application data with translated HESA codes for the current and previous recruitment cycle year' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface
    when_i_visit_the_reports_page
    and_i_click_export_hesa_data
    then_i_can_see_links_to_the_report_for_the_current_and_previous_cycles
    and_i_can_download_application_data_as_csv_for_the_current_recruitment_cycle
    and_i_can_download_application_data_as_csv_for_the_previous_recruitment_cycle
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_courses_with_applications
    current_provider_user = ProviderUser.last
    providers = current_provider_user.providers
    course = create(:course, provider: providers.first)
    course_option = create(:course_option, course:)
    @applications = create_list(:application_choice,
                                5,
                                :accepted,
                                course_option:)

    # Make sure at least one application does not have a degree
    @applications.last.application_form.application_qualifications.degrees.delete_all

    previous_year_course = create(:course, provider: providers.first, recruitment_cycle_year: previous_timetable.recruitment_cycle_year)
    previous_year_course_option = create(:course_option, course: previous_year_course)
    @last_years_applications = create_list(:application_choice,
                                           5,
                                           :accepted,
                                           course_option: previous_year_course_option)
  end

  def when_i_visit_the_reports_page
    visit provider_interface_reports_path
  end

  def and_i_click_export_hesa_data
    click_link_or_button 'Export data for Higher Education Statistics Agency (HESA)'
  end

  def then_i_can_see_links_to_the_report_for_the_current_and_previous_cycles
    expect(page).to have_content("The data will include all candidates who have accepted an offer since #{current_timetable.apply_opens_at.to_fs(:govuk_date)}")
    expect(page).to have_content("The data will include all candidates who have accepted an offer from #{previous_timetable.apply_opens_at.to_fs(:govuk_date)} to #{previous_timetable.decline_by_default_at.to_fs(:govuk_date)}.")
  end

  def and_i_can_download_application_data_as_csv_for_the_current_recruitment_cycle
    click_link_or_button "Export data for #{current_timetable.cycle_range_name} (CSV)"

    csv = CSV.parse(page.body, headers: true)
    expect(csv.headers).to eq(%w[id status first_name last_name date_of_birth nationality
                                 domicile email recruitment_cycle_year provider_code accredited_provider_name course_code site_code
                                 study_mode SBJCA QLAIM FIRSTDEG DEGTYPE DEGSBJ DEGCLSS institution_country DEGSTDT DEGENDDT
                                 institution_details sex disabilities ethnicity])

    expect(csv['id'].sort).to eq(@applications.map { |a| a.id.to_s }.sort)
    expect(csv['email'].sort).to eq(@applications.map { |a| a.application_form.candidate.email_address }.sort)
    expect(csv['provider_code'].sort).to eq(@applications.map { |a| a.provider.code }.sort)
    expect(csv['course_code'].sort).to eq(@applications.map { |a| a.course.code }.sort)
  end

  def and_i_can_download_application_data_as_csv_for_the_previous_recruitment_cycle
    visit provider_interface_reports_hesa_exports_path
    click_link_or_button "Export data for #{previous_timetable.cycle_range_name} (CSV)"

    csv = CSV.parse(page.body, headers: true)
    expect(csv.headers).to eq(%w[id status first_name last_name date_of_birth nationality
                                 domicile email recruitment_cycle_year provider_code accredited_provider_name course_code site_code
                                 study_mode SBJCA QLAIM FIRSTDEG DEGTYPE DEGSBJ DEGCLSS institution_country DEGSTDT DEGENDDT
                                 institution_details sex disabilities ethnicity])

    expect(csv['id'].sort).to eq(@last_years_applications.map { |a| a.id.to_s }.sort)
    expect(csv['email'].sort).to eq(@last_years_applications.map { |a| a.application_form.candidate.email_address }.sort)
    expect(csv['provider_code'].sort).to eq(@last_years_applications.map { |a| a.provider.code }.sort)
    expect(csv['course_code'].sort).to eq(@last_years_applications.map { |a| a.course.code }.sort)
  end
end
