require 'rails_helper'

RSpec.feature 'Undo reference refusal' do
  include DfESignInHelpers
  include CandidateHelper

  scenario 'Support agent reverses a reference refusal' do
    given_i_am_a_support_user
    and_there_is_an_application_with_a_refused_reference
    and_i_visit_the_application

    when_i_undo_the_refusal
    then_the_refusal_is_undone
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_with_a_refused_reference
    @application_with_reference = create(:application_form)
    create(:reference, :feedback_refused, name: 'Harry', application_form: @application_with_reference)
  end

  def and_i_visit_the_application
    visit support_interface_application_form_path(@application_with_reference)
    within_summary_row 'Reference status' do
      expect(page).to have_content 'Reference declined'
    end
  end

  def when_i_undo_the_refusal
    click_link 'Undo refusal for Harry'
    click_button 'Undo refusal'
  end

  def then_the_refusal_is_undone
    within_summary_row 'Reference status' do
      expect(page).to have_content 'Requested'
    end
  end
end
