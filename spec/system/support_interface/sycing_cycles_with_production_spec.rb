require 'rails_helper'

RSpec.describe 'Syncing cycles with production' do
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

  scenario 'Undoing a change in the cycle timetable' do
    given_i_am_signed_in_as_a_support_user
    and_i_navigate_to_edit_current_cycle
    when_i_make_a_successful_change_to_the_cycle
    and_i_sync_timetables_with_production
    then_the_timetable_is_restored
  end

private

  def and_i_navigate_to_edit_current_cycle
    click_on 'Settings'
    click_on 'Recruitment cycles'
    click_on current_timetable.recruitment_cycle_year
  end

  def when_i_make_a_successful_change_to_the_cycle
    @original_apply_deadline_at = current_timetable.apply_deadline_at
    within_fieldset 'Apply deadline' do
      new_date = 1.day.ago
      fill_in 'Day', with: new_date.day
      fill_in 'Month', with: new_date.month
      fill_in 'Year', with: new_date.year
    end
    click_on 'Update'

    expect(current_timetable.reload.apply_deadline_at).not_to eq @original_apply_deadline_at
  end

  def and_i_sync_timetables_with_production
    click_on 'Sync cycle timetables with production'
  end

  def then_the_timetable_is_restored
    expect(current_timetable.reload.apply_deadline_at).to eq @original_apply_deadline_at
  end
end
