require 'rails_helper'

RSpec.describe TimeLimitConfig do
  describe '#limits_for' do
    it ':reject_by_default returns a default limit of 40 business days' do
      expect(TimeLimitConfig.limits_for(:reject_by_default).first.limit).to eq(40)
      expect(TimeLimitConfig.limits_for(:reject_by_default).first.use_business_days).to eq(true)
    end

    it ':decline_by_default returns a default limit of 10 business days' do
      expect(TimeLimitConfig.limits_for(:decline_by_default).first.limit).to eq(10)
      expect(TimeLimitConfig.limits_for(:decline_by_default).first.use_business_days).to eq(true)
    end

    it ':edit_by returns a default limit of 7 days' do
      expect(TimeLimitConfig.limits_for(:edit_by).first.limit).to eq(7)
      expect(TimeLimitConfig.limits_for(:edit_by).first.use_business_days).to eq(false)
    end

    it ':chase_provider_before_rbd returns a default limit of 20 business days' do
      expect(TimeLimitConfig.limits_for(:chase_provider_before_rbd).first.limit).to eq(20)
      expect(TimeLimitConfig.limits_for(:chase_provider_before_rbd).first.use_business_days).to eq(true)
    end

    it ':chase_candidate_before_dbd returns a default limit of 5 business days' do
      expect(TimeLimitConfig.limits_for(:chase_candidate_before_dbd).first.limit).to eq(5)
      expect(TimeLimitConfig.limits_for(:chase_candidate_before_dbd).first.use_business_days).to eq(true)
    end
  end
end
