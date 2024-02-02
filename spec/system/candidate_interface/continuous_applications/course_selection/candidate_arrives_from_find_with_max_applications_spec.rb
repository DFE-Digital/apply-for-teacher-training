require 'rails_helper'

RSpec.feature 'Candidate arrives from Find with provider and course that is already added' do
  include CandidateHelper

  scenario 'The provider is only accepting applications on the Apply service' do
    given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_create_account_or_sign_in_path

    given_i_am_signed_in
    and_i_already_have_max_applications

    when_i_follow_a_link_from_find

    then_i_am_redirected_to_your_applications_tab
    and_i_see_a_message_about_the_limit
  end

  def given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply
    @provider = create(:provider, code: '8N5', name: 'Snape University')
    @course = create(:course, :open_on_apply, name: 'Potions', code: 'D75F', provider: @provider, recruitment_cycle_year: 2024)
    create(:course_option, course: @course)
  end

  def and_i_already_have_max_applications
    create_list(:application_choice, ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES,
                :unsubmitted,
                application_form: current_candidate.current_application)
  end

  def when_i_follow_a_link_from_find
    visit candidate_interface_apply_from_find_path(
      providerCode: @course.provider.code,
      courseCode: @course.code,
    )
  end

  def then_i_am_redirected_to_the_create_account_or_sign_in_path
    expect(page).to have_current_path candidate_interface_create_account_or_sign_in_path(
      providerCode: @provider.code,
      courseCode: @course.code,
    )
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def then_i_am_redirected_to_your_applications_tab
    expect(page).to have_current_path(
      candidate_interface_continuous_applications_choices_path,
    )
  end

  def and_i_see_a_message_about_the_limit
    expect(page).to have_content('You cannot have more than 4 applications. Remove an application first, and then apply to Potions.')
  end
end
