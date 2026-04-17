require 'rails_helper'

RSpec.describe 'Change visa explanation' do
  include DfESignInHelpers

  before do
    FeatureFlag.activate('2027_visa_expiry')
  end

  scenario 'editing visa explanation', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_choice_awaiting_provider_decision

    when_i_visit_the_application_page
    then_i_click_change_visa_explanation

    when_i_input_an_explanation
    and_i_add_an_audit_comment
    and_i_click_continue
    then_i_expect_to_see_my_explanation
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_choice_awaiting_provider_decision
    application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
      visa_expired_at: 2.days.from_now,
    )
    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form:,
      visa_explanation: 'other',
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_choice.application_form_id)
  end

  def then_i_click_change_visa_explanation
    click_link_or_button 'Change visa explanation'
  end

  def when_i_input_an_explanation
    choose 'My visa expires after the course ends'
  end

  def and_i_add_an_audit_comment
    fill_in 'Audit log comment', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def then_i_expect_to_see_my_explanation
    within '.govuk-summary-list__row', text: 'Based on your visa expiry date, which of these applies to you?' do
      expect(page).to have_text('My visa expires after the course ends')
    end
  end
end
