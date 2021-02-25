require 'rails_helper'

RSpec.feature 'Reinstating references' do
  include DfESignInHelpers

  scenario 'Support agent reinstates a refused reference' do
    given_i_am_a_support_user
    and_there_is_an_application_with_a_refused_reference
    and_i_visit_the_application

    when_i_click_to_reinstate_the_reference
    and_i_confirm_i_really_want_to_reinstate_the_reference
    then_the_reference_is_reinstated
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_with_a_refused_reference
    @application_with_reference = create(:completed_application_form)
    create(:reference, :feedback_requested, name: 'Harry', application_form: @application_with_reference)
    RefereeInterface::RefuseFeedbackForm.new(choice: 'yes').save(@application_with_reference.application_references.first)
  end

  def and_i_visit_the_application
    visit support_interface_application_form_path(@application_with_reference)
  end

  def when_i_click_to_reinstate_the_reference
    click_on 'Reinstate reference for Harry'
  end

  def and_i_confirm_i_really_want_to_reinstate_the_reference
    click_on 'Reinstate reference'
  end

  def then_the_reference_is_reinstated
    expect(page).to have_content 'Reference was reinstated'
    expect(page).to have_content 'Requested'
  end
end
