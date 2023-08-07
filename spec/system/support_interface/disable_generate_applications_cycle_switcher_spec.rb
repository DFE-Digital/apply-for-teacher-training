require 'rails_helper'

RSpec.feature 'Disable generate future applications cycle switching' do
  include DfESignInHelpers

  scenario 'Cannot generate future applications when switching to next cycle' do
    given_i_am_a_support_user
    when_the_cycle_switcher_is_after_apply_opens
    and_i_visit_the_support_tasks_interface

    then_i_do_not_see_generate_future_applications
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_the_cycle_switcher_is_after_apply_opens
    SiteSetting.set(name: 'cycle_schedule', value: 'today_is_after_apply_opens')
  end

  def and_i_visit_the_support_tasks_interface
    visit '/support/settings/tasks'
  end

  def then_i_do_not_see_generate_future_applications
    expect(page).not_to have_button("Generate #{RecruitmentCycle.next_year} recruitment cycle test applications")
  end
end
