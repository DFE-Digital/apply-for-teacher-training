require 'rails_helper'

RSpec.describe 'Feedback page' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  scenario 'correct info for rejection_reasons' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_my_organisation_has_a_rejected_reason_application
    and_i_visit_the_feedback_page

    then_i_see_the_rejection_feedback
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def when_my_organisation_has_a_rejected_reason_application
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_choice = create(:application_choice, :rejected_reasons, course_option:)
  end

  def and_i_visit_the_feedback_page
    visit provider_interface_application_choice_feedback_path(@application_choice)
  end

  def then_i_see_the_rejection_feedback
    rejected_at_date = @application_choice.rejected_at.to_fs(:govuk_date)
    expect(page.text).to include('Feedback',
                                 "This application was rejected on #{rejected_at_date}. The following feedback was sent to the candidate.",
                                 'Qualifications',
                                 'We could find no record of your GCSEs.',
                                 'Personal statement',
                                 'We do not accept applications written in Old Norse.',
                                 'References',
                                 'We do not accept references from close family members, such as your mum.')
  end
end
