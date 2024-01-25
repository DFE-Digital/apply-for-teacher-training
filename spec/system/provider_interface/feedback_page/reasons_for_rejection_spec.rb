require 'rails_helper'

RSpec.describe 'Feedback page' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  scenario 'correct info for reasons_for_rejection' do
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
    @application_choice = create(:application_choice, :reasons_for_rejection, course_option:)
  end

  def and_i_visit_the_feedback_page
    visit provider_interface_application_choice_feedback_path(@application_choice)
  end

  def then_i_see_the_rejection_feedback
    expect(page.text).to include('Feedback',
                                 'This application was rejected on 11 October 2023. The following feedback was sent to the candidate.',
                                 'Something you did',
                                 'Didn’t reply to our interview offer.',
                                 'Didn’t attend interview.',
                                 'Persistent scratching',
                                 'Not scratch so much',
                                 'Quality of application',
                                 'Personal statement',
                                 'Use a spellchecker',
                                 'Subject knowledge',
                                 'Claiming to be the \'world\'s leading expert\' seemed a bit strong',
                                 'Lights on but nobody home',
                                 'Study harder',
                                 'Qualifications',
                                 'No English GCSE grade 4 (C) or above, or valid equivalent.',
                                 'All the other stuff',
                                 'Performance at interview',
                                 'Be fully dressed',
                                 'Honesty and professionalism',
                                 'Fake news',
                                 'Clearly not a popular student',
                                 'Safeguarding issues',
                                 'We need to run further checks')
  end
end
