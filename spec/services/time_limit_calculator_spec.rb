require 'rails_helper'

RSpec.describe TimeLimitCalculator do
  it 'returns default value with just a default time limit' do
    create :time_limit, rule: :reject_by_default, limit: 20
    calculator = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    )
    expect(calculator.call).to eq 20
  end
end
