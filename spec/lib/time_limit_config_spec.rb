require 'rails_helper'

RSpec.describe TimeLimitConfig do
  describe '#limits_for' do
    it ':decline_by_default returns a default limit of 10 days' do
      expect(described_class.limits_for(:decline_by_default).first.limit).to eq(10)
    end

    it ':chase_candidate_before_dbd returns a default limit of 5 days' do
      expect(described_class.limits_for(:chase_candidate_before_dbd).first.limit).to eq(5)
    end

    it ':reject_by_default returns a default limit of 30 days when continuous applications', :continuous_applications do
      expect(described_class.limits_for(:reject_by_default).first.limit).to eq(30)
    end

    it ':reject_by_default returns a default limit of 40 days non continuous applications', continuous_applications: false do
      expect(described_class.limits_for(:reject_by_default).first.limit).to eq(40)
    end

    it ':reject_by_default returns a limit of 20 days date is after June in the current cycle' do
      TestSuiteTimeMachine.travel_permanently_to(Date.new(RecruitmentCycle.current_year, 7, 1)) do
        expect(described_class.limits_for(:reject_by_default).first.limit).to eq(20)
      end
    end
  end
end
