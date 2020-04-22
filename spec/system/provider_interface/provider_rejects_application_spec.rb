require 'rails_helper'

RSpec.feature 'Provider rejects application' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_awaiting_provider_decision) {
    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder'))
  }

  scenario 'Provider rejects application' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_respond_to_an_application
    and_i_choose_to_reject_it
    and_i_add_a_rejection_reason
    and_i_click_to_continue
    then_i_am_asked_to_confirm_the_rejection

    when_i_confirm_the_rejection
    then_i_am_back_to_the_application_page
    and_i_can_see_the_application_has_just_been_rejected

    when_the_change_response_feature_is_activated
    then_i_can_see_a_link_to_make_an_offer_on_the_application
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def when_i_respond_to_an_application
    visit provider_interface_application_choice_respond_path(
      application_awaiting_provider_decision.id,
    )
  end

  def and_i_choose_to_reject_it
    choose 'Reject application'
    click_on 'Continue'
  end

  def and_i_add_a_rejection_reason
    fill_in('Tell the candidate why you’re rejecting their application', with: 'A rejection reason')
  end

  def and_i_click_to_continue
    click_on 'Continue'
  end

  def then_i_am_asked_to_confirm_the_rejection
    expect(page).to have_current_path(
      provider_interface_application_choice_confirm_reject_path(
        application_awaiting_provider_decision.id,
      ),
    )
  end

  def when_i_confirm_the_rejection
    click_on 'Reject application'
  end

  def then_i_am_back_to_the_application_page
    expect(page).to have_current_path(
      provider_interface_application_choice_path(
        application_awaiting_provider_decision.id,
      ),
    )
  end

  def and_i_can_see_the_application_has_just_been_rejected
    expect(page).to have_content 'Application successfully rejected'
  end

  def when_the_change_response_feature_is_activated
    FeatureFlag.activate('provider_change_response')
  end

  def then_i_can_see_a_link_to_make_an_offer_on_the_application
    page.refresh
    expect(page).to have_link 'Change rejection to offer'
  end
end
