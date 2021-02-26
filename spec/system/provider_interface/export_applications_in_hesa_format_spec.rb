require 'rails_helper'

RSpec.feature 'Export applications in HESA format' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'download a CSV of application data with translated HESA codes' do
    FeatureFlag.activate(:export_hesa_data)
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface
    when_i_visit_the_export_applications_page
    and_i_click_export_data
    then_i_can_download_application_data_as_csv
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
    course_option = create(:course_option, course: course)
    @applications = create_list(:application_choice,
                                5,
                                :application_form_with_degree,
                                :with_accepted_offer,
                                course_option: course_option)
  end

  def when_i_visit_the_export_applications_page
    visit provider_interface_new_hesa_export_path
  end

  def and_i_click_export_data
    expect(page).to have_content('The data will include all candidates who have accepted an offer from any of your organisations.')
    expect(page).to have_content('Diversity information will be marked confidential if you do not have permission to view it.')

    click_button 'Export data'
  end

  def then_i_can_download_application_data_as_csv
    csv = CSV.parse(page.body, headers: true)
    expect(csv.headers).to eq(%w[id status first_name last_name date_of_birth nationality
                                 domicile email recruitment_cycle_year provider_code accredited_provider_name course_code site_code
                                 study_mode SBJCA QLAIM FIRSTDEG DEGTYPE DEGSBJ DEGCLSS institution_country DEGSTDT DEGENDDT
                                 institution_details sex disabilities ethnicity])

    expect(csv['id'].sort).to eq(@applications.map { |a| a.application_form.support_reference }.sort)
    expect(csv['email'].sort).to eq(@applications.map { |a| a.application_form.candidate.email_address }.sort)
    expect(csv['provider_code'].sort).to eq(@applications.map { |a| a.provider.code }.sort)
    expect(csv['course_code'].sort).to eq(@applications.map { |a| a.course.code }.sort)
  end
end
