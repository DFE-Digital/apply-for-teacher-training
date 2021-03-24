require 'rails_helper'

RSpec.feature 'Provider changes an offer' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  before do
    FeatureFlag.deactivate(:updated_offer_flow)
  end

  scenario 'Provider changes an offer' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_two_providers
    and_i_am_permitted_to_make_decisions_for_my_providers
    and_an_offered_application_choice_exists_for_one_of_my_providers
    and_other_full_time_and_part_time_courses_exist_for_this_provider
    and_an_older_course_exists_for_this_provider
    and_i_sign_in_to_the_provider_interface
    and_i_view_an_offered_application

    when_i_click_on_change_provider
    then_i_see_all_my_providers

    when_i_click_on_continue
    then_i_see_all_courses_for_this_provider_year_and_study_mode
    and_i_can_change_the_course
    and_i_can_change_the_study_mode
    and_i_see_all_available_locations_for_this_study_mode
    and_i_can_change_the_location

    when_i_inspect_and_confirm_these_changes
    then_the_offer_has_new_course_study_mode_and_location_details

    given_i_am_the_candidate_of_the_changed_offer
    then_i_receive_an_email_about_the_changed_offer
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_two_providers
    provider_user_exists_in_apply_database
    @provider_user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @provider = Provider.find_by(code: 'ABC')
  end

  def and_i_am_permitted_to_make_decisions_for_my_providers
    permit_make_decisions!
  end

  def and_an_offered_application_choice_exists_for_one_of_my_providers
    # Course @course_option_one belongs to is exclusively full time
    @course_option_one = course_option_for_provider(provider: @provider, study_mode: 'full_time')
    @application_offered = create(:application_choice, :with_offer, course_option: @course_option_one, offered_course_option: @course_option_one)
  end

  def and_other_full_time_and_part_time_courses_exist_for_this_provider
    # Course with both study modes and associated course options
    @both_modes_course = create(:course, :open_on_apply, :with_both_study_modes, provider: @provider)
    @course_option_two = create(:course_option, :full_time, course: @both_modes_course)
    @course_option_three = create(:course_option, :part_time, course: @both_modes_course)
    # Exclusively part time course with associated course option
    @part_time_course = create(:course, :open_on_apply, :part_time, provider: @provider)
    @course_option_four = create(:course_option, :part_time, course: @part_time_course)
  end

  def and_an_older_course_exists_for_this_provider
    @old_course = create(
      :course,
      :open_on_apply,
      :with_both_study_modes,
      recruitment_cycle_year: 2019,
      provider: @provider,
    )
    create(:course_option, :full_time, course: @old_course)
    create(:course_option, :part_time, course: @old_course)
  end

  def and_i_view_an_offered_application
    visit provider_interface_application_choice_path(
      @application_offered.id,
    )
  end

  def when_i_click_on_change_provider
    visit provider_interface_application_choice_path(@application_offered.id)
    click_on 'Offer'
    click_on 'Change training provider'
  end

  def then_i_see_all_my_providers
    expect(page).to have_content @provider_user.providers.first.name
    expect(page).to have_content @provider_user.providers.second.name
  end

  def when_i_click_on_continue
    click_on t('continue')
  end

  def then_i_see_all_courses_for_this_provider_year_and_study_mode
    expect(page).not_to have_content @old_course.name_and_code
    expect(page).to have_content @course_option_one.course.name_and_code
    expect(page).to have_content @part_time_course.name_and_code
    expect(page).to have_content @both_modes_course.name_and_code
  end

  def and_i_can_change_the_course
    choose @both_modes_course.name_and_code
    click_on t('continue')
  end

  def and_i_can_change_the_study_mode
    choose 'Part time'
    click_on t('continue')
  end

  def and_i_see_all_available_locations_for_this_study_mode
    expect(page).not_to have_content @course_option_one.site.name # wrong everything
    expect(page).not_to have_content @course_option_two.site.name # wrong study_mode
    expect(page).to have_content @course_option_three.site.name
    expect(page).not_to have_content @course_option_four.site.name # wrong course
  end

  def and_i_can_change_the_location
    choose @course_option_three.site.name
    click_on t('continue')
  end

  def when_i_inspect_and_confirm_these_changes
    expect(page).to have_content @application_offered.application_form.full_name

    expect(page).to have_content @course_option_one.course.name_and_code
    expect(page).to have_content @course_option_one.site.name_and_address

    expect(page).to have_content @course_option_three.course.name_and_code
    expect(page).to have_content @course_option_three.site.name_and_address

    click_on 'Change offer'
  end

  def then_the_offer_has_new_course_study_mode_and_location_details
    click_on 'Offer'

    expect(page).to have_content @course_option_three.course.name_and_code
    expect(page).to have_content @course_option_three.site.name_and_address
    expect(page).to have_content 'Part time'
    expect(@application_offered.reload.offered_option).to eq(@course_option_three)
  end

  def given_i_am_the_candidate_of_the_changed_offer
    @candidate = @application_offered.application_form.candidate
  end

  def then_i_receive_an_email_about_the_changed_offer
    open_email(@candidate.email_address)

    expect(current_email.subject).to include(
      t('candidate_mailer.changed_offer.subject', provider_name: @provider.reload.name),
    )
  end
end
