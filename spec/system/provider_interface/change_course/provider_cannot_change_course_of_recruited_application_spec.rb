require 'rails_helper'

RSpec.feature 'Provider changes a course' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Provider cannot change the course for recruited application' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_the_provider_user_can_offer_multiple_provider_courses

    when_i_visit_the_provider_interface
    and_i_click_an_application_choice_that_is_recruited
    then_i_cannot_change_the_course
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
    @provider = @provider_user.providers.first

    @ratifying_provider = create(:provider)

    @course = build(:course, :full_time, provider: @provider, accredited_provider: @ratifying_provider)

    @course_option = build(:course_option, course: @course)
    @recruited_application_choice = create(:application_choice, :with_completed_application_form, :recruited, course_option: @course_option)

    create(
      :provider_relationship_permissions,
      training_provider: @provider,
      ratifying_provider: @ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_click_an_application_choice_that_is_recruited
    click_link_or_button @recruited_application_choice.application_form.full_name
  end

  def then_i_cannot_change_the_course
    within('[data-qa="course-details"]') do
      expect(page).to have_no_content 'Change'
    end
  end

  def then_i_dont_see_the_study_mode_page
    expect(page.current_url).not_to include 'study-modes'
  end

  def and_i_select_a_new_location
    choose @one_mode_course_options.site_name
  end
end
