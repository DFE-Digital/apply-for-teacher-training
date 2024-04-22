require 'rails_helper'

RSpec.feature 'Visit provider recruitment performance report page' do
  include DfESignInHelpers

  before { FeatureFlag.activate(:recruitment_performance_report) }

  scenario 'provider report has been generated' do
    given_a_provider_and_provider_user_exists
    and_a_provider_recruitment_performance_report_has_been_generated
    and_national_recruitment_performance_report_has_been_generated
    and_i_am_signed_in_as_provider_user
    and_i_visit_the_provider_recruitment_report_page
    then_i_see_the_report
  end

  scenario 'provider report has not been generated' do
    given_a_provider_and_provider_user_exists
    and_i_am_signed_in_as_provider_user
    and_i_visit_the_provider_recruitment_report_page
    then_i_see_no_report_message
  end

private

  def given_a_provider_and_provider_user_exists
    @provider_user = create(:provider_user, :with_dfe_sign_in, email_address: 'email@provider.ac.uk')
    @provider = @provider_user.providers.first
  end

  def and_a_provider_recruitment_performance_report_has_been_generated
    create(:provider_recruitment_performance_report, provider: @provider)
  end

  def and_national_recruitment_performance_report_has_been_generated
    create(:national_recruitment_performance_report)
  end

  def and_i_visit_the_provider_recruitment_report_page
    visit provider_interface_reports_provider_recruitment_performance_report_path(provider_id: @provider.id)
  end

  def then_i_see_the_report
    expect(page).to have_content('Recruitment performance weekly report 2023 to 2024')
    expect(page).to have_content("This report shows your organisation's initial teacher training (ITT) recruitment performance so far this recruitment cycle")
  end

  def then_i_see_no_report_message
    expect(page).to have_content('Recruitment performance weekly report 2023 to 2024')
    expect(page).to have_content('This report is not ready to view.')
  end

  def and_i_am_signed_in_as_provider_user
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end
  alias_method :given_i_am_signed_in_as_provider_user, :and_i_am_signed_in_as_provider_user
end
