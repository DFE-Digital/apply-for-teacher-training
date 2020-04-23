require 'rails_helper'

RSpec.feature 'Withdraw choice from application' do
  include DfESignInHelpers

  scenario 'A support user withdraws a choice from an application' do
    given_i_am_a_support_user
    and_there_is_a_candidate_who_wants_a_course_removed

    when_i_visit_the_application_form
    and_click_on_the_button_to_change_courses
    and_i_select_the_option_to_withdraw_a_course
    and_i_select_the_course_i_want_to_remove

    then_the_course_is_withdrawn
    and_i_can_not_remove_the_last_course
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_candidate_who_wants_a_course_removed
    @application_form = create(:completed_application_form)

    create(:application_choice, status: 'awaiting_references', application_form: @application_form)
    @undesired_choice = create(:application_choice, status: 'awaiting_references', application_form: @application_form)
  end

  def when_i_visit_the_application_form
    visit support_interface_application_form_path(@application_form)
  end

  def and_click_on_the_button_to_change_courses
    click_on 'Add or withdraw course choices'
  end

  def and_i_select_the_option_to_withdraw_a_course
    choose I18n.t!('support_interface.change_course.remove_course')
    click_on 'Continue'
  end

  def and_i_select_the_course_i_want_to_remove
    choose "#{@undesired_choice.course.name_and_code} at #{@undesired_choice.provider.name}"
    click_on 'Withdraw choice'
  end

  def then_the_course_is_withdrawn
    expect(page).to have_content 'Cancelled'
    expect(@undesired_choice.reload).to be_cancelled
  end

  def and_i_can_not_remove_the_last_course
    click_on 'Add or withdraw course choices'
    expect(page).not_to have_content I18n.t!('support_interface.change_course.remove_course')
  end
end
