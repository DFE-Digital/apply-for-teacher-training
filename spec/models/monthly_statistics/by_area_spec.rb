require 'rails_helper'

RSpec.describe MonthlyStatistics::ByArea do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by area'" do
    5.times do
      create_application_choice(statuses: %i[with_rejection], region_code: 'london')
      create_application_choice(statuses: %i[awaiting_provider_decision], region_code: 'south_east')
      create_application_choice(statuses: %i[with_recruited], region_code: 'south_east')
      create_application_choice(statuses: %i[with_offer], region_code: 'wales')
      create_application_choice(statuses: %i[with_deferred_offer with_rejection], status_before_deferral: 'offer', region_code: 'west_midlands', recruitment_cycle_year: RecruitmentCycle.previous_year)
      create_application_choice(statuses: %i[with_deferred_offer with_declined_offer], status_before_deferral: 'offer', region_code: 'london', recruitment_cycle_year: RecruitmentCycle.current_year)
      create_application_choice(statuses: %i[with_conditions_not_met], region_code: 'wales')
      create_application_choice(statuses: %i[with_offer], region_code: 'london')
      create_application_choice(statuses: %i[with_withdrawn_offer], region_code: 'north_east')
      create_application_choice(statuses: %i[withdrawn], region_code: 'north_east')
      create_application_choice(statuses: %i[with_rejection], region_code: nil)
      create_application_choice_with_previous_application(status: :with_rejection, region_code: 'north_west')
    end

    expect(region_titles).to eq(
      [
        'Channel Islands',
        'East Midlands',
        'Eastern',
        'Isle of Man',
        'London',
        'No region',
        'North East',
        'North West',
        'Northern Ireland',
        'Scotland',
        'South East',
        'South West',
        'Wales',
        'West Midlands',
        'Yorkshire and the Humber',
        'European Economic Area',
        'Rest of the World',
      ],
    )
    expect(column_totals).to eq([5, '0 to 4', 15, 5, 30, 55])
    expect(totals_for('London')).to eq(
      'Recruited' => '0 to 4',
      'Conditions pending' => '0 to 4',
      'Received an offer' => 5,
      'Awaiting provider decisions' => '0 to 4',
      'Unsuccessful' => 5,
      'Total' => 10,
    )
    expect(totals_for('South East')).to eq(
      'Recruited' => 5,
      'Conditions pending' => '0 to 4',
      'Received an offer' => '0 to 4',
      'Awaiting provider decisions' => 5,
      'Unsuccessful' => '0 to 4',
      'Total' => 10,
    )
    expect(totals_for('Wales')).to eq(
      'Recruited' => '0 to 4',
      'Conditions pending' => '0 to 4',
      'Received an offer' => 5,
      'Awaiting provider decisions' => '0 to 4',
      'Unsuccessful' => 5,
      'Total' => 10,
    )
    expect(totals_for('West Midlands')).to eq(
      'Recruited' => '0 to 4',
      'Conditions pending' => '0 to 4',
      'Received an offer' => 5,
      'Awaiting provider decisions' => '0 to 4',
      'Unsuccessful' => '0 to 4',
      'Total' => 5,
    )
    expect(totals_for('North West')).to eq(
      'Recruited' => '0 to 4',
      'Conditions pending' => '0 to 4',
      'Received an offer' => '0 to 4',
      'Awaiting provider decisions' => '0 to 4',
      'Unsuccessful' => 5,
      'Total' => 5,
    )

    expect(totals_for('North East')).to eq(
      'Recruited' => '0 to 4',
      'Conditions pending' => '0 to 4',
      'Received an offer' => '0 to 4',
      'Awaiting provider decisions' => '0 to 4',
      'Unsuccessful' => 10,
      'Total' => 10,
    )

    expect(totals_for('No region')).to eq(
      'Recruited' => '0 to 4',
      'Conditions pending' => '0 to 4',
      'Received an offer' => '0 to 4',
      'Awaiting provider decisions' => '0 to 4',
      'Unsuccessful' => 5,
      'Total' => 5,
    )
  end

  def create_application_choice(
    statuses:,
    region_code:,
    recruitment_cycle_year: RecruitmentCycle.current_year,
    previous_application_form: nil,
    status_before_deferral: nil
  )
    application_form = create(
      :application_form,
      previous_application_form: previous_application_form,
      recruitment_cycle_year: recruitment_cycle_year,
      region_code: region_code,
    )
    statuses.map do |status|
      create(
        :application_choice,
        status,
        status_before_deferral: status_before_deferral,
        application_form: application_form,
      )
    end
  end

  def create_application_choice_with_previous_application(
    status:,
    region_code:,
    recruitment_cycle_year: RecruitmentCycle.current_year
  )
    previous_application_choice = create_application_choice(
      statuses: [status],
      region_code: region_code,
      recruitment_cycle_year: recruitment_cycle_year,
    ).first
    create_application_choice(
      statuses: [status],
      region_code: region_code,
      recruitment_cycle_year: recruitment_cycle_year,
      previous_application_form: previous_application_choice.application_form,
    )
  end

  def region_titles
    statistics[:rows].map { |row| row.values.first }
  end

  def column_totals
    statistics[:column_totals]
  end

  def totals_for(area)
    statistics[:rows].find { |row| row['Area'] == area }.except('Area')
  end
end
