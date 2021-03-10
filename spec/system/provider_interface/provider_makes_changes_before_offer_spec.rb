require 'rails_helper'

RSpec.feature 'Provider makes changes before making an offer' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  before do
    FeatureFlag.deactivate(:updated_offer_flow)
  end

  scenario 'Provider makes changes to course and location' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_a_provider
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_an_application_choice_exists_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_i_view_an_application

    and_i_click_on_respond_to_application
    then_i_see_options_to_make_an_offer

    when_i_am_permitted_to_see_applications_for_another_provider
    and_two_course_options_exist_for_this_provider
    and_i_am_permitted_to_make_decisions_for_this_provider
    and_i_view_an_application
    and_i_click_on_respond_to_application

    then_i_see_options_to_make_an_offer_but_change_provider
    and_i_can_choose_to_make_an_offer_but_change_provider

    then_i_see_all_providers
    and_i_can_change_training_provider
    and_i_see_all_courses_for_this_provider
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

  def and_i_am_permitted_to_see_applications_for_a_provider
    @provider = create(:provider, :with_signed_agreement, code: 'ABC', name: 'Example Provider')
    @provider_user = create(:provider_user, providers: [@provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def and_an_application_choice_exists_for_my_provider
    @course_option_one = course_option_for_provider(provider: @provider)
    @application = create(:application_choice, :awaiting_provider_decision, course_option: @course_option_one)
  end

  def and_i_view_an_application
    visit provider_interface_application_choice_path(
      @application.id,
    )
  end

  def and_i_click_on_respond_to_application
    visit provider_interface_application_choice_path(@application.id)
    click_on 'Make decision'
  end

  def then_i_see_options_to_make_an_offer(provider_option: false)
    expect(page).to have_content 'Make an offer'
    expect(page).to have_content 'Make an offer but change course'
    expect(page).to have_content 'Make an offer but change location'

    if provider_option
      expect(page).to have_content 'Make an offer but change training provider'
    else
      expect(page).not_to have_content 'Make an offer but change training provider'
    end

    expect(page).to have_content 'Reject application'
  end

  def then_i_see_options_to_make_an_offer_but_change_provider
    then_i_see_options_to_make_an_offer(provider_option: true)
  end

  def when_i_am_permitted_to_see_applications_for_another_provider
    @another_provider = create(:provider, :with_signed_agreement, code: 'DEF', name: 'Another Provider')
    @provider_user.providers << @another_provider
  end

  def and_two_course_options_exist_for_this_provider
    @course_option_two = course_option_for_provider(provider: @another_provider)
    @course_option_three = create(:course_option,
                                  course: @course_option_two.course,
                                  site: create(:site, provider: @another_provider))
  end

  def and_i_am_permitted_to_make_decisions_for_this_provider
    permit_make_decisions!(provider: @another_provider)
  end

  def and_i_can_choose_to_make_an_offer_but_change_provider
    choose 'Make an offer but change training provider'
    click_on t('continue')
  end

  def then_i_see_all_providers
    expect(page).to have_content @another_provider.name_and_code
  end

  def and_i_can_change_training_provider
    choose @another_provider.name_and_code
    click_on t('continue')
  end

  def and_i_see_all_courses_for_this_provider
    @another_provider.courses.each do |course|
      expect(page).to have_content course.name_and_code
    end
  end

  def and_i_can_change_the_course
    choose @course_option_two.course.name_and_code
    click_on t('continue')
  end

  def and_i_see_all_available_locations_for_this_course
    @course_option_two.course.course_options.each do |course_option|
      expect(page).to have_content course_option.site.name
    end
  end

  def and_i_can_change_the_location
    choose @course_option_three.site.name
    click_on t('continue')
  end

  def and_i_can_add_conditions_to_the_offer
    expect(page).to have_content 'Conditions of offer'

    fill_in 'First condition', with: 'Condition the first'
    fill_in 'Second condition', with: 'Condition the second'

    click_on t('continue')
  end

  def and_i_can_see_the_offer_confirmation_details
    expect(page).to have_content 'Check and confirm offer'

    expect(page).to have_content(@course_option_three.course.name_and_code)
    expect(page).to have_content(@course_option_three.site.name)

    click_on 'Make offer'
  end

  def then_a_new_offer_has_new_course_and_location_details
    click_on 'Offer'

    expect(page).to have_content @course_option_three.course.name_and_code
    expect(page).to have_content @course_option_three.site.name_and_address
    expect(@application.reload.offered_option).to eq(@course_option_three)
  end
end
