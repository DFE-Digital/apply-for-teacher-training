require 'rails_helper'

RSpec.describe MonthlyStatistics::ByArea do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by area'" do
    create_application_choice(status: :with_rejection, region_code: 'london')
    create_application_choice(status: :awaiting_provider_decision, region_code: 'south_east')
    create_application_choice(status: :with_recruited, region_code: 'south_east')
    create_application_choice(status: :with_offer, region_code: 'wales')
    create_application_choice(status: :with_deferred_offer, region_code: 'west_midlands', recruitment_cycle_year: RecruitmentCycle.previous_year)
    create_application_choice(status: :with_deferred_offer, region_code: 'london', recruitment_cycle_year: RecruitmentCycle.current_year)
    create_application_choice(status: :with_conditions_not_met, region_code: 'wales')
    create_application_choice(status: :with_offer, region_code: 'london')
    create_application_choice_with_previous_application(status: :with_rejection, region_code: 'north_west')

    expect(column_totals).to eq([1, 0, 3, 1, 3, 8])
    expect(totals_for('London')).to eq(
      'Recruited' => 0,
      'Conditions pending' => 0,
      'Received an offer' => 1,
      'Awaiting provider decisions' => 0,
      'Unsuccessful' => 1,
      'Total' => 2,
    )
    expect(totals_for('South East')).to eq(
      'Recruited' => 1,
      'Conditions pending' => 0,
      'Received an offer' => 0,
      'Awaiting provider decisions' => 1,
      'Unsuccessful' => 0,
      'Total' => 2,
    )
    expect(totals_for('Wales')).to eq(
      'Recruited' => 0,
      'Conditions pending' => 0,
      'Received an offer' => 1,
      'Awaiting provider decisions' => 0,
      'Unsuccessful' => 1,
      'Total' => 2,
    )
    expect(totals_for('West Midlands')).to eq(
      'Recruited' => 0,
      'Conditions pending' => 0,
      'Received an offer' => 1,
      'Awaiting provider decisions' => 0,
      'Unsuccessful' => 0,
      'Total' => 1,
    )
    expect(totals_for('North West')).to eq(
      'Recruited' => 0,
      'Conditions pending' => 0,
      'Received an offer' => 0,
      'Awaiting provider decisions' => 0,
      'Unsuccessful' => 1,
      'Total' => 1,
    )
  end

  def create_application_choice(
    status:,
    region_code:,
    recruitment_cycle_year: RecruitmentCycle.current_year,
    previous_application_form: nil
  )
    create(
      :application_choice,
      status,
      application_form: create(
        :application_form,
        previous_application_form: previous_application_form,
        recruitment_cycle_year: recruitment_cycle_year,
        region_code: region_code,
      ),
    )
  end

  def create_application_choice_with_previous_application(
    status:,
    region_code:,
    recruitment_cycle_year: RecruitmentCycle.current_year
  )
    previous_application_choice = create_application_choice(
      status: status,
      region_code: region_code,
      recruitment_cycle_year: recruitment_cycle_year,
    )
    create_application_choice(
      status: status,
      region_code: region_code,
      recruitment_cycle_year: recruitment_cycle_year,
      previous_application_form: previous_application_choice.application_form,
    )
  end

  def column_totals
    statistics[:column_totals]
  end

  def totals_for(area)
    statistics[:rows].find { |row| row['Area'] == area }.except('Area')
  end
end
