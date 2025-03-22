require 'rails_helper'

RSpec.describe TimeLimitCalculator do
  it 'returns default value with just a default time limit' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return(
      [
        TimeLimitConfig.new_rule(nil, nil, 20),
      ],
    )
    calculator = described_class.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq(
      days: 20,
      time_in_future: 20.business_days.from_now.end_of_day,
      time_in_past: 20.business_days.ago.end_of_day,
    )
  end

  it 'returns value for rule with `from_date` when effective date matches rule' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return(
      [
        TimeLimitConfig.new_rule(nil, nil, 20),
        TimeLimitConfig.new_rule(10.days.ago, nil, 10),
      ],
    )
    calculator = described_class.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq(
      days: 10,
      time_in_future: 10.business_days.from_now.end_of_day,
      time_in_past: 10.business_days.ago.end_of_day,
    )
  end

  it 'returns value for default rule rather than one with `from_date` when effective date does not match rule' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return(
      [
        TimeLimitConfig.new_rule(nil, nil, 20),
        TimeLimitConfig.new_rule(10.days.from_now, nil, 10),
      ],
    )
    calculator = described_class.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq(
      days: 20,
      time_in_future: 20.business_days.from_now.end_of_day,
      time_in_past: 20.business_days.ago.end_of_day,
    )
  end

  it 'returns value for rule with `to_date` and `from_date` when effective date matches rule' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return(
      [
        TimeLimitConfig.new_rule(nil, nil, 20),
        TimeLimitConfig.new_rule(10.days.ago, nil, 10),
        TimeLimitConfig.new_rule(5.days.ago, 5.days.from_now, 5),
      ],
    )
    calculator = described_class.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq(
      days: 5,
      time_in_future: 5.business_days.from_now.end_of_day,
      time_in_past: 5.business_days.ago.end_of_day,
    )
  end

  it 'returns nil when there is no rule for the given effective date' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return([])
    calculator = described_class.new(
      rule: :reject_by_default,
      effective_date: 20.days.ago,
    )
    expect(calculator.call).to eq(
      days: nil, time_in_future: nil, time_in_past: nil,
    )
  end

  describe 'configured reject_by_default limits', time: mid_cycle(2023) do
    let(:current_year) { RecruitmentCycleTimetable.current_year }

    it 'applies the 20 day rule' do
      calculator = described_class.new(
        rule: :reject_by_default,
        effective_date: Time.zone.local(current_year, 7, 6),
      )
      expect(calculator.call).to eq(
        days: 20,
        time_in_future: Time.zone.local(current_year, 8, 3).end_of_day,
        time_in_past: Time.zone.local(current_year, 6, 8).end_of_day,
      )
    end
  end
end
