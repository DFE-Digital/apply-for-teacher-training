require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByProviderArea do
  include MonthlyStatisticsTestHelper

  before { generate_monthly_statistics_test_data }
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'applications by provider area'" do
    expect(statistics).to eq(
      {
        rows: [
          {
            'Area' => 'East',
            'Recruited' => 1,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Area' => 'East Midlands',
            'Recruited' => 0,
            'Conditions pending' => 2,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 2,
          },
          {
            'Area' => 'London',
            'Recruited' => 0,
            'Conditions pending' => 1,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Area' => 'North East',
            'Recruited' => 1,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 2,
            'Total' => 3,
          },
          {
            'Area' => 'North West',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 1,
          },
          {
            'Area' => 'South East',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Area' => 'South West',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 1,
          },
          {
            'Area' => 'West Midlands',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Area' => 'Yorkshire and The Humber',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 1,
          },
        ],
        column_totals: [2, 3, 2, 0, 5, 12],
      },
    )
  end
end

def setup_test_data
  # previous year
  create_application_choice_for_last_cycle(status_before_deferral: 'recruited', region_code: 'eastern')
  create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', region_code: 'east_midlands')
  create_application_choice_for_last_cycle(status_before_deferral: 'pending_conditions', region_code: 'london')
  create_application_choice_for_last_cycle(status_before_deferral: 'recruited', region_code: 'north_east')

  # current year
  create_application_choice_for_this_cycle(status: 'pending_conditions', region_code: 'east_midlands')
  create_application_choice_for_this_cycle(status: :with_rejection, region_code: 'north_west')
  create_application_choice_for_this_cycle(status: :with_offer, region_code: 'south_east')
  create_application_choice_for_this_cycle(status: :with_rejection, region_code: 'south_west')
  create_application_choice_for_this_cycle(status: :with_offer, region_code: 'west_midlands')
  create_application_choice_for_this_cycle(status: :with_conditions_not_met, region_code: 'yorkshire_and_the_humber')
  create_application_choice_for_this_cycle(status: :withdrawn, region_code: 'north_east')
  create_application_choice_for_this_cycle(status: :with_withdrawn_offer, region_code: 'north_east')
end

def create_application_choice_for_this_cycle(status:, region_code:)
  create(:application_choice, status, current_recruitment_cycle_year: RecruitmentCycle.current_year, course_option: create(:course_option, course: create(:course, level: 'secondary', provider: create(:provider, region_code: region_code))))
end

def create_application_choice_for_last_cycle(status_before_deferral:, region_code:)
  create(:application_choice, :with_offer, :offer_deferred, status_before_deferral: status_before_deferral, current_recruitment_cycle_year: RecruitmentCycle.previous_year, course_option: create(:course_option, course: create(:course, level: 'secondary', provider: create(:provider, region_code: region_code))))
end
end
