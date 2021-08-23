require 'rails_helper'

RSpec.feature 'View active status of applications report' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:provider) { create(:provider, :with_signed_agreement) }
  let(:other_provider) { create(:provider, :with_signed_agreement) }
  let(:course_without_accredited_provider) { create(:course, name: 'Beekeeping', provider: provider, accredited_provider: nil) }
  let(:course_option_without_accredited_provider) { create(:course_option, course: course_without_accredited_provider) }
  let(:course_with_other_accredited_provider) { create(:course, name: 'Archaeology', provider: provider, accredited_provider: other_provider) }
  let(:course_option_with_other_accredited_provider) { create(:course_option, course: course_with_other_accredited_provider) }
  let(:course_provider_accredits) { create(:course, name: 'Criminology', provider: other_provider, accredited_provider: provider) }
  let(:course_option_provider_accredits) { create(:course_option, course: course_provider_accredits) }

  before do
    FeatureFlag.activate(:provider_reports_dashboard)
  end

  scenario 'a provider can navigate, view and export the active applications status report' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface
    when_i_visit_the_reports_page
    and_i_click_on_the_status_of_active_applications_report
    then_i_can_view_the_active_course_data_for_my_provider
    and_i_can_download_the_data_as_a_csv
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    @provider_user = provider_user_exists_in_apply_database
    @provider_user.update(providers: [provider])
  end

  def and_my_organisation_has_courses_with_applications
    create(:application_choice, status: :interviewing, course_option: course_option_with_other_accredited_provider)
    create(:application_choice, status: :pending_conditions, course_option: course_option_with_other_accredited_provider)
    create(:application_choice, status: :interviewing, course_option: course_option_without_accredited_provider)
    create(:application_choice, status: :pending_conditions, course_option: course_option_without_accredited_provider)
    create(:application_choice, status: :recruited, course_option: course_option_provider_accredits)
    create(:application_choice, status: :offer, course_option: course_option_provider_accredits)
  end

  def when_i_visit_the_reports_page
    visit provider_interface_reports_path
  end

  def and_i_click_on_the_status_of_active_applications_report
    click_on 'Status of active applications'
  end

  def then_i_can_view_the_active_course_data_for_my_provider
    expect(page).to have_content('Status of active applications')
    expect(page).to have_content(provider.name)
    within 'table thead tr' do
      expect(page).to have_content('Course')
      expect(page).to have_content('Received')
      expect(page).to have_content('Interviewing')
      expect(page).to have_content('Offered')
      expect(page).to have_content('Conditions pending')
      expect(page).to have_content('Recruited')
    end
    within 'table tbody' do
      expect(page).to have_content(course_with_other_accredited_provider.name)
      expect(page).to have_content(course_without_accredited_provider.name)
      expect(page).to have_content(course_provider_accredits.name)
    end
  end

  def and_i_can_download_the_data_as_a_csv
    click_on 'Export data (CSV)'

    csv = CSV.parse(page.body, headers: true)
    expect(csv.headers).to eq(['Name', 'Code', 'Partner organisation', 'Received', 'Interviewing', 'Offered', 'Conditions pending', 'Recruited'])

    expect(csv['Name']).to eq(['Archaeology', 'Beekeeping', 'Criminology', 'All courses'])
  end
end
