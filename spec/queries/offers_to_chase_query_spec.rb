require 'rails_helper'

RSpec.describe OffersToChaseQuery do
  let(:application_choice_without_offer) { create(:application_choice, :awaiting_provider_decision) }
  let(:application_choice_with_offer_not_in_offer_status) { create(:application_choice, :recruited, offer: create(:offer, created_at: inside_range)) }
  let(:application_choice_offer_from_last_cycle) { create(:application_choice, current_recruitment_cycle_year: CycleTimetable.previous_year, offer: create(:offer, created_at: inside_range)) }

  let(:application_choice_with_chaser) { create(:application_choice, :offer, chasers_sent: [create(:chaser_sent, chaser_type: "offer_#{days}_day")]) }

  let(:application_choice_without_chaser) { create(:application_choice, :offer, current_recruitment_cycle_year:) }
  let(:offer_without_chaser) { application_choice_without_chaser.offer }
  let(:current_recruitment_cycle_year) { CycleTimetable.current_year }

  let(:chaser_type) { :offer_10_day }

  let(:days) { 10 }
  let(:date_range) { days.days.ago.all_day }
  let(:inside_range) { date_range.max - 1.hour }
  let(:outside_range) { date_range.max + 1.hour }

  before do
    TestSuiteTimeMachine.travel_temporarily_to(offset) do
      application_choice_without_offer
      application_choice_with_chaser
      application_choice_without_chaser
    end
  end

  context 'when offers are made before the chaser sent range for offer_10_day' do
    let(:offset) { outside_range }

    it 'returns empty collection' do
      expect(offer_without_chaser.created_at).to be > 10.days.ago
      expect(described_class.call(chaser_type:, date_range:)).to be_empty
    end
  end

  context 'when offers are made inside the range 20 to 10 days ago and chaser_type is offer_10_day' do
    let(:days) { 10 }
    let(:offset) { inside_range }

    it 'returns the application choice without a chaser' do
      expect(date_range).to cover(offer_without_chaser.created_at)

      expect(described_class.call(chaser_type:, date_range:)).to contain_exactly(application_choice_without_chaser)
    end
  end

  describe 'when the range is 20 to 30 days ago and offers are made inside the range' do
    let(:days) { 20 }

    context 'and chaser_type is offer_20_day and chaser has been sent for offer_20_day' do
      let(:offset) { inside_range }
      let(:chaser_type) { :offer_20_day }

      it 'returns the application choice without a chaser sent' do
        expect(date_range).to cover(offer_without_chaser.created_at)

        expect(described_class.call(chaser_type:, date_range:)).to contain_exactly(application_choice_without_chaser)
      end
    end

    context 'and chaser_type is offer_20_day and chaser only sent for offer_10_day' do
      let(:offset) { inside_range }
      let(:chaser_type) { :offer_10_day }

      it 'returns the application choice no chaser sent and one with old chaser sent' do
        expect(date_range).to cover(offer_without_chaser.created_at)

        expect(described_class.call(chaser_type:, date_range:)).to contain_exactly(application_choice_without_chaser, application_choice_with_chaser)
      end
    end
  end

  describe 'when the range is 10 to 20 days ago and offers are made inside the range' do
    let(:days) { 10 }

    context 'and the application is from the previous recruitment cycle' do
      let(:offset) { inside_range }
      let(:chaser_type) { :offer_10_day }
      let(:current_recruitment_cycle_year) { CycleTimetable.previous_year }

      it 'excludes applications from previous cycle' do
        expect(date_range).to cover(offer_without_chaser.created_at)

        expect(described_class.call(chaser_type:, date_range:)).to be_empty
      end
    end
  end
end
