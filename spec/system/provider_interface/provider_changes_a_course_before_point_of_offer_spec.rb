require 'rails_helper'

RSpec.feature 'Provider changes a course' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Changing a course choice before point of offer' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface
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

    when_i_select_a_study_mode
    and_i_click_continue
    then_i_am_taken_to_the_change_location_page

    when_i_select_a_new_location
    and_i_click_continue
    then_the_review_page_is_loaded

    when_i_click_change_course
    then_i_am_taken_to_the_change_course_page

    when_i_select_a_course_with_one_study_mode_and_one_location
    and_i_click_continue
    then_the_review_page_is_loaded

    when_i_click_back
    then_i_am_taken_to_the_change_course_page

    when_i_click_continue
    then_the_review_page_is_loaded

    when_i_click_update_course
    then_i_see_the_changed_offer_details
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
    @selected_provider = create(:provider)

    @provider = @provider_user.providers.first
    @ratifying_provider = create(:provider)
    @course = build(:course, :full_time, provider: @provider, accredited_provider: @ratifying_provider)
    @course_option = build(:course_option, course: @course)
    @application_form = build(:application_form, :minimum_info)

    @application_choice = create(:application_choice, :awaiting_provider_decision,
                                 application_form: @application_form,
                                 course_option: @course_option)
    create(:provider_permissions, provider: @selected_provider, provider_user: @provider_user, make_decisions: true, set_up_interviews: true)
    courses = [create(:course, study_mode: :full_time_or_part_time, provider: @selected_provider, accredited_provider: @ratifying_provider),
               create(:course, :open, study_mode: :full_time_or_part_time, provider: @selected_provider, accredited_provider: @ratifying_provider)]
    @selected_course = courses.sample

    @one_mode_and_location_course = create(:course, :open, study_mode: :full_time, provider: @selected_provider, accredited_provider: @ratifying_provider)
    @one_mode_and_location_course_option = create(:course_option, :full_time, site: create(:site, provider: @one_mode_and_location_course.provider), course: @one_mode_and_location_course)

    course_options = [create(:course_option, :part_time, course: @selected_course),
                      create(:course_option, :full_time, course: @selected_course),
                      create(:course_option, :full_time, course: @selected_course),
                      create(:course_option, :part_time, course: @selected_course)]

    create(
      :provider_relationship_permissions,
      training_provider: @provider,
      ratifying_provider: @ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )

    create(
      :provider_relationship_permissions,
      training_provider: @selected_provider,
      ratifying_provider: @ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )

    @selected_course_option = course_options.sample
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_click_an_application_choice_that_is_interviewing
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
    choose @selected_provider.name_and_code
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_see_a_list_of_courses_to_select_from
    expect(page).to have_content "Update course - #{@application_form.full_name}"
    expect(page).to have_content 'Course'
  end

  alias_method :then_i_am_taken_to_the_change_course_page, :then_i_see_a_list_of_courses_to_select_from

  def when_i_select_a_different_course
    choose @selected_course.name_and_code
  end

  def then_i_dont_see_the_study_mode_page
    expect(page.current_url).not_to include 'study-modes'
  end

  def then_no_study_mode_is_pre_selected
    expect(page).to have_content "Update course - #{@application_form.full_name}"
    expect(page).to have_content 'Full time or part time'
    expect(find_field('Full time')).not_to be_checked
    expect(find_field('Part time')).not_to be_checked
  end

  def when_i_select_a_study_mode
    choose @selected_course_option.study_mode.humanize
  end

  def then_i_am_taken_to_the_change_location_page
    expect(page).to have_content "Update course - #{@application_form.full_name}"
    expect(page).to have_content 'Location'
  end

  def when_i_select_a_new_location
    choose @selected_course_option.site_name
  end

  def and_i_select_a_new_location
    choose @one_mode_course_options.site_name
  end

  def then_the_review_page_is_loaded
    expect(page).to have_content "Update course - #{@application_form.full_name}"
    expect(page).to have_content 'Check details and update course'
  end

  def when_i_click_change_course
    @selected_course = @provider_available_course
    @selected_course_option = @provider_available_course_option

    within(all('.govuk-summary-list__row')[1]) do
      click_link_or_button 'Change'
    end
  end

  def when_i_select_a_course_with_one_study_mode_and_one_location
    choose @one_mode_and_location_course.name_and_code
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def when_i_click_update_course
    click_link_or_button 'Update course'
  end

  def then_i_see_the_changed_offer_details
    within(all('.govuk-summary-list')[3]) do
      expect(page).to have_content(@one_mode_and_location_course.provider.name)
      expect(page).to have_content(@one_mode_and_location_course.name_and_code)
      expect(page).to have_content(@one_mode_and_location_course.study_mode.humanize)
      expect(page).to have_content(@one_mode_and_location_course_option.site.name_and_code)
      expect(page).to have_content(@one_mode_and_location_course_option.site.address_line1)
      expect(page).to have_content(@one_mode_and_location_course_option.site.address_line2)
      expect(page).to have_content(@one_mode_and_location_course_option.site.address_line3)
    end
  end
end
