require 'rails_helper'

RSpec.feature 'Export applications' do
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
    @applications = create_list(:application_choice, 5, :with_offer, course_option: course_option)
  end

  def when_i_visit_the_export_applications_page
    visit provider_interface_applications_path
    click_on 'Export data'
  end

  def and_i_click_export_data
    expect(page).to have_content("Click 'Download' to download application data for the current cycle")

    click_on 'Download'
  end

  def then_i_can_download_application_data_as_csv
    csv = CSV.parse(page.body, headers: true)
    expect(csv.headers).to eq([
      'id', 'status', 'first name', 'last name', 'date of birth', 'nationality',
      'domicile', 'email address', 'recruitment cycle', 'provider code', 'accredited body',
      'course code', 'site code', 'study mode', 'SBJCA', 'QLAIM', 'FIRSTDEG', 'DEGTYPE',
      'DEGSBJ', 'DEGCLSS', 'institution country', 'DEGSTDT', 'DEGENDDT', 'institution details',
      'sex', 'disabilities', 'ethnicity'
    ])

    expect(csv['id'].sort).to eq(@applications.map { |a| a.application_form.support_reference }.sort)
    expect(csv['email address'].sort).to eq(@applications.map { |a| a.application_form.candidate.email_address }.sort)
    expect(csv['provider code'].sort).to eq(@applications.map { |a| a.provider.code }.sort)
    expect(csv['course code'].sort).to eq(@applications.map { |a| a.course.code }.sort)
  end
end
