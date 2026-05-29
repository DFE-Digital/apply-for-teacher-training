require 'rails_helper'

RSpec.describe 'Cycle switching' do
  include DfESignInHelpers

  let(:body) { Pathname.new(Rails.root.join('spec/examples/production_recruitment_cycle_timetables_api/fetch_all_recruitment_cycles.json')) }

  before do
    stub_request(:get, ProductionRecruitmentCycleTimetablesAPI::Client::BASE_URL)
      .to_return(
        status: 200,
        body: body.read,
        headers: { 'Content-Type' => 'application/json' },
      )
  end

  scenario 'Support user switches cycle schedule' do
    given_it_is_before_the_apply_deadline
    given_i_am_signed_in_as_a_support_user
    when_i_navigate_to_the_cycle_page
    and_i_see_a_mid_cycle_description_and_content

    when_i_update_the_current_cycle_so_the_deadline_has_passed
    then_i_see_post_deadline_description
  end

  scenario 'Support user updates the winter reject by default date' do
    given_i_am_signed_in_as_a_support_user
    when_i_navigate_to_the_cycle_page
    and_i_click_on_the_current_recruitment_cycle
    then_i_see_the_edit_recruitment_cycle_page

    when_i_update_the_winter_reject_by_default_date
    then_i_see_the_winter_reject_by_default_date_has_been_updated
  end

  scenario 'Support user updates the winter decline by default date' do
    given_i_am_signed_in_as_a_support_user
    when_i_navigate_to_the_cycle_page
    and_i_click_on_the_current_recruitment_cycle
    then_i_see_the_edit_recruitment_cycle_page

    when_i_update_the_winter_decline_by_default_date
    then_i_see_the_winter_decline_by_default_date_has_been_updated
  end

private

  def given_it_is_before_the_apply_deadline
    TestSuiteTimeMachine.travel_permanently_to(current_timetable.apply_deadline_at - 13.weeks)
  end

  def when_i_navigate_to_the_cycle_page
    click_on 'Settings'
    click_on 'Recruitment cycles'
  end

  def and_i_see_a_mid_cycle_description_and_content
    expect(page).to have_text "Apply has opened (#{current_timetable.recruitment_cycle_year})"
    expect(page).to have_text 'Candidates can make choices and submit applications, providers can act on applications.'
  end

  def when_i_update_the_current_cycle_so_the_deadline_has_passed
    click_on current_timetable.recruitment_cycle_year.to_s
    within_fieldset 'Apply deadline' do
      new_date = 1.day.ago
      fill_in 'Day', with: new_date.day
      fill_in 'Month', with: new_date.month
      fill_in 'Year', with: new_date.year
    end
    click_on 'Update'
  end

  def then_i_see_post_deadline_description
    expect(page).to have_text 'The cycle has been updated.'
    expect(page).to have_text "Apply deadline has passed (#{current_timetable.recruitment_cycle_year})"
    expect(page).to have_text 'The deadline for submitting applications has passed. Candidates without active applications can start preparing applications for next year. Providers can still act on submitted applications.'
  end

  def and_i_click_on_the_current_recruitment_cycle
    click_on current_timetable.recruitment_cycle_year.to_s
  end

  def then_i_see_the_edit_recruitment_cycle_page
    within_fieldset 'Find opens' do
      expect(page).to have_field('Day', with: current_timetable.find_opens_at.day)
      expect(page).to have_field('Month', with: current_timetable.find_opens_at.month)
      expect(page).to have_field('Year', with: current_timetable.find_opens_at.year)
    end
    within_fieldset 'Apply opens' do
      expect(page).to have_field('Day', with: current_timetable.apply_opens_at.day)
      expect(page).to have_field('Month', with: current_timetable.apply_opens_at.month)
      expect(page).to have_field('Year', with: current_timetable.apply_opens_at.year)
    end
    within_fieldset 'Apply deadline' do
      expect(page).to have_field('Day', with: current_timetable.apply_deadline_at.day)
      expect(page).to have_field('Month', with: current_timetable.apply_deadline_at.month)
      expect(page).to have_field('Year', with: current_timetable.apply_deadline_at.year)
    end
    within_fieldset 'Reject by default' do
      expect(page).to have_field('Day', with: current_timetable.reject_by_default_at.day)
      expect(page).to have_field('Month', with: current_timetable.reject_by_default_at.month)
      expect(page).to have_field('Year', with: current_timetable.reject_by_default_at.year)
    end
    within_fieldset 'Decline by default' do
      expect(page).to have_field('Day', with: current_timetable.decline_by_default_at.day)
      expect(page).to have_field('Month', with: current_timetable.decline_by_default_at.month)
      expect(page).to have_field('Year', with: current_timetable.decline_by_default_at.year)
    end
    within_fieldset 'Find closes' do
      expect(page).to have_field('Day', with: current_timetable.find_closes_at.day)
      expect(page).to have_field('Month', with: current_timetable.find_closes_at.month)
      expect(page).to have_field('Year', with: current_timetable.find_closes_at.year)
    end
    within_fieldset 'Winter reject by default' do
      expect(page).to have_field('Day', with: current_timetable.winter_reject_by_default_at.day)
      expect(page).to have_field('Month', with: current_timetable.winter_reject_by_default_at.month)
      expect(page).to have_field('Year', with: current_timetable.winter_reject_by_default_at.year)
    end
    within_fieldset 'Winter decline by default' do
      expect(page).to have_field('Day', with: current_timetable.winter_decline_by_default_at.day)
      expect(page).to have_field('Month', with: current_timetable.winter_decline_by_default_at.month)
      expect(page).to have_field('Year', with: current_timetable.winter_decline_by_default_at.year)
    end
  end

  def when_i_update_the_winter_reject_by_default_date
    within_fieldset 'Winter reject by default' do
      @new_date = current_timetable.winter_reject_by_default_at - 1.day
      fill_in 'Day', with: @new_date.day
      fill_in 'Month', with: @new_date.month
      fill_in 'Year', with: @new_date.year
    end
    click_on 'Update'
  end

  def then_i_see_the_winter_reject_by_default_date_has_been_updated
    expect(page).to have_text 'The cycle has been updated.'
    summary_cards = page.first('.govuk-summary-card')
    expect(summary_cards).to have_text(@new_date.to_fs(:govuk_date_and_time))
  end

  def when_i_update_the_winter_decline_by_default_date
    within_fieldset 'Winter reject by default' do
      @new_date = current_timetable.winter_decline_by_default_at - 1.day
      fill_in 'Day', with: @new_date.day
      fill_in 'Month', with: @new_date.month
      fill_in 'Year', with: @new_date.year
    end
    click_on 'Update'
  end

  def then_i_see_the_winter_decline_by_default_date_has_been_updated
    expect(page).to have_text 'The cycle has been updated.'
    summary_cards = page.first('.govuk-summary-card')
    expect(summary_cards).to have_text(@new_date.to_fs(:govuk_date_and_time))
  end
end
