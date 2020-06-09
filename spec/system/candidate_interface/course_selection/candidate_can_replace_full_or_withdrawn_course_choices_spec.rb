require 'rails_helper'

RSpec.describe 'A course option selected by a candidate has become full or been withdrawn' do
  include CandidateHelper
  include CourseOptionHelpers

  scenario 'when a candidate arrives at the dashboard they can follow the replace course flow' do
    given_the_replace_full_or_withdrawn_application_choices_is_active
    and_i_have_submitted_my_application
    and_one_of_my_application_choices_has_become_full
    and_another_course_exists

    when_i_arrive_at_my_application_dashboard
    then_i_see_that_one_of_my_choices_in_not_available

    given_i_have_two_full_course_choices

    when_i_arrive_at_my_application_dashboard
    then_i_see_that_multiple_choices_are_not_available
  end

  def given_the_replace_full_or_withdrawn_application_choices_is_active
    FeatureFlag.activate('replace_full_or_withdrawn_application_choices')
  end

  def and_i_have_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_one_of_my_application_choices_has_become_full
    @course_option = @application.application_choices.first.course_option
    @course_option.no_vacancies!
  end

  def and_another_course_exists
    course_option_for_provider_code(provider_code: '1N1')
  end

  def when_i_arrive_at_my_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_see_that_one_of_my_choices_in_not_available
    expect(page).to have_content 'One of your choices is not available anymore.'
  end

  def given_i_have_two_full_course_choices
    application_choice = create(:application_choice, application_form: @application)
    application_choice.course_option.no_vacancies!
  end

  def then_i_see_that_multiple_choices_are_not_available
    expect(page).to have_content 'Some of your choices are not available anymore.'
  end
end
