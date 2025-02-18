require 'rails_helper'

RSpec.describe 'Provider changes a course with error' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Display update errors' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_the_provider_user_can_offer_multiple_provider_courses

    when_i_visit_the_provider_interface
    and_i_click_the_application_choice
    and_i_click_on_change_the_training_provider
    then_i_see_a_list_of_training_providers_to_select_from

    when_i_select_a_different_provider
    and_i_click_continue
    then_i_see_a_list_of_courses_to_select_from

    when_i_select_a_different_course
    and_i_click_continue
    then_the_review_page_is_loaded

    when_the_update_action_cannot_be_done
    and_i_click_update_course
    then_i_see_the_error_message
  end

  def given_i_am_a_provider_user
    @provider_user = create(:provider_user, :with_dfe_sign_in, :with_set_up_interviews)
    user_exists_in_dfe_sign_in(email_address: @provider_user.email_address)
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def and_the_provider_user_can_offer_multiple_provider_courses
    @target_provider = create(:provider)

    @source_provider = @provider_user.providers.first
    @ratifying_provider = create(:provider)

    @course = build(:course, :full_time, provider: @source_provider, accredited_provider: @ratifying_provider)
    @course_option = build(:course_option, course: @course)

    @application_form = build(:application_form, :minimum_info)

    @application_choice = create(:application_choice, :awaiting_provider_decision,
                                 application_form: @application_form,
                                 course_option: @course_option)

    @target_course = create(:course, :open, study_mode: :full_time, provider: @target_provider, accredited_provider: @ratifying_provider)

    @one_mode_and_location_course = create(:course, :open, study_mode: :full_time, provider: @target_provider, accredited_provider: @ratifying_provider)
    @one_mode_and_location_course_option = create(:course_option, :full_time, site: create(:site, provider: @one_mode_and_location_course.provider), course: @one_mode_and_location_course)

    @target_course_option = create(:course_option, :part_time, course: @target_course)

    # Give the ProviderUser permission on the courses belonging to their provider
    create(:provider_permissions, provider: @target_provider, provider_user: @provider_user, make_decisions: true, set_up_interviews: true)

    # Allow the ProviderUser to move courses from one provider to another
    create(
      :provider_relationship_permissions,
      training_provider: @source_provider,
      ratifying_provider: @ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )

    create(
      :provider_relationship_permissions,
      training_provider: @target_provider,
      ratifying_provider: @ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_click_the_application_choice
    click_link_or_button @application_choice.application_form.full_name
  end

  def and_i_click_on_change_the_training_provider
    within(all('.govuk-summary-list__row').find { |e| e.text.include?('Training provider') }) do
      click_link_or_button 'Change'
    end
  end

  def then_i_see_a_list_of_training_providers_to_select_from
    expect(page).to have_content "Update course - #{@application_form.full_name}"
    expect(page).to have_content 'Training provider'
  end

  def when_i_select_a_different_provider
    choose @target_provider.name_and_code
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  def then_i_see_a_list_of_courses_to_select_from
    expect(page).to have_content "Update course - #{@application_form.full_name}"
    expect(page).to have_content 'Course'
  end

  def when_i_select_a_different_course
    choose @target_course.name_and_code
  end

  def then_the_review_page_is_loaded
    expect(page).to have_content "Update course - #{@application_form.full_name}"
    expect(page).to have_content 'Check details and update course'
  end

  def and_i_click_update_course
    click_link_or_button 'Update course'
  end

  def when_the_update_action_cannot_be_done
    allow_any_instance_of(ProviderInterface::CourseWizard).to receive(:valid?).with(:save).and_return(false) # rubocop:disable RSpec/AnyInstance
  end

  def then_i_see_the_error_message
    expect(page).to have_content('The course could not be changed')
  end
end
