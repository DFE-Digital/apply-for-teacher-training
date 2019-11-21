require 'rails_helper'

RSpec.feature 'Provider responds to application' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }

  let(:application_awaiting_provider_decision) do
    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option)
  end

  let(:application_rejected) { create(:application_choice, status: 'rejected', course_option: course_option) }

  scenario 'Provider can respond to an application currently awaiting_provider_decision' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    when_i_visit_a_application_with_status_awaiting_provider_decision
    then_i_can_see_its_status application_awaiting_provider_decision
    and_i_can_respond_to_the_application

    when_i_click_to_respond_to_the_application
    then_i_am_given_the_option_to_make_an_offer
    and_i_am_given_the_option_to_reject_the_application
  end

  scenario 'Provider cannot respond to application currently rejected' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    when_i_visit_a_application_with_status_rejected
    then_i_can_see_its_status application_rejected
    and_i_cannot_respond_to_the_application
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_visit_a_application_with_status_awaiting_provider_decision
    visit provider_interface_application_choice_path(
      application_awaiting_provider_decision.id,
    )
  end

  def when_i_visit_a_application_with_status_rejected
    visit provider_interface_application_choice_path(
      application_rejected.id,
    )
  end

  def then_i_can_see_its_status(application)
    if application.status == 'awaiting_provider_decision'
      expect(page).to have_content 'Awaiting provider decision'
    elsif application.status == 'rejected'
      expect(page).to have_content 'Provider rejected'
    end
  end

  def and_i_can_respond_to_the_application
    expect(page).to have_content 'Respond to application'
  end

  def and_i_cannot_respond_to_the_application
    expect(page).not_to have_content 'Respond to application'
  end

  def when_i_click_to_respond_to_the_application
    click_on 'Respond to application'
  end

  def then_i_am_given_the_option_to_make_an_offer
    expect(page).to have_content 'Make an offer'
  end

  def and_i_am_given_the_option_to_reject_the_application
    expect(page).to have_content 'Reject application'
  end
end
