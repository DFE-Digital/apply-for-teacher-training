require 'rails_helper'

RSpec.feature 'A provider changes their offer' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'from offered to rejected' do
    given_the_providers_can_change_offers_feature_flag_is_on
    and_i_am_logged_in_as_a_provider
    and_i_have_made_an_offer_to_a_candidate

    when_i_visit_their_application
    and_i_click_change_offer
    and_i_choose_to_reject_the_offer
    and_i_complete_the_rejection_flow

    then_i_should_see_the_application_again
    and_i_should_see_the_application_status_has_changed
  end

  def given_the_providers_can_change_offers_feature_flag_is_on
    FeatureFlag.activate('providers_can_change_offers')
  end

  def and_i_am_logged_in_as_a_provider
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_i_have_made_an_offer_to_a_candidate
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_choice = create(:application_choice, :with_offer,
                                 course_option: course_option,
                                 application_form: create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder'))
  end

  def when_i_visit_their_application
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_click_change_offer
    click_link 'Change decision'
  end

  def and_i_choose_to_reject_the_offer
    choose 'Change offer to rejection'
    click_button 'Continue'
  end

  def and_i_complete_the_rejection_flow
    fill_in 'Tell the candidate why their application was rejected', with: 'The course is full now'
    click_button 'Continue'
    click_button 'Confirm rejection'
  end

  def then_i_should_see_the_application_again
    expect(page).to have_current_path(
      provider_interface_application_choice_path(
        @application_choice.id,
      )
    )
  end

  def and_i_should_see_the_application_status_has_changed
    expect(page).to have_content('Rejected')
  end
end
