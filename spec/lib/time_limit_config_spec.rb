require 'rails_helper'

RSpec.describe TimeLimitConfig do
  describe '#limits_for' do
    it ':decline_by_default returns a default limit of 10 days' do
      expect(described_class.limits_for(:decline_by_default).first.limit).to eq(10)
    end

    it ':chase_provider_before_rbd returns a default limit of 20 days' do
      expect(described_class.limits_for(:chase_provider_before_rbd).first.limit).to eq(20)
    end

    it ':chase_candidate_before_dbd returns a default limit of 5 days' do
      expect(described_class.limits_for(:chase_candidate_before_dbd).first.limit).to eq(5)
    end

    context 'when continuous applications', time: Time.zone.local(2023, 11, 11, 11, 11, 11) do
      before do
        FeatureFlag.activate(:continuous_applications)
      end

      it ':reject_by_default returns a default limit of 30 days' do
        expect(described_class.limits_for(:reject_by_default).first.limit).to eq(30)
      end
    end

    context 'when not continuous applications', time: Time.zone.local(2023, 11, 11, 11, 11, 11) do
      before do
        FeatureFlag.deactivate(:continuous_applications)
      end

      it ':reject_by_default returns a default limit of 40 days' do
        expect(described_class.limits_for(:reject_by_default).first.limit).to eq(40)
      end
    end
  end
end
