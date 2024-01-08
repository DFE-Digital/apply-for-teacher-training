require 'rails_helper'

RSpec.feature 'Recalculate dates task', sidekiq: false do
  include DfESignInHelpers

  scenario 'Support user performs a task' do
    given_i_am_a_support_user

    when_i_visit_the_support_tasks_page
    and_i_click_on_recalculate_dates
    then_i_see_that_the_job_has_been_scheduled
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_support_tasks_page
    visit support_interface_tasks_path
  end

  def and_i_click_on_recalculate_dates
    click_link_or_button 'Recalculate dates'
  end

  def then_i_see_that_the_job_has_been_scheduled
    expect(page).to have_content 'Scheduled job to recalculate dates'
  end
end
