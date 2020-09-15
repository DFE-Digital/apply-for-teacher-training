require 'rails_helper'

RSpec.feature 'Application references performance CSV' do
  include DfESignInHelpers

  scenario 'support user can download a CSV with the application references performance report' do
    given_i_am_a_support_user
    and_there_is_an_application_with_references_in_the_system

    when_i_visit_the_service_performance_page
    and_i_click_on_download_reference_types_performance_report

    then_i_should_be_able_to_download_a_csv
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_with_references_in_the_system
    application_form = create(:application_form)

    create(:reference, feedback_status: 'feedback_refused', referee_type: 'academic', application_form: application_form)
    create(:reference, feedback_status: 'feedback_refused', referee_type: 'professional', application_form: application_form)
  end

  def when_i_visit_the_service_performance_page
    visit support_interface_performance_path
  end

  def and_i_click_on_download_reference_types_performance_report
    click_link 'Download application references (CSV)'
  end

  def then_i_should_be_able_to_download_a_csv
    af = ApplicationForm.first
    expect(page).to have_content af.support_reference
    expect(page).to have_content af.phase
    expect(page).to have_content af.application_references[0].referee_type
    expect(page).to have_content af.application_references[0].feedback_status
    expect(page).to have_content af.application_references[1].referee_type
    expect(page).to have_content af.application_references[1].feedback_status
  end
end
