require 'rails_helper'

RSpec.describe TimeLimitCalculator do
  around do |example|
    Timecop.freeze(Time.zone.local(2019, 6, 1)) do
      example.run
    end
  end

  it 'returns default value with just a default time limit' do
    create :time_limit, rule: :reject_by_default, limit: 20
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq 20
  end

  it 'returns value for rule with `from_date` when effective date matches rule' do
    create :time_limit, rule: :reject_by_default, limit: 10, from_date: 10.days.ago
    create :time_limit, rule: :reject_by_default, limit: 20
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq 10
  end

  it 'returns value for default rule rather than one with `from_date` when effective date does not match rule' do
    create :time_limit, rule: :reject_by_default, limit: 10, from_date: 10.days.from_now
    create :time_limit, rule: :reject_by_default, limit: 20
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq 20
  end

  it 'returns value for rule with `to_date` and `from_date` when effective date matches rule' do
    create :time_limit, rule: :reject_by_default, limit: 5, from_date: 5.days.ago, to_date: 5.days.from_now
    create :time_limit, rule: :reject_by_default, limit: 10, from_date: 10.days.ago
    create :time_limit, rule: :reject_by_default, limit: 20
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq 5
  end

  it 'returns nil when there is no rule for the given effective date' do
    create :time_limit, rule: :reject_by_default, limit: 5, from_date: 5.days.ago, to_date: 5.days.from_now
    create :time_limit, rule: :reject_by_default, limit: 10, from_date: 10.days.ago
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: 20.days.ago,
    )
    expect(calculator.call).to eq nil
  end
end
