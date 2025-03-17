require 'rails_helper'

RSpec.describe OffersToChaseQuery do
  let(:application_choice_without_offer) { create(:application_choice, :awaiting_provider_decision) }
  let(:application_choice_with_offer_not_in_offer_status) { create(:application_choice, :recruited, offered_at: Time.zone.now) }
  let(:application_choice_offer_from_last_cycle) { create(:application_choice, current_recruitment_cycle_year: CycleTimetable.previous_year, offered_at: inside_range) }

  let(:application_choice_with_chaser) { create(:application_choice, :offer, chasers_sent: [create(:chaser_sent, chaser_type: "offer_#{days}_day")]) }

  let(:application_choice_without_chaser) { create(:application_choice, :offer, current_recruitment_cycle_year:) }
  let(:current_timetable) { RecruitmentCycleTimetable.current_timetable }
  let(:current_recruitment_cycle_year) { current_timetable.recruitment_cycle_year }

  # We have to make sure our offset doesn't mean we are straddling two recruitment cycles.
  let(:travel_to_base) { current_timetable.apply_deadline_at - 2.months }

  before do
    TestSuiteTimeMachine.travel_temporarily_to(offset) do
      application_choice_without_offer
      application_choice_with_chaser
      application_choice_without_chaser
    end
  end

  context 'candidate does not want to receive nudges' do
    let(:chaser_type) { :offer_10_day }
    let(:days) { 10 }

    let(:date_range) { (travel_to_base - days.days).all_day }
    let(:inside_range) { date_range.max - 1.hour }
    let(:offset) { inside_range }

    before do
      application_choice_without_chaser.candidate.update(unsubscribed_from_emails: true)
    end

    it 'does not return any application choices for that candidate even though the application choice is in range' do
      expect(date_range).to cover(application_choice_without_chaser.offered_at)
      expect(described_class.call(chaser_type:, date_range:)).to be_empty
    end
  end

  context 'when offers are made 9 days ago for offer_10_day' do
    let(:chaser_type) { :offer_10_day }
    let(:days) { 10 }

    let(:date_range) { (travel_to_base - days.days).all_day }
    let(:outside_range) { date_range.max + 1.hour }
    let(:offset) { outside_range }

    it 'returns empty collection' do
      nine_days_ago = (travel_to_base - 9.days).all_day
      expect(nine_days_ago).to cover(application_choice_without_chaser.offered_at)
      expect(described_class.call(chaser_type:, date_range:)).to be_empty
    end
  end

  context 'when offers are made 10 days ago and chaser_type is offer_10_day' do
    let(:chaser_type) { :offer_10_day }
    let(:days) { 10 }

    let(:date_range) { (travel_to_base - days.days).all_day }
    let(:inside_range) { date_range.max - 1.hour }
    let(:offset) { inside_range }

    it 'returns the application choice without a chaser' do
      expect(date_range).to cover(application_choice_without_chaser.offered_at)

      expect(described_class.call(chaser_type:, date_range:)).to contain_exactly(application_choice_without_chaser)
    end
  end

  describe 'when the range is 20 days ago and offers are made 20 days ago' do
    let(:days) { 20 }
    let(:date_range) { (travel_to_base - days.days).all_day }
    let(:inside_range) { date_range.max - 1.hour }

    context 'and chaser_type is offer_20_day and chaser has been sent for offer_20_day' do
      let(:offset) { inside_range }
      let(:chaser_type) { :offer_20_day }

      it 'returns the application choice without a chaser sent' do
        expect(date_range).to cover(application_choice_without_chaser.offered_at)

        expect(described_class.call(chaser_type:, date_range:)).to contain_exactly(application_choice_without_chaser)
      end
    end

    context 'and chaser_type is offer_20_day and chaser only sent for offer_10_day' do
      let(:offset) { inside_range }
      let(:chaser_type) { :offer_10_day }

      it 'returns the application choice no chaser sent and one with old chaser sent' do
        expect(date_range).to cover(application_choice_without_chaser.offered_at)

        expect(described_class.call(chaser_type:, date_range:)).to contain_exactly(application_choice_without_chaser, application_choice_with_chaser)
      end
    end
  end

  describe 'when the range is 10 days ago and offers are made 10 days ago' do
    let(:days) { 10 }
    let(:date_range) { (travel_to_base - days.days).all_day }
    let(:inside_range) { date_range.max - 1.hour }

    context 'and the application is from the previous recruitment cycle' do
      let(:offset) { inside_range }
      let(:chaser_type) { :offer_10_day }
      let(:current_recruitment_cycle_year) { RecruitmentCycleTimetable.previous_year }

      it 'excludes applications from previous cycle' do
        expect(date_range).to cover(application_choice_without_chaser.offered_at)

        expect(described_class.call(chaser_type:, date_range:)).to be_empty
      end
    end
  end
end
