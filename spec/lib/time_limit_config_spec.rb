require 'rails_helper'

RSpec.describe TimeLimitConfig do
  describe '#limits_for' do
    it ':reject_by_default returns a default limit of 40 days' do
      expect(TimeLimitConfig.limits_for(:reject_by_default).first.limit).to eq(40)
    end

    it ':decline_by_default returns a default limit of 10 days' do
      expect(TimeLimitConfig.limits_for(:decline_by_default).first.limit).to eq(10)
    end
  end
end
