require 'rails_helper'

RSpec.describe TimeLimitConfig do
  describe '#limits_for' do
    it ':reject_by_default returns a default limit of 40 days' do
      expect(TimeLimitConfig.limits_for(:reject_by_default).first.limit).to eq(40)
    end

    it ':decline_by_default returns a default limit of 10 days' do
      expect(TimeLimitConfig.limits_for(:decline_by_default).first.limit).to eq(10)
    end

    it ':chase_provider_before_rbd returns a default limit of 20 days' do
      expect(TimeLimitConfig.limits_for(:chase_provider_before_rbd).first.limit).to eq(20)
    end

    it ':chase_candidate_before_dbd returns a default limit of 5 days' do
      expect(TimeLimitConfig.limits_for(:chase_candidate_before_dbd).first.limit).to eq(5)
    end
  end

  describe '.edit_by' do
    before { FeatureFlag.deactivate('covid_19') }

    it 'returns 5 days' do
      expect(TimeLimitConfig.edit_by.count).to eq(5)
    end

    it 'returns type as working' do
      expect(TimeLimitConfig.edit_by.type).to eq(:working)
    end

    it 'displays "5 calendar days"' do
      expect(TimeLimitConfig.edit_by.to_s).to eq('5 working days')
    end

    it 'returns days as BusinessTime::BusinessDays object' do
      expect(TimeLimitConfig.edit_by.to_days).to be_a_kind_of(BusinessTime::BusinessDays)
    end
  end
end
