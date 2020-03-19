require 'rails_helper'

RSpec.feature 'Provider makes changes before making an offer' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider makes changes to course and location' do
    given_i_am_a_provider_user_with_dfe_sign_in
    when_change_response_feature_is_activated
    and_i_am_permitted_to_see_applications_for_two_providers
    and_an_application_choice_exists_for_one_of_my_providers
    and_another_two_course_options_exist_for_this_provider
    and_i_sign_in_to_the_provider_interface
    and_i_view_an_application

    and_i_click_on_respond_to_application
    then_i_see_options_to_make_an_offer

    when_i_choose_make_offer_but_change_course
    then_i_see_all_courses_for_this_provider
    and_i_can_change_the_course
    and_i_see_all_available_locations_for_this_course
    and_i_can_change_the_location

    and_i_can_add_conditions_to_the_offer
    and_i_can_see_the_offer_confirmation_details
    then_a_new_offer_has_new_course_and_location_details
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def when_change_response_feature_is_activated
    FeatureFlag.activate('provider_change_response')
  end

  def and_i_am_permitted_to_see_applications_for_two_providers
    provider_user_exists_in_apply_database
    @provider_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @provider = Provider.find_by(code: 'ABC')
  end

  def and_an_application_choice_exists_for_one_of_my_providers
    @course_option_one = course_option_for_provider_code(provider_code: @provider.code)
    @application = create(:application_choice, :awaiting_provider_decision, course_option: @course_option_one)
  end

  def and_another_two_course_options_exist_for_this_provider
    @course_option_two = course_option_for_provider_code(provider_code: @provider.code)
    @course_option_three = create(:course_option, course: @course_option_two.course, site: create(:site, provider: @provider))
  end

  def and_i_view_an_application
    visit provider_interface_application_choice_path(
      @application.id,
    )
  end

  def and_i_click_on_respond_to_application
    visit provider_interface_application_choice_path(@application.id)
    click_on 'Respond to application'
  end

  def then_i_see_options_to_make_an_offer
    expect(page).to have_content 'Make an offer'
    expect(page).to have_content 'Make an offer but change course'
    expect(page).to have_content 'Make an offer but change location'
    expect(page).to have_content 'Make an offer but change training provider'
    expect(page).to have_content 'Reject application'
  end

  def when_i_choose_make_offer_but_change_course
    choose 'Make an offer but change course'
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

  def and_i_can_add_conditions_to_the_offer
    expect(page).to have_content 'Conditions of offer'
    expect(page).to have_content(@course_option_three.course.name_and_code)
    expect(page).to have_content(@course_option_three.site.name)

    fill_in 'First condition', with: 'Condition the first'
    fill_in 'Second condition', with: 'Condition the second'

    click_on 'Continue'
  end

  def and_i_can_see_the_offer_confirmation_details
    expect(page).to have_content 'Confirm offer'

    expect(page).to have_content(@course_option_three.course.name_and_code)
    expect(page).to have_content(@course_option_three.site.name)

    click_on 'Confirm offer'
  end

  def then_a_new_offer_has_new_course_and_location_details
    expect(page).to have_content @course_option_three.course.name_and_code
    expect(page).to have_content @course_option_three.site.name_and_address
    expect(@application.reload.offered_option).to eq(@course_option_three)
  end
end
