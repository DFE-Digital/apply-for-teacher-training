require 'rails_helper'

RSpec.describe 'Cycle switching errors' do
  include DfESignInHelpers

  let(:timetable) { current_timetable }

  scenario 'adding invalid dates' do
    given_i_am_signed_in_as_a_support_user
    and_i_navigate_to_edit_current_cycle
    when_i_enter_invalid_dates_in_all_the_fields
    then_i_see_invalid_date_errors
  end

  context 'Wrong sequence dates' do
    before do
      given_i_am_signed_in_as_a_support_user
      and_i_navigate_to_edit_current_cycle
    end

    scenario 'Apply opening before find opens' do
      when_i_enter_a_bad_apply_opens_date
      then_i_see_apply_opens_error
    end

    scenario 'Apply deadline before find apply opens' do
      when_i_enter_a_bad_apply_deadline
      then_i_see_apply_deadline_error
    end

    scenario 'Reject by default before apply deadline' do
      when_i_enter_a_bad_reject_by_default_date
      then_i_see_reject_by_default_date_error
    end

    scenario 'Decline by default before reject by default' do
      when_i_enter_a_bad_decline_by_default_date
      then_i_see_decline_by_default_date_error
    end

    scenario 'Find closes before decline by default date' do
      when_i_enter_a_bad_find_closes_date
      then_i_see_find_closes_date_error
    end
  end

private

  def and_i_navigate_to_edit_current_cycle
    click_on 'Settings'
    click_on 'Recruitment cycles'
    click_on timetable.recruitment_cycle_year
  end

  def when_i_enter_invalid_dates_in_all_the_fields
    within_fieldset 'Find opens' do
      fill_in 'Month', with: 13
    end
    within_fieldset 'Apply opens' do
      fill_in 'Day', with: 99
    end
    within_fieldset 'Apply deadline' do
      fill_in 'Year', with: 'eeee'
    end
    within_fieldset 'Reject by default' do
      fill_in 'Month', with: 13
    end
    within_fieldset 'Decline by default' do
      fill_in 'Day', with: -1
    end
    within_fieldset 'Find closes' do
      fill_in 'Year', with: 2051
    end

    click_on 'Update'
  end

  def then_i_see_invalid_date_errors
    expect(page).to have_content('Enter a valid Find open date').twice
    expect(page).to have_content('Enter a valid Apply open date').twice
    expect(page).to have_content('Enter a valid Apply deadline date').twice
    expect(page).to have_content('Enter a valid reject by default date').twice
    expect(page).to have_content('Enter a valid decline by default date').twice
    expect(page).to have_content('Enter a valid Find closes date').twice
  end

  def when_i_enter_a_bad_apply_opens_date
    within_fieldset 'Apply opens' do
      invalid_date = timetable.find_opens_at - 1.day
      fill_in 'Day', with: invalid_date.day
      fill_in 'Month', with: invalid_date.month
      fill_in 'Year', with: invalid_date.year
    end
    click_on 'Update'
  end

  def then_i_see_apply_opens_error
    expect(page).to have_content('Enter an Apply open date that is after Find has opened').twice
  end

  def when_i_enter_a_bad_apply_deadline
    within_fieldset 'Apply deadline' do
      invalid_date = timetable.apply_opens_at - 1.day
      fill_in 'Day', with: invalid_date.day
      fill_in 'Month', with: invalid_date.month
      fill_in 'Year', with: invalid_date.year
    end
    click_on 'Update'
  end

  def then_i_see_apply_deadline_error
    expect(page).to have_content('Enter an Apply deadline that is after Apply has opened').twice
  end

  def when_i_enter_a_bad_reject_by_default_date
    within_fieldset 'Reject by default' do
      invalid_date = timetable.apply_deadline_at - 1.day
      fill_in 'Day', with: invalid_date.day
      fill_in 'Month', with: invalid_date.month
      fill_in 'Year', with: invalid_date.year
    end
    click_on 'Update'
  end

  def then_i_see_reject_by_default_date_error
    expect(page).to have_content('Enter a reject by default date that is after the Apply deadline').twice
  end

  def when_i_enter_a_bad_decline_by_default_date
    within_fieldset 'Decline by default' do
      invalid_date = timetable.reject_by_default_at - 1.day
      fill_in 'Day', with: invalid_date.day
      fill_in 'Month', with: invalid_date.month
      fill_in 'Year', with: invalid_date.year
    end
    click_on 'Update'
  end

  def then_i_see_decline_by_default_date_error
    expect(page).to have_content('Enter a decline by default date that is after the reject by default date').twice
  end

  def when_i_enter_a_bad_find_closes_date
    within_fieldset 'Find closes' do
      invalid_date = timetable.reject_by_default_at - 1.day
      fill_in 'Day', with: invalid_date.day
      fill_in 'Month', with: invalid_date.month
      fill_in 'Year', with: invalid_date.year
    end
    click_on 'Update'
  end

  def then_i_see_find_closes_date_error
    expect(page).to have_content('Enter a Find close date that is after the decline by default date').twice
  end
end
