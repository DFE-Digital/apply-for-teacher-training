require 'rails_helper'

RSpec.feature 'Provider defers an offer' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Provider defers an offer' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_an_offered_application_choice_exists_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_i_view_an_offered_application

    when_i_navigate_to_the_offer_tab
    and_i_click_on_defer_offer
    then_i_am_asked_to_confirm_deferral_of_the_offer

    when_i_confirm_deferral_of_the_offer
    then_i_am_back_at_the_offer_page
    and_i_can_see_the_application_offer_is_deferred
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_an_offered_application_choice_exists_for_my_provider
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_offered = create(:application_choice,
                                  :with_completed_application_form,
                                  :with_accepted_offer,
                                  current_course_option: course_option)
  end

  def and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    provider_user_exists_in_apply_database
    permit_make_decisions!
  end

  def and_i_view_an_offered_application
    visit provider_interface_application_choice_path(
      @application_offered.id,
    )
  end

  def when_i_navigate_to_the_offer_tab
    click_on 'Offer'
  end

  def and_i_click_on_defer_offer
    click_on 'Defer offer'
  end

  def then_i_am_asked_to_confirm_deferral_of_the_offer
    expect(page).to have_current_path(
      provider_interface_application_choice_new_defer_offer_path(
        @application_offered.id,
      ),
    )
    expect(page).to have_content 'Confirm offer deferral'
  end

  def when_i_confirm_deferral_of_the_offer
    click_on 'Confirm offer deferral'
  end

  def then_i_am_back_at_the_offer_page
    within '.govuk-heading-xl' do
      expect(page).to have_content @application_offered.application_form.first_name
      expect(page).to have_content @application_offered.application_form.last_name
    end

    expect(page).to have_content 'Offer'
  end

  def and_i_can_see_the_application_offer_is_deferred
    expect(page).to have_content 'Offer deferred'
  end
end
