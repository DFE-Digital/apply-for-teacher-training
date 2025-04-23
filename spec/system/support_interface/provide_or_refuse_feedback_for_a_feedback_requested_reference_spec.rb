require 'rails_helper'

RSpec.describe 'Support user can access the RefereeInterface' do
  include DfESignInHelpers

  it 'Support user accesses the provide and refuse reference flow' do
    given_i_am_a_support_user
    and_there_is_an_application_with_a_reference_in_the_feedback_requested_state

    when_i_visit_the_application_form_page
    and_click_the_provide_feedback_link
    then_i_see_the_confidentiality_page
    when_i_select_not_to_share_and_continue
    then_i_see_the_reference_relationship_page

    when_i_visit_the_application_form_page
    and_click_the_refuse_feedback_link
    and_i_decline_to_give_a_reference
    then_i_confirm_i_dont_want_to_give_a_reference

    when_the_candidates_reference_is_in_the_feedback_provided_state
    and_i_visit_the_application_form_page
    then_i_do_not_see_the_provide_feedback_or_refuse_feedback_link
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_with_a_reference_in_the_feedback_requested_state
    @application = create(:completed_application_form, first_name: 'GOB', last_name: 'Bluth')
    create(:reference, :feedback_requested, application_form: @application)
    create(:application_choice, :accepted, application_form: @application)
  end

  def when_i_visit_the_application_form_page
    visit support_interface_application_form_path(@application)
  end

  def and_click_the_provide_feedback_link
    click_link_or_button 'Give feedback'
  end

  def then_i_see_the_confidentiality_page
    expect(page).to have_content "Can your reference be shared with #{@application.full_name}?"
  end

  def when_i_select_not_to_share_and_continue
    choose 'No, it should be treated as confidential'
    click_on 'Save and continue'
  end

  def then_i_see_the_reference_relationship_page
    expect(page).to have_content t('page_titles.referee.relationship', full_name: @application.full_name)
  end

  def and_click_the_refuse_feedback_link
    click_link_or_button 'decline to give a reference'
  end

  def and_i_decline_to_give_a_reference
    choose 'No, I’m unable to give a reference'
    click_link_or_button t('save_and_continue')
  end

  def then_i_confirm_i_dont_want_to_give_a_reference
    click_link_or_button 'Yes, I am unable to give a reference'
  end

  def when_the_candidates_reference_is_in_the_feedback_provided_state
    @application.application_references.creation_order.first.feedback_provided!
  end

  def and_i_visit_the_application_form_page
    when_i_visit_the_application_form_page
  end

  def then_i_do_not_see_the_provide_feedback_or_refuse_feedback_link
    expect(page).to have_no_link 'Give feedback'
    expect(page).to have_no_link 'decline to give a reference'
  end
end
