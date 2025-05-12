require 'rails_helper'

RSpec.describe 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate deleting their only job entry should also remove any breaks entered' do
    given_i_am_signed_in_with_one_login
    and_i_visit_the_site

    when_i_click_on_work_history
    then_i_see_the_start_page
    then_i_choose_that_i_have_work_history_to_add
    and_i_click_add_a_first_job
    then_i_see_the_add_a_job_page
    and_i_add_a_job_that_covers_the_last_4_years_and_9_months
    then_i_see_a_two_month_break_between_my_job_and_now

    given_i_am_on_review_work_history_page
    when_i_click_to_explain_my_break_for_the_last_2_months
    then_i_see_the_start_and_end_date_filled_in_for_my_break_that_covers_the_last_2_months
    when_i_enter_a_reason_for_my_break_for_the_last_2_months
    then_i_see_my_reason_for_my_break_for_the_last_2_months_on_the_review_page

    when_i_delete_my_job
    and_i_confirm_i_want_to_delete_my_job
    then_i_see_the_start_page
    then_i_choose_that_i_have_work_history_to_add
    and_i_click_add_a_first_job
    then_i_see_the_add_a_job_page
    and_i_add_a_job_that_covers_the_last_4_years_and_9_months
    then_i_see_a_two_month_break_between_my_job_and_now
    and_i_do_not_see_my_previous_break_entry
  end

  def and_i_visit_the_site
    visit candidate_interface_details_path
  end

  def when_i_click_on_work_history
    click_link_or_button t('page_titles.work_history')
  end

  def then_i_see_the_start_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_path
  end

  def then_i_choose_that_i_have_work_history_to_add
    choose 'Yes'
    click_link_or_button 'Continue'
  end

  def and_i_click_add_a_first_job
    click_link_or_button 'Add a job'
  end

  def then_i_see_the_add_a_job_page
    expect(page).to have_current_path candidate_interface_new_restructured_work_history_path
  end

  def and_i_add_a_job_that_covers_the_last_4_years_and_9_months
    scope = 'application_form.restructured_work_history'
    fill_in t('role.label', scope:), with: 'Microsoft Painter'
    fill_in t('employer.label', scope:), with: 'Department for Education'

    choose 'Full time'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: Date.current.month
      fill_in 'Year', with: 5.years.ago.year
    end

    within('[data-qa="currently-working"]') do
      choose 'No'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: 3.months.ago.month
      fill_in 'Year', with: 3.months.ago.year
    end

    within('[data-qa="relevant-skills"]') do
      choose 'No'
    end

    click_link_or_button t('save_and_continue')
  end

  def then_i_see_a_two_month_break_between_my_job_and_now
    expect(page).to have_content('You have a break in your work history (2 months)')
  end

  def then_i_see_the_start_and_end_date_filled_in_for_my_break_that_covers_the_last_2_months
    then_i_see_the_start_and_end_date_filled_for_adding_another_job_that_covers_the_last_2_months
  end

  def then_i_see_the_start_and_end_date_filled_for_adding_another_job_that_covers_the_last_2_months
    expect(page).to have_css("input[value='#{3.months.ago.month}']")
    expect(page).to have_css("input[value='#{3.months.ago.year}']")
    expect(page).to have_css("input[value='#{Date.current.month}']")
    expect(page).to have_css("input[value='#{Date.current.year}']")
  end

  def given_i_am_on_review_work_history_page
    visit candidate_interface_restructured_work_history_review_path
  end

  def when_i_click_to_explain_my_break_for_the_last_2_months
    click_link_or_button 'add a reason for this break', match: :first
  end

  def when_i_enter_a_reason_for_my_break_for_the_last_2_months
    fill_in 'Enter reasons for break in work history', with: 'Painting is tiring.'

    click_link_or_button t('continue')
  end

  def then_i_see_my_reason_for_my_break_for_the_last_2_months_on_the_review_page
    expect(page).to have_content('Painting is tiring.')
  end

  def when_i_delete_my_job
    click_link_or_button 'Delete job Microsoft Painter for Department for Education'
  end

  def and_i_confirm_i_want_to_delete_my_job
    click_link_or_button 'Yes I’m sure - delete this job'
  end

  def and_i_do_not_see_my_previous_break_entry
    expect(page).to have_no_content('Painting is tiring.')
  end
end
