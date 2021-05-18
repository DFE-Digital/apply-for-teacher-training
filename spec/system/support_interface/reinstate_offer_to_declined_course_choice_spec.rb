require 'rails_helper'

RSpec.feature 'Reinstate offer to a declined course choice' do
  include DfESignInHelpers

  scenario 'Support user can reverse a course choice that has accidently been declined' do
    given_i_am_a_support_user
    and_the_reinstate_offer_feature_flag_is_on
    and_there_is_a_submitted_application_in_the_system_with_a_declined_offer
    and_i_visit_the_support_page

    when_i_click_on_an_application
    and_i_am_on_the_correct_application_page
    then_i_see_the_declined_course_choice

    when_i_click_on_the_reinstate_offer_link
    then_i_see_the_reinstate_offer_page
    when_i_click_continue
    then_i_am_told_to_confirm_i_have_followed_the_guidance

    when_i_confirm_reinstating_an_offer
    and_i_click_continue
    then_i_am_told_that_i_need_to_provide_a_zendesk_ticket
    when_i_provide_an_invalid_zendesk_ticket_link
    and_i_click_continue
    then_i_am_told_that_i_need_to_provide_a_valid_zendesk_ticket_link

    when_i_provide_a_valid_zendesk_ticket
    and_i_confirm_reinstating_an_offer
    and_i_click_continue
    then_i_am_redirected_to_the_application_form_page
    and_i_see_the_offer_has_been_reinstated
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_the_reinstate_offer_feature_flag_is_on
    FeatureFlag.activate(:support_user_reinstate_offer)
  end

  def and_there_is_a_submitted_application_in_the_system_with_a_declined_offer
    @application_form = create :completed_application_form

    @application_choice = create(
      :application_choice,
      :with_declined_offer,
      application_form: @application_form,
    )
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application
    click_on @application_form.full_name
  end

  def and_i_am_on_the_correct_application_page
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
  end

  def then_i_see_the_declined_course_choice
    within(all('.app-summary-card__body')[0]) do
      expect(page).to have_content('Offer declined')
    end
  end

  def when_i_click_on_the_reinstate_offer_link
    within(all('.app-summary-card__body')[0]) do
      within(all('.govuk-summary-list__row')[0]) do
        all('.govuk-summary-list__actions')[0].click_link
      end
    end
  end

  def then_i_see_the_reinstate_offer_page
    expect(page).to have_current_path support_interface_application_form_application_choice_reinstate_offer_path(@application_form.id, @application_choice.id)
  end

  def and_i_click_continue
    click_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_am_told_to_confirm_i_have_followed_the_guidance
    expect(page).to have_content 'Select that you have read the guidance'
  end

  def when_i_confirm_reinstating_an_offer
    check 'I have read the guidance'
  end
  alias_method :and_i_confirm_reinstating_an_offer, :when_i_confirm_reinstating_an_offer

  def then_i_am_told_that_i_need_to_provide_a_zendesk_ticket
    expect(page).to have_content 'Enter a Zendesk ticket URL'
  end

  def when_i_provide_an_invalid_zendesk_ticket_link
    fill_in('Zendesk ticket URL', with: 'This wont work')
  end

  def then_i_am_told_that_i_need_to_provide_a_valid_zendesk_ticket_link
    expect(page).to have_content 'Enter a valid Zendesk ticket URL'
  end

  def when_i_provide_a_valid_zendesk_ticket
    fill_in('Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/example')
  end

  def then_i_am_redirected_to_the_application_form_page
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
  end

  def and_i_see_the_offer_has_been_reinstated
    within(all('.app-summary-card__body')[0]) do
      expect(page).to have_content('Offer made')
    end
  end
end
