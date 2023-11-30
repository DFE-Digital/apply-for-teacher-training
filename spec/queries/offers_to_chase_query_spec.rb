require 'rails_helper'

RSpec.describe OffersToChaseQuery do
  let!(:application_choice_without_offer) { create(:application_choice, :awaiting_provider_decision) }
  let!(:application_choice_with_chaser) { create(:application_choice, :offer) }
  let!(:chaser_sent) { create(:chaser_sent, chased: application_choice_with_chaser, chaser_type: "offer_#{min_of_range}_day") }

  let!(:application_choice_without_chaser) { create(:application_choice, :offer) }
  let(:offer_without_chaser) { application_choice_without_chaser.offer }

  let(:days_range) { (10..20) }
  let(:min_of_range) { days_range.min }
  let(:max_of_range) { days_range.max }

  before { chaser_sent }

  context 'when days is not acceptable argument' do
    let(:days_range) { (10..20) }

    it 'raises an ArgumentError' do
      expect { described_class.call(days: 3) }.to raise_error(ArgumentError)
    end
  end

  context 'when days is 10 and offer made less than 10 days ago' do
    let(:days_range) { (10..20) }

    it 'returns empty collection' do
      TestSuiteTimeMachine.travel_permanently_to(10.days.from_now - 1.second)
      expect(offer_without_chaser.created_at).to be < 10.days.from_now
      expect(described_class.call(days: 10)).to be_empty
    end
  end

  context 'when days is 10 and offer made more than 10 and less than 20 days ago' do
    let(:days_range) { (10..20) }

    it 'returns the appliation choice without a chaser' do
      TestSuiteTimeMachine.travel_permanently_to(min_of_range.days.from_now + 10.seconds)

      expect(Time.zone.now).to be_between(min_of_range.days.since(offer_without_chaser.created_at), max_of_range.days.since(offer_without_chaser.created_at))

      expect(described_class.call(days: min_of_range)).to contain_exactly(application_choice_without_chaser)
    end
  end

  context 'when days is 20 and offer made more than 20 and less than 30 days ago' do
    let(:days_range) { (20..30) }

    it 'returns the appliation choice without a chaser' do
      TestSuiteTimeMachine.travel_permanently_to(min_of_range.days.from_now + 10.seconds)

      expect(Time.zone.now).to be_between(min_of_range.days.since(offer_without_chaser.created_at), max_of_range.days.since(offer_without_chaser.created_at))

      expect(described_class.call(days: min_of_range)).to contain_exactly(application_choice_without_chaser)
    end
  end
end
