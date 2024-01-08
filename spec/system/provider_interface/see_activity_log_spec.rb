require 'rails_helper'

RSpec.feature 'See activity log' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider visits application page' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_i_have_a_manage_account
    and_my_organisation_has_applications
    and_the_provider_activity_log_feature_flag_is_on
    and_i_sign_in_to_the_provider_interface

    when_i_click_on_the_activity_log_tab
    then_i_should_see_events_for_all_applications_belonging_to_my_providers
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def and_i_have_a_manage_account
    provider_user = provider_user_exists_in_apply_database
    @provider1, @provider2 = provider_user.providers
  end

  def and_my_organisation_has_applications
    course1 = create(:course, provider: @provider1, name: 'Course 1')
    course2 = create(:course, provider: @provider2, accredited_provider: @provider1, name: 'Course 2')
    course3 = create(:course, provider: create(:provider), accredited_provider: @provider1, name: 'Course 3')
    course4 = create(:course, provider: create(:provider), name: 'Course 4')
    course5 = create(:course, provider: @provider1, name: 'Course 5')

    course_option1 = create(:course_option, course: course1)
    course_option2 = create(:course_option, course: course2)
    course_option3 = create(:course_option, course: course3)
    course_option4 = create(:course_option, course: course4)
    course_option5 = create(:course_option, course: course5)

    @choice1 = create(:application_choice, :awaiting_provider_decision, status: 'awaiting_provider_decision', course_option: course_option1)
    create(:application_choice_audit, :awaiting_provider_decision, application_choice: @choice1)

    @choice2 = create(:application_choice, :rejected, course_option: course_option2)
    create(:application_choice_audit, :with_rejection, application_choice: @choice2)

    @choice3 = create(:application_choice, :offered, course_option: course_option3)
    create(:application_choice_audit, :with_offer, application_choice: @choice3)

    @choice4 = create(:application_choice, :offered, course_option: course_option4)
    create(:application_choice_audit, :with_offer, application_choice: @choice4)

    @choice5 = create(:application_choice, :offered, course_option: course_option5)
    create(:application_form_audit, application_choice: @choice5, changes: { 'date_of_birth' => %w[01-01-2000 01-02-2002] })
  end

  def and_the_provider_activity_log_feature_flag_is_on
    FeatureFlag.activate(:provider_activity_log)
  end

  def and_i_should_see_the_applications_menu_item_highlighted
    link = page.find_link('Applications', class: 'app-primary-navigation__link')
    expect(link['aria-current']).to eq('page')
  end

  def when_i_click_on_the_activity_log_tab
    click_link_or_button 'Activity log'
  end

  def then_i_should_see_events_for_all_applications_belonging_to_my_providers
    expect(page).to have_content @choice5.current_course.name
    expect(page).to have_content @choice3.current_course.name
    expect(page).to have_content @choice2.current_course.name
    expect(page).to have_content @choice1.current_course.name
    expect(page).to have_no_content @choice4.current_course.name
  end
end
