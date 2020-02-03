require 'rails_helper'

RSpec.feature 'Pre-reference submission', sidekiq: true do
  include CandidateHelper
  include DfESignInHelpers

  scenario 'An application is sent to the provider before all references have come in' do
    given_i_am_signed_in_as_a_support_user
    and_there_is_a_submitted_application_without_all_references

    when_i_visit_the_application_page
    and_i_choose_to_send_it_to_the_provider_without_references

    ReceiveReference.new(
      reference: @reference,
      feedback: 'Hi'
    ).save!
  end

  def given_i_am_signed_in_as_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_submitted_application_without_all_references
    @application_form = create(:application_form)
    create(:application_choice, application_form: @application_form, status: 'awaiting_references')
    create(:application_choice, application_form: @application_form, status: 'awaiting_references')

    create(:reference, :complete, application_form: @application_form)
    @reference = create(:reference, :requested, application_form: @application_form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_form)
  end

  def and_i_choose_to_send_it_to_the_provider_without_references
    find('details').click
    click_on 'Send to provider without references'
  end
end
