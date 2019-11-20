require 'rails_helper'

RSpec.describe MakeAnOffer do
  describe 'validation' do
    it 'accepts nil conditions' do
      decision = MakeAnOffer.new(
        application_choice: build_stubbed(:application_choice, status: :awaiting_provider_decision),
        offer_conditions: nil,
      )

      expect(decision).to be_valid
    end

    it 'only accepts conditions as an array' do
      decision = MakeAnOffer.new(
        application_choice: build_stubbed(:application_choice, status: :awaiting_provider_decision),
        offer_conditions: 'SPLAT',
      )

      expect(decision).not_to be_valid
    end

    it 'limits the number of conditions to 20' do
      decision = MakeAnOffer.new(
        application_choice: build_stubbed(:application_choice, status: :awaiting_provider_decision),
        offer_conditions: Array.new(21) { 'a condition' },
      )

      expect(decision).not_to be_valid
    end

    it 'limits the length of conditions to 255 characters' do
      decision = MakeAnOffer.new(
        application_choice: build_stubbed(:application_choice, status: :awaiting_provider_decision),
        offer_conditions: ['a' * 256],
      )

      expect(decision).not_to be_valid
    end
  end
end
