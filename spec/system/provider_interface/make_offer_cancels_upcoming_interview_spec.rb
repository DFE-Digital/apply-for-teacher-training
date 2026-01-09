require 'rails_helper'

RSpec.describe 'Provider makes an offer on an application with interviews in the future' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let!(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           application_form:,
           course_option:)
  end
  let!(:interview) { create(:interview, application_choice:, date_and_time: 2.days.from_now) }
  let(:course) do
    build(:course, :full_time, provider:)
  end
  let(:course_option) { build(:course_option, course:) }

  scenario 'Making an offer for the requested course option cancels upcoming interviews' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_make_an_offer_on_an_application_with_interviews
    then_i_see_the_review_page_with_cancelling_interviews_warning_text

    when_i_send_the_offer
    then_i_see_that_the_offer_was_successfully_made
    and_future_interviews_are_cancelled
  end

  def given_i_am_a_provider_user
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_make_an_offer_on_an_application_with_interviews
    when_i_visit_the_provider_interface
    and_i_click_an_application_choice_awaiting_decision_with_upcoming_interviews
    and_i_click_on_make_decision
    then_i_see_the_decision_page

    when_i_choose_to_make_an_offer
    then_the_conditions_page_is_loaded
    and_i_do_not_request_any_specific_references
    and_i_click_continue
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_click_an_application_choice_awaiting_decision_with_upcoming_interviews
    click_link_or_button application_choice.application_form.full_name
  end

  def and_i_click_on_make_decision
    click_link_or_button 'Make decision'
  end

  def then_i_see_the_decision_page
    expect(page).to have_content('Make a decision')
    expect(page).to have_content('Course applied for')
  end

  def when_i_choose_to_make_an_offer
    choose 'Make an offer'
    and_i_click_continue
  end

  def then_the_conditions_page_is_loaded
    expect(page).to have_content('Conditions of offer')
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  def then_i_see_the_review_page_with_cancelling_interviews_warning_text
    expect(page).to have_content('Check and send offer')
    expect(page).to have_content('The upcoming interview will be cancelled.')
  end

  def when_i_send_the_offer
    click_link_or_button 'Send offer'
  end

  def then_i_see_that_the_offer_was_successfully_made
    within('.govuk-notification-banner--success') do
      expect(page).to have_content('Offer sent')
    end
  end

  def and_future_interviews_are_cancelled
    expect(interview.reload.cancelled_at).not_to be_nil
  end

  def and_i_do_not_request_any_specific_references
    choose 'No'
  end
end
