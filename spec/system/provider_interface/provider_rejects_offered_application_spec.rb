require 'rails_helper'

RSpec.feature 'Provider rejects an application with an offer' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_with_an_offer) { create(:application_choice, :with_offer, ) }

  scenario 'Provider rejects application' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider

    when_i_visit_an_application_with_an_offer
    and_i_click_change_status
    then_i_should_see_the_change_status_page

    when_i_choose_reject_application
    and_i_click_to_continue
    and_i_add_a_rejection_reason
    and_i_click_to_continue

    then_i_should_see_the_application_page
    and_i_should_see_that_the_application_has_been_rejected
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def when_i_visit_an_application_with_an_offer
    visit provider_interface_application_choice_path(
      application_with_an_offer.id,
    )
  end

  def and_i_click_change_status
    click_button 'Change status'
  end

  def then_i_should_see_the_change_status_page
    expect(page).to have_title 'Change status'
  end

  def when_i_choose_reject_application
    choose 'Reject application'
  end

  def and_i_click_to_continue
    click_button 'Continue'
  end

  def and_i_add_a_rejection_reason
    fill_in('Tell the candidate why their application was rejected', with: 'A rejection reason')
  end

  def then_i_am_back_to_the_application_page
    expect(page).to have_current_path(
      provider_interface_application_choice_path(
        application_with_an_offer.id,
      )
    )
  end

  def and_i_can_see_the_application_has_just_been_rejected
    expect(page).to have_content 'Application status changed to ‘Rejected’'
  end
end
