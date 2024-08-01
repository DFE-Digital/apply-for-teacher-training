require 'rails_helper'

RSpec.describe 'Revert a withdrawn application choice' do
  include DfESignInHelpers

  scenario 'cannot revert a withdrawal when application exists for the course option' do
    given_i_am_a_support_user
    and_there_is_a_withdrawn_application_in_the_system
    and_there_is_an_open_application_to_the_same_course
    and_i_visit_the_support_page

    when_i_click_on_an_application
    and_i_am_on_the_correct_application_page
    then_i_see_the_withdrawn_course_choice

    when_i_click_on_the_revert_withdrawal_link
    then_i_see_the_revert_withdrawal_page
    when_i_click_continue
    then_i_am_told_there_is_an_existing_application
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_open_application_to_the_same_course
    create(
      :application_choice,
      :unsubmitted,
      course_option: @application_choice.course_option,
      application_form: @application_form,
    )
  end

  def and_there_is_a_withdrawn_application_in_the_system
    @application_form = create(:completed_application_form)

    @application_choice = create(
      :application_choice,
      :withdrawn,
      application_form: @application_form,
    )
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application
    click_link_or_button @application_form.full_name
  end

  def and_i_am_on_the_correct_application_page
    expect(page).to have_current_path support_interface_application_form_path(application_form_id: @application_form.id)
  end

  def then_i_see_the_withdrawn_course_choice
    expect(page).to have_content('Withdrawn').once
  end

  def when_i_click_on_the_revert_withdrawal_link
    click_link_or_button 'Revert withdrawal'
  end

  def then_i_see_the_revert_withdrawal_page
    expect(page).to have_current_path support_interface_application_form_application_choice_revert_withdrawal_path(@application_form.id, @application_choice.id)
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def then_i_am_told_there_is_an_existing_application
    expect(page).to have_content 'cannot apply to the same course when an open application exists'
  end
end
