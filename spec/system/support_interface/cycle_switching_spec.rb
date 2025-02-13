require 'rails_helper'

RSpec.describe 'Cycle switching' do
  include DfESignInHelpers

  scenario 'Support user switches cycle schedule', time: after_find_opens do
    given_i_am_a_support_user
    when_i_click_on_the_recruitment_cycle_link
    then_i_see_the_cycle_information
    and_i_see_the_cycle_information_for_after_find_opens

    when_i_click_on_move_forward
    then_i_see_the_success_message_for_apply_opens
    then_i_see_the_cycle_information_for_after_apply_opens

    when_i_click_on_move_forward
    then_see_the_success_message_for_apply_deadline_approaching
    then_i_see_the_cycle_information_for_apply_deadline_approaching

    when_i_click_on_move_forward
    then_see_the_success_message_for_after_apply_deadline
    then_i_see_the_cycle_information_for_after_apply_deadline

    when_i_click_on_move_forward
    then_see_the_success_message_for_after_reject_by_default
    then_i_see_the_cycle_information_for_after_reject_by_default

    when_i_click_on_move_forward
    then_see_the_success_message_for_after_decline_by_default
    then_i_see_the_cycle_information_for_after_decline_by_default

    when_i_click_on_move_forward
    then_see_the_success_message_for_after_find_has_closed
    then_i_see_the_cycle_information_for_after_find_has_closed

    when_i_click_on_move_forward
    then_see_the_success_message_for_after_find_has_reopened
    then_i_see_the_cycle_information_for_after_find_opens
  end

  # scenario 'We are in the last available recruitment cycle', time: after_find_closes(last_available_year) do
  #   given_i_am_a_support_user
  #   when_i_click_on_the_recruitment_cycle_link
  #   then_i_do_not_see_the_move_forward_button
  #   and_i_see_text_that_the_next_cycle_is_not_defined
  # end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_click_on_the_recruitment_cycle_link
    click_link_or_button 'Settings'
    click_link_or_button 'Recruitment cycles'
  end

  def then_i_see_the_cycle_information
    expect(page).to have_title 'Recruitment cycles'
    expect(page)
      .to have_content("Find closes on #{current_timetable.find_closes_at.to_fs(:govuk_date)}")
  end

  def and_i_see_the_cycle_information_for_after_find_opens
    expect(page).to have_content 'Find has opened, but apply has not'
    expect(page).to have_content 'Switch to the next stage in the cycle: Mid cycle'
  end
  alias_method :then_i_see_the_cycle_information_for_after_find_opens, :and_i_see_the_cycle_information_for_after_find_opens

  def then_i_see_the_cycle_information_for_after_apply_opens
    expect(page).to have_content 'Mid cycle'
    expect(page).to have_content 'Switch to the next stage in the cycle: Mid cycle, apply deadline is approaching'
  end

  def then_i_see_the_cycle_information_for_apply_deadline_approaching
    expect(page).to have_content 'Mid cycle, apply deadline is approaching'
    expect(page).to have_content 'Switch to the next stage in the cycle: After Apply deadline'
  end

  def then_i_see_the_success_message_for_apply_opens
    expect(page).to have_content 'Apply is now open'
  end

  def then_see_the_success_message_for_apply_deadline_approaching
    expect(page).to have_content 'The Apply deadline is approaching'
  end

  def then_see_the_success_message_for_after_apply_deadline
    expect(page).to have_content 'The Apply deadline has passed. As a developer to cancel all draft applications for a realistic view.'
  end

  def then_see_the_success_message_for_after_reject_by_default
    expect(page).to have_content 'The deadline for providers to make offers has passed. Ask a developer to run the Reject By Default job for a realistic view.'
  end

  def then_see_the_success_message_for_after_decline_by_default
    expect(page).to have_content 'The deadline for accepting offers has passed. Ask a developer to run the Decline By Default job for a realistic view.'
  end

  def then_see_the_success_message_for_after_find_has_closed
    expect(page).to have_content 'Find has now closed.'
  end

  def then_see_the_success_message_for_after_find_has_reopened
    expect(page).to have_content 'We are now in the new cycle'
  end

  def then_i_see_the_cycle_information_for_after_apply_deadline
    expect(page).to have_content 'After Apply deadline'
    expect(page).to have_content 'Switch to the next stage in the cycle: After Reject By Default'
  end

  def then_i_see_the_cycle_information_for_after_reject_by_default
    expect(page).to have_content 'After Reject By Default'
    expect(page).to have_content 'Switch to the next stage in the cycle: After Decline by Default'
  end

  def then_i_see_the_cycle_information_for_after_decline_by_default
    expect(page).to have_content 'The deadline for accepting offers has passed. Ask a developer to run the Decline By Default job for a realistic view.'
    expect(page).to have_content 'Switch to the next stage in the cycle: After Find has closed'
  end

  def then_i_see_the_cycle_information_for_after_find_has_closed
    expect(page).to have_content 'After Find has closed'
    expect(page).to have_content 'Switch to the next stage in the cycle: Start of the new cycle'
  end

  def when_i_click_on_move_forward
    click_on 'Move forward'
  end

  def then_the_schedule_is_updated
    expect(page).to have_content("Apply deadline #{CycleTimetable.apply_deadline.to_fs(:govuk_date)}")
  end

  def then_i_do_not_see_the_move_forward_button
    expect(page).to have_content('The next cycle is not defined').thrice
  end

  def and_i_see_text_that_the_next_cycle_is_not_defined; end

  def current_timetable
    RecruitmentCycleTimetable.current_timetable
  end
end
