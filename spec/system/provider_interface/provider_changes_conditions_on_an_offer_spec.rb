require 'rails_helper'

RSpec.describe 'Change offer conditions' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Provider user changes the conditions on an offer with javascript on', :js do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_an_authorised_provider_user
    and_i_can_access_the_provider_interface

    when_i_navigate_to_an_offer
    and_i_navigate_to_the_offer_tab
    and_i_click_on_add_or_change_conditions
    and_i_add_further_conditions
    then_i_see_the_new_conditions

    when_i_click_on_add_or_change_conditions
    and_i_remove_a_condition
    then_i_expect_to_see_the_updated_conditions

    when_i_click_on_add_or_change_conditions
    then_i_does_not_see_the_removed_condition

    when_i_send_the_new_offer
    then_the_candidate_has_the_new_conditions
  end

  scenario 'Provider user changes the conditions on an offer with javascript off', js: false do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_an_authorised_provider_user
    and_i_can_access_the_provider_interface

    when_i_navigate_to_an_offer
    and_i_navigate_to_the_offer_tab
    and_i_click_on_add_or_change_conditions
    and_i_add_further_conditions
    then_i_see_the_new_conditions

    when_i_click_on_add_or_change_conditions
    and_i_remove_a_condition
    then_i_expect_to_see_the_updated_conditions

    when_i_click_on_add_or_change_conditions
    then_i_does_not_see_the_removed_condition

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
    @condition = create(:text_condition)
    @application_choice = create(
      :application_choice,
      :offered,
      offer: create(:offer, conditions: [@condition]),
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

  def and_i_add_further_conditions
    click_link_or_button 'Add another condition'
    fill_in 'Condition 2', with: 'condition'
    click_link_or_button 'Add another condition'
    fill_in 'Condition 3', with: 'and another'
    click_link_or_button 'Continue'
  end

  def then_i_see_the_new_conditions
    expect(page).to have_content @condition.text
    expect(page).to have_content 'condition'
    expect(page).to have_content 'and another'
  end

  def and_i_remove_a_condition
    click_link_or_button 'Remove condition 3'
    click_link_or_button 'Continue'
  end

  def then_i_expect_to_see_the_updated_conditions
    expect(page).to have_content @condition.text
    expect(page).to have_content 'condition'
    expect(page).to have_no_content 'and another'
  end

  def then_i_does_not_see_the_removed_condition
    expect(page).to have_content 'Conditions of offer'
    expect(page).to have_content @condition.text
    expect(page).to have_content 'condition'
    expect(page).to have_no_content 'and another'
    click_link_or_button 'Continue'
  end

  def when_i_send_the_new_offer
    click_link_or_button 'Send new offer'
    expect(page).to have_content('New offer sent')
    expect(page).to have_content("#{@application_form.full_name} Offered")
  end

  def then_the_candidate_has_the_new_conditions
    conditions = @application_choice.reload.offer.non_structured_conditions_text
    expect(conditions).to contain_exactly(@condition.text, 'condition')
  end
end
