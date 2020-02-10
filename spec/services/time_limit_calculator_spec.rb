require 'rails_helper'

RSpec.describe TimeLimitCalculator do
  around do |example|
    Timecop.freeze(Time.zone.local(2019, 6, 1)) do
      example.run
    end
  end

  it 'returns default value with just a default time limit' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return(
      [
        TimeLimitConfig::Rule.new(nil, nil, 20),
      ],
    )
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq [20, Time.zone.local(2019, 7, 1).end_of_day, Time.zone.local(2019, 5, 1).end_of_day]
  end

  it 'returns value for rule with `from_date` when effective date matches rule' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return(
      [
        TimeLimitConfig::Rule.new(nil, nil, 20),
        TimeLimitConfig::Rule.new(10.days.ago, nil, 10),
      ],
    )
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq [10, Time.zone.local(2019, 6, 17).end_of_day, Time.zone.local(2019, 5, 16).end_of_day]
  end

  it 'returns value for default rule rather than one with `from_date` when effective date does not match rule' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return(
      [
        TimeLimitConfig::Rule.new(nil, nil, 20),
        TimeLimitConfig::Rule.new(10.days.from_now, nil, 10),
      ],
    )
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq [20, Time.zone.local(2019, 7, 1).end_of_day, Time.zone.local(2019, 5, 1).end_of_day]
  end

  it 'returns value for rule with `to_date` and `from_date` when effective date matches rule' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return(
      [
        TimeLimitConfig::Rule.new(nil, nil, 20),
        TimeLimitConfig::Rule.new(10.days.ago, nil, 10),
        TimeLimitConfig::Rule.new(5.days.ago, 5.days.from_now, 5),
      ],
    )
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq [5, Time.zone.local(2019, 6, 10).end_of_day, Time.zone.local(2019, 5, 23).end_of_day]
  end

  it 'returns nil when there is no rule for the given effective date' do
    allow(TimeLimitConfig).to receive(:limits_for).and_return([])
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: 20.days.ago,
    )
    expect(calculator.call).to eq [nil, nil, nil]
  end
end
