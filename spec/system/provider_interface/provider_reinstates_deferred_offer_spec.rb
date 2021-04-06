require 'rails_helper'

RSpec.feature 'Provider reinstates deferred offer' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:provider) { Provider.find_by(code: 'ABC') }
  let(:course_current_year) { create(:course, :open_on_apply, provider: provider) }
  let(:course_previous_year) { create(:course, :open_on_apply, :previous_year, provider: provider) }
  let(:course_previous_year_but_still_available) { create(:course, :open_on_apply, :previous_year_but_still_available, provider: provider) }

  let(:choices) do
    {
      wrong_year: new_application_choice(create(:course_option, course: course_current_year)),
      no_match: new_application_choice(create(:course_option, course: course_previous_year)),
      reinstatable: new_application_choice(
        create(
          :course_option,
          :previous_year_but_still_available,
          course: course_previous_year_but_still_available,
        ),
      ),
    }
  end

  def new_application_choice(course_option)
    create(
      :application_choice,
      :with_deferred_offer_previously_recruited,
      course_option: course_option,
    )
  end

  scenario 'Provider can reinstate a deferred offer from previous cycle' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_applications_with_status_offer_deferred_exist
    and_i_am_permitted_to_make_decisions_for_my_providers
    and_i_sign_in_to_the_provider_interface

    when_i_visit_a_application_with_status_offer_deferred_from_current_cycle
    then_i_do_not_see_a_prompt_to_review_the_deferred_offer

    when_i_visit_an_offer_deferred_application_that_cannot_be_reinstated
    then_i_see_a_prompt_to_review_the_deferred_offer
    when_i_click_to_review_the_deferred_offer
    then_i_cannot_click_to_continue

    when_i_visit_a_reinstatable_offer_from_previous_cycle
    then_i_see_a_prompt_to_review_the_deferred_offer

    when_i_click_to_review_the_deferred_offer
    then_i_can_see_the_details_of_the_deferred_offer
    and_i_can_specify_if_offer_conditions_are_still_met
    and_i_can_review_the_new_offer_conditions_and_details

    when_i_click_to_reinstate_the_offer
    then_i_see_a_success_flash_message
    and_the_application_has_status_conditions_met
    and_the_course_now_offered_is_from_the_current_year
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_applications_with_status_offer_deferred_exist
    expect(choices.values).to all(be_persisted)
  end

  def and_i_am_permitted_to_make_decisions_for_my_providers
    permit_make_decisions!
  end

  def when_i_visit_a_application_with_status_offer_deferred_from_current_cycle
    visit provider_interface_application_choice_path(choices[:wrong_year].id)
  end

  def when_i_visit_an_offer_deferred_application_that_cannot_be_reinstated
    visit provider_interface_application_choice_path(choices[:no_match].id)
  end

  def when_i_visit_a_reinstatable_offer_from_previous_cycle
    visit provider_interface_application_choice_path(choices[:reinstatable].id)
  end

  def then_i_do_not_see_a_prompt_to_review_the_deferred_offer
    expect(page).not_to have_content 'Review deferred offer'
  end

  def then_i_see_a_prompt_to_review_the_deferred_offer
    expect(page).to have_content 'Review deferred offer'
  end

  def when_i_click_to_review_the_deferred_offer
    click_on 'Review deferred offer'
  end

  def then_i_can_see_the_details_of_the_deferred_offer
    expect(page).to have_content choices[:reinstatable].current_course_option.site.name_and_address
  end

  def and_i_can_specify_if_offer_conditions_are_still_met
    click_on t('continue')
    choose 'Yes, all conditions are still met'
    click_on t('continue')
  end

  def then_i_cannot_click_to_continue
    expect { click_on t('continue') }.to raise_error Capybara::ElementNotFound
  end

  def and_i_can_review_the_new_offer_conditions_and_details
    expect(page).to have_content choices[:reinstatable].current_course_option.site.name_and_address
  end

  def when_i_click_to_reinstate_the_offer
    click_on 'Confirm offer'
  end

  def then_i_see_a_success_flash_message
    expect(page).to have_content 'Deferred offer successfully confirmed for current cycle'
  end

  def and_the_application_has_status_conditions_met
    expect(page).to have_content 'Conditions met'
  end

  def and_the_course_now_offered_is_from_the_current_year
    expect(choices[:reinstatable].reload.current_course.recruitment_cycle_year).to eq(RecruitmentCycle.current_year)
  end
end
