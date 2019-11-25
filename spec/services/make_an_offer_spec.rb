require 'rails_helper'

RSpec.describe MakeAnOffer do
  describe '#save' do
    it 'sets the offered_at date' do
      application_choice = create(:application_choice, status: :awaiting_provider_decision)

      MakeAnOffer.new(application_choice: application_choice)

      Timecop.freeze do
        MakeAnOffer.new(application_choice: application_choice).save

        expect(application_choice.offered_at).to eq(Time.now)
      end
    end
  end

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

  describe 'decline by default' do
    let(:application_form) { create :application_form }

    let(:application_choice) {
      create(:application_choice,
             application_form: application_form,
             status: 'awaiting_provider_decision',
             edit_by: 2.business_days.ago)
    }

    it 'calls SetDeclineByDefault service' do
      MakeAnOffer.new(application_choice: application_choice).save
      application_choice.reload

      expect(application_choice.decline_by_default_at).not_to be_nil
      expect(application_choice.decline_by_default_days).not_to be_nil
    end
  end
end
