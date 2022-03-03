require 'rails_helper'

RSpec.feature 'Provider changes a course' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }
  let(:ratifying_provider) { create(:provider) }
  let(:application_form) { build(:application_form, :minimum_info) }
  let!(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           application_form: application_form,
           course_option: course_option)
  end
  let(:course) do
    build(:course, :full_time, provider: provider, accredited_provider: ratifying_provider)
  end
  let(:course_option) { build(:course_option, course: course) }

  scenario 'Changing a course choice before point of offer (only one study mode)' do
    given_i_am_a_provider_user
    and_the_feature_flag_is_enabled
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_the_provider_has_multiple_courses
    and_the_provider_user_can_offer_multiple_provider_courses

    when_i_visit_the_provider_interface
    and_i_click_an_application_choice_that_is_interviewing
    and_i_click_on_change_the_training_provider
    then_i_see_a_list_of_training_providers_to_select_from

    when_i_select_a_different_provider
    and_i_click_continue
    then_i_see_a_list_of_courses_to_select_from

    when_i_select_a_course_with_one_study_mode
    and_i_click_continue
    then_i_dont_see_the_study_mode_page
  end

  scenario 'Changing a course choice before point of offer' do
    given_i_am_a_provider_user
    and_the_feature_flag_is_enabled
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_the_provider_has_multiple_courses
    and_the_provider_user_can_offer_multiple_provider_courses

    when_i_visit_the_provider_interface
    and_i_click_an_application_choice_that_is_interviewing
    and_i_click_on_change_the_training_provider
    then_i_see_a_list_of_training_providers_to_select_from

    when_i_select_a_different_provider
    and_i_click_continue
    then_i_see_a_list_of_courses_to_select_from

    when_i_select_a_different_course
    and_i_click_continue
    then_no_study_mode_is_pre_selected
  end

  def given_i_am_a_provider_user
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  def and_the_feature_flag_is_enabled
    FeatureFlag.activate(:change_course_details_before_offer)
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def and_the_provider_has_multiple_courses
    @provider_available_course = create(:course, :open_on_apply, study_mode: :full_time, provider: provider, accredited_provider: ratifying_provider)
    create(:course, :open_on_apply, provider: provider)
    course_options = [create(:course_option, :full_time, course: @provider_available_course),
                      create(:course_option, :full_time, course: @provider_available_course),
                      create(:course_option, :full_time, course: @provider_available_course)]

    @provider_available_course_option = course_options.sample
  end

  def and_the_provider_user_can_offer_multiple_provider_courses
    @selected_provider = create(:provider, :with_signed_agreement)
    create(:provider_permissions, provider: @selected_provider, provider_user: provider_user, make_decisions: true)
    courses = [create(:course, study_mode: :full_time_or_part_time, provider: @selected_provider, accredited_provider: ratifying_provider),
               create(:course, :open_on_apply, study_mode: :full_time_or_part_time, provider: @selected_provider, accredited_provider: ratifying_provider)]
    @selected_course = courses.sample

    @one_mode_course = create(:course, :open_on_apply, study_mode: :full_time, provider: @selected_provider, accredited_provider: ratifying_provider)
    create(:course_option, :full_time, course: @one_mode_course)

    course_options = [create(:course_option, :part_time, course: @selected_course),
                      create(:course_option, :full_time, course: @selected_course),
                      create(:course_option, :full_time, course: @selected_course),
                      create(:course_option, :part_time, course: @selected_course)]

    create(
      :provider_relationship_permissions,
      training_provider: provider,
      ratifying_provider: ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )

    create(
      :provider_relationship_permissions,
      training_provider: @selected_provider,
      ratifying_provider: ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )

    @selected_course_option = course_options.sample
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_click_an_application_choice_that_is_interviewing
    click_on application_choice.application_form.full_name
  end

  def and_i_click_on_change_the_training_provider
    within(all('.govuk-summary-list__row')[11]) do
      click_on 'Change'
    end
  end

  def then_i_see_a_list_of_training_providers_to_select_from
    expect(page).to have_content "Update course - #{application_form.full_name}"
    expect(page).to have_content 'Training provider'
  end

  def when_i_select_a_different_provider
    choose @selected_provider.name_and_code
  end

  def and_i_click_continue
    click_on t('continue')
  end

  def then_i_see_a_list_of_courses_to_select_from
    expect(page).to have_content "Update course - #{application_form.full_name}"
    expect(page).to have_content 'Course'
  end

  def when_i_select_a_different_course
    choose @selected_course.name_and_code
  end

  def when_i_select_a_course_with_one_study_mode
    choose @one_mode_course.name_and_code
  end

  def then_i_dont_see_the_study_mode_page
    expect(page.current_url).not_to include 'study-modes'
  end

  def then_no_study_mode_is_pre_selected
    expect(page).to have_content "Update course - #{application_form.full_name}"
    expect(page).to have_content 'Full time or part time'
    expect(find_field('Full time')).not_to be_checked
    expect(find_field('Part time')).not_to be_checked
  end
end
