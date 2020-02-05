require 'rails_helper'

RSpec.feature 'Provider makes an offer' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider withdraws an offer' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_an_offered_application_choice_exist_for_my_provider
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_i_view_an_offered_application
    then_i_cannot_change_response

    when_change_response_feature_is_activated
    and_i_change_response_to_an_application
    and_i_choose_to_withdraw_an_offer
    then_i_see_a_form_prompting_for_reasons

    when_i_enter_reasons
    and_i_click_to_continue
    then_i_am_asked_to_confirm_withdrawal_of_the_offer

    when_i_confirm_withdrawal_of_the_offer
    then_i_am_back_to_the_application_page
    and_i_can_see_the_application_offer_is_withdrawn
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_an_offered_application_choice_exist_for_my_provider
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_offered = create(:application_choice, status: 'offer', course_option: course_option, application_form: create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder'))
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def when_change_response_feature_is_activated
    FeatureFlag.activate('provider_change_response')
  end

  def then_i_cannot_change_response
    first('a', text: 'Change response', count: 0)
  end

  def and_i_view_an_offered_application
    visit provider_interface_application_choice_path(
      @application_offered.id,
    )
  end

  def and_i_change_response_to_an_application
    visit provider_interface_application_choice_path(
      @application_offered.id,
    )
    click_on 'Change response'
  end

  def and_i_choose_to_withdraw_an_offer
    choose 'Withdraw offer'
    click_on 'Continue'
  end

  def then_i_see_a_form_prompting_for_reasons
    expect(page).to have_current_path(
      provider_interface_application_choice_new_withdraw_offer_path(
        @application_offered.id,
      ),
    )
  end

  def when_i_enter_reasons
    fill_in('provider_interface_withdraw_offer_form[reason]', with: 'We are very sorry but...')
  end

  def and_i_click_to_continue
    click_on 'Continue'
  end

  def then_i_am_asked_to_confirm_withdrawal_of_the_offer
    expect(page).to have_current_path(
      provider_interface_application_choice_confirm_withdraw_offer_path(
        @application_offered.id,
      ),
    )
    expect(page).to have_content 'Are you sure you want to withdraw this offer?'
    expect(page).to have_content 'We are very sorry but...'
    expect(find('#provider_interface_withdraw_offer_form_reason', visible: false).value).to eq 'We are very sorry but...'
  end

  def when_i_confirm_withdrawal_of_the_offer
    click_on 'Yes I\'m sure - withdraw offer'
  end

  def then_i_am_back_to_the_application_page
    expect(page).to have_current_path(
      provider_interface_application_choice_path(
        @application_offered.id,
      ),
    )
    expect(page).to have_content @application_offered.application_form.first_name
    expect(page).to have_content @application_offered.application_form.last_name
  end

  def and_i_can_see_the_application_offer_is_withdrawn
    expect(page).to have_content 'Application status changed to ‘Offer withdrawn’'
    expect(page).to have_content 'Withdrawn by us'
  end
end
