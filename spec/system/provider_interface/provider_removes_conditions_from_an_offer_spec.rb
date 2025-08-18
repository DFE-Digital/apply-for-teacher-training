require 'rails_helper'

RSpec.describe 'Remove offer conditions' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Provider user removes the conditions from an offer with javascript on', :js do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_an_authorised_provider_user
    and_i_can_access_the_provider_interface

    when_i_navigate_to_an_offer
    and_i_navigate_to_the_offer_tab
    and_i_click_on_add_or_change_conditions
    and_i_remove_all_conditions
    then_i_expect_to_see_the_updated_conditions

    when_i_click_on_add_or_change_conditions
    then_i_do_not_see_the_removed_condition

    when_i_send_the_new_offer
    then_the_candidate_has_the_new_conditions
  end

  scenario 'Provider user removes the conditions from an offer with javascript off', js: false do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_an_authorised_provider_user
    and_i_can_access_the_provider_interface

    when_i_navigate_to_an_offer
    and_i_navigate_to_the_offer_tab
    and_i_click_on_add_or_change_conditions
    and_i_remove_all_conditions
    then_i_expect_to_see_the_updated_conditions

    when_i_click_on_add_or_change_conditions
    then_i_do_not_see_the_removed_condition

    when_i_send_the_new_offer
    then_the_candidate_has_the_new_conditions
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_an_authorised_provider_user
    @provider = create(:provider)
    create(:provider_user, providers: [@provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    permit_make_decisions!
  end

  def and_i_can_access_the_provider_interface
    provider_signs_in_using_dfe_sign_in
    visit provider_interface_applications_path
    expect(page).to have_current_path provider_interface_applications_path
  end

  def when_i_navigate_to_an_offer
    course_option = course_option_for_provider_code(provider_code: @provider.code)
    @application_form = create(
      :completed_application_form,
      first_name: 'John',
      last_name: 'Smith',
    )
    @conditions = create_list(:text_condition, 3)
    @application_choice = create(
      :application_choice,
      :offered,
      offer: create(:offer, conditions: @conditions),
      current_course_option: course_option,
      application_form: @application_form,
    )
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_navigate_to_the_offer_tab
    click_link_or_button 'Offer'
  end

  def and_i_click_on_add_or_change_conditions
    click_link_or_button 'Add or change conditions'
  end

  alias_method :when_i_click_on_add_or_change_conditions, :and_i_click_on_add_or_change_conditions

  def and_i_remove_all_conditions
    click_link_or_button 'Remove condition 3'
    click_link_or_button 'Remove condition 2'
    click_link_or_button 'Remove condition 1'
    click_link_or_button 'Continue'
  end

  def then_i_expect_to_see_the_updated_conditions
    expect(page).to have_no_content @conditions.first.text
    expect(page).to have_no_content @conditions.second.text
    expect(page).to have_no_content @conditions.third.text
  end

  def then_i_do_not_see_the_removed_condition
    expect(page).to have_content 'Conditions of offer'
    expect(page).to have_no_content @conditions.first.text
    expect(page).to have_no_content @conditions.second.text
    expect(page).to have_no_content @conditions.third.text
    click_link_or_button 'Continue'
  end

  def when_i_send_the_new_offer
    click_link_or_button 'Send new offer'
    expect(page).to have_current_path provider_interface_application_choice_offer_path(@application_choice)
  end

  def then_the_candidate_has_the_new_conditions
    conditions = @application_choice.reload.offer.conditions
    expect(conditions).to be_empty
  end
end
