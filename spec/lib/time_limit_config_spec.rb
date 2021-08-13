require 'rails_helper'

RSpec.describe TimeLimitConfig do
  describe '#limits_for' do
    it ':reject_by_default returns a default limit of 40 days' do
      expect(described_class.limits_for(:reject_by_default).first.limit).to eq(40)
    end

    it ':decline_by_default returns a default limit of 10 days' do
      expect(described_class.limits_for(:decline_by_default).first.limit).to eq(10)
    end

    it ':chase_provider_before_rbd returns a default limit of 20 days' do
      expect(described_class.limits_for(:chase_provider_before_rbd).first.limit).to eq(20)
    end

    it ':chase_candidate_before_dbd returns a default limit of 5 days' do
      expect(described_class.limits_for(:chase_candidate_before_dbd).first.limit).to eq(5)
    end

    it ':ucas_match_candidate_withdrawal_request returns a default limit of 10 days' do
      expect(described_class.limits_for(:ucas_match_candidate_withdrawal_request).first.limit).to eq(10)
    end

    it ':ucas_match_candidate_withdrawal_request_reminder returns a default limit of 5 days' do
      expect(described_class.limits_for(:ucas_match_candidate_withdrawal_request_reminder).first.limit).to eq(5)
    end

    it ':ucas_match_ucas_withdrawal_request returns a default limit of 5 days' do
      expect(described_class.limits_for(:ucas_match_ucas_withdrawal_request).first.limit).to eq(5)
    end
  end
end
