require 'rails_helper'

RSpec.feature 'Provider withdraws an offer' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Provider withdraws an offer' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_an_offered_application_choice_exists_for_my_provider
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider

    and_i_sign_in_to_the_provider_interface
    and_i_view_an_offered_application
    and_i_navigate_to_the_offer_tab

    when_i_click_on_withdraw_application
    then_i_see_a_form_prompting_for_reasons

    when_i_enter_reasons
    and_i_click_to_continue
    then_i_am_asked_to_confirm_withdrawal_of_the_offer

    when_i_confirm_withdrawal_of_the_offer
    then_i_am_sent_to_the_application_feedback_tab
    and_i_can_see_the_application_offer_is_withdrawn
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_an_offered_application_choice_exists_for_my_provider
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_offered = create(:application_choice, :with_offer, offered_course_option: course_option)
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    permit_make_decisions!
  end

  def and_i_view_an_offered_application
    visit provider_interface_application_choice_path(
      @application_offered.id,
    )
  end

  def and_i_navigate_to_the_offer_tab
    click_on 'Offer'
  end

  def when_i_click_on_withdraw_application
    click_on 'Withdraw offer'
  end

  def then_i_see_a_form_prompting_for_reasons
    expect(page).to have_current_path(
      provider_interface_application_choice_new_withdraw_offer_path(
        @application_offered.id,
      ),
    )
  end

  def when_i_enter_reasons
    fill_in('withdraw_offer[offer_withdrawal_reason]', with: 'We are very sorry but...')
  end

  def and_i_click_to_continue
    click_on t('continue')
  end

  def then_i_am_asked_to_confirm_withdrawal_of_the_offer
    expect(page).to have_current_path(
      provider_interface_application_choice_confirm_withdraw_offer_path(
        @application_offered.id,
      ),
    )
    expect(page).to have_content 'Check and confirm withdrawal'
    expect(page).to have_content 'We are very sorry but...'
    expect(find('#withdraw_offer_offer_withdrawal_reason', visible: false).value).to eq 'We are very sorry but...'
  end

  def when_i_confirm_withdrawal_of_the_offer
    click_on 'Withdraw offer'
  end

  def then_i_am_sent_to_the_application_feedback_tab
    expect(page).to have_current_path(
      provider_interface_application_choice_feedback_path(
        @application_offered.id,
      ),
    )

    expect(page).to have_content 'We are very sorry but...'
  end

  def and_i_can_see_the_application_offer_is_withdrawn
    expect(page).to have_content 'Offer successfully withdrawn'
    expect(page).to have_content 'Offer withdrawn'
  end
end
