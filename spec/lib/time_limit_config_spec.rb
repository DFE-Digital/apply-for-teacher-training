require 'rails_helper'

RSpec.describe TimeLimitConfig do
  describe '#limits_for' do
    it ':reject_by_default returns a default limit of 30 days when continuous applications' do
      expect(described_class.limits_for(:reject_by_default).first.limit).to eq(30)
    end

    it ':reject_by_default returns a limit of 20 days date is after June in the current cycle' do
      TestSuiteTimeMachine.travel_permanently_to(Date.new(current_year, 7, 1)) do
        expect(described_class.limits_for(:reject_by_default).first.limit).to eq(20)
      end
    end
  end
end
