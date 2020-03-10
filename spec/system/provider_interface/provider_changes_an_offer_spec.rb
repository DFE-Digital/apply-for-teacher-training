require 'rails_helper'

RSpec.feature 'Provider changes an offer' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider changes an offer' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_two_providers
    and_an_offered_application_choice_exists_for_one_of_my_providers
    and_another_two_course_options_exist_for_this_provider
    and_i_sign_in_to_the_provider_interface
    and_i_view_an_offered_application
    then_i_cannot_change_the_offer

    when_change_response_feature_is_activated
    and_i_click_on_change_provider
    then_i_see_all_my_providers

    when_i_click_on_continue
    then_i_see_all_courses_for_this_provider
    and_i_can_change_the_course
    and_i_see_all_available_locations_for_this_course
    and_i_can_change_the_location

    when_i_inspect_and_confirm_these_changes
    then_the_offer_has_new_course_and_location_details
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_two_providers
    provider_user_exists_in_apply_database
    @provider_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @provider = Provider.find_by(code: 'ABC')
  end

  def and_an_offered_application_choice_exists_for_one_of_my_providers
    @course_option_one = course_option_for_provider_code(provider_code: @provider.code)
    @application_offered = create(:application_choice, :with_offer, course_option: @course_option_one)
  end

  def and_another_two_course_options_exist_for_this_provider
    @course_option_two = course_option_for_provider_code(provider_code: @provider.code)
    @course_option_three = create(:course_option, course: @course_option_two.course, site: create(:site, provider: @provider))
  end

  def when_change_response_feature_is_activated
    FeatureFlag.activate('provider_change_response')
  end

  def then_i_cannot_change_the_offer
    first('a', text: 'Change', count: 0)
  end

  def and_i_view_an_offered_application
    visit provider_interface_application_choice_path(
      @application_offered.id,
    )
  end

  def and_i_click_on_change_provider
    visit provider_interface_application_choice_path(@application_offered.id)
    click_on 'Change training provider'
  end

  def then_i_see_all_my_providers
    expect(page).to have_content @provider_user.providers.first.name
    expect(page).to have_content @provider_user.providers.second.name
  end

  def when_i_click_on_continue
    click_on 'Continue'
  end

  def then_i_see_all_courses_for_this_provider
    @provider.courses.each do |course|
      expect(page).to have_content course.name_and_code
    end
  end

  def and_i_can_change_the_course
    choose @course_option_two.course.name_and_code
    click_on 'Continue'
  end

  def and_i_see_all_available_locations_for_this_course
    @course_option_two.course.course_options.each do |course_option|
      expect(page).to have_content course_option.site.name
    end
  end

  def and_i_can_change_the_location
    choose @course_option_three.site.name
    click_on 'Continue'
  end

  def when_i_inspect_and_confirm_these_changes
    expect(page).to have_content @application_offered.application_form.full_name

    expect(page).to have_content @course_option_one.course.name_and_code
    expect(page).to have_content @course_option_one.site.name_and_address

    expect(page).to have_content @course_option_three.course.name_and_code
    expect(page).to have_content @course_option_three.site.name_and_address

    click_on 'Change offer'
  end

  def then_the_offer_has_new_course_and_location_details
    expect(page).to have_content @course_option_three.course.name_and_code
    expect(page).to have_content @course_option_three.site.name_and_address
    expect(@application_offered.reload.offered_option).to eq(@course_option_three)
  end
end
