require 'rails_helper'

RSpec.describe Chasers::Candidate::OfferWorker do
  describe '#perform' do
    before do
      allow(Chasers::Candidate::OfferEmailService).to receive(:call).and_call_original
      allow(OffersToChaseQuery).to receive(:call).and_call_original
    end

    context 'when applications are offered in different periods' do
      let!(:application_choices) do
        Chasers::Candidate.chaser_to_date_range.each_value do |date_range|
          create(:application_choice, :offer, offered_at: date_range.min)
        end
      end
      let(:chaser_types) do
        Chasers::Candidate.chaser_types
      end
      let(:mailers) { chaser_types }
      let(:groups) { application_choices.zip(chaser_types, mailers) }

      it 'calls the service for each chaser interval' do
        described_class.new.perform

        expect(OffersToChaseQuery).to have_received(:call).with(chaser_type: Symbol, date_range: Range).exactly(5).times
        groups do |application_choice, chaser_type, mailer|
          expect(Chasers::Candidate::OfferEmailService).to have_received(:call).with(chaser_type:, mailer:, application_choice:)
        end
      end
    end

    context 'when the same application received an offer without decision' do
      it 'sends offer emails in the expected date ranges', time: Time.zone.local(2023, 12, 11) do
        application_choice = create(:application_choice, :offer)

        described_class.new.perform

        expect(Chasers::Candidate::OfferEmailService).not_to have_received(:call)

        TestSuiteTimeMachine.advance_time_to(9.days.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 0

        TestSuiteTimeMachine.advance_time_to(1.day.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 1
        expect(application_choice.chasers_sent.pluck(:chaser_type)).to contain_exactly('offer_10_day')

        TestSuiteTimeMachine.advance_time_to(9.days.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 1

        TestSuiteTimeMachine.advance_time_to(1.day.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 2
        expect(application_choice.chasers_sent.pluck(:chaser_type)).to contain_exactly('offer_10_day', 'offer_20_day')

        TestSuiteTimeMachine.advance_time_to(9.days.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 2

        TestSuiteTimeMachine.advance_time_to(1.day.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 3
        expect(application_choice.chasers_sent.pluck(:chaser_type)).to contain_exactly('offer_10_day', 'offer_20_day', 'offer_30_day')

        TestSuiteTimeMachine.advance_time_to(9.days.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 3

        TestSuiteTimeMachine.advance_time_to(1.day.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 4
        expect(application_choice.chasers_sent.pluck(:chaser_type)).to contain_exactly('offer_10_day', 'offer_20_day', 'offer_30_day', 'offer_40_day')

        TestSuiteTimeMachine.advance_time_to(9.days.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 4

        TestSuiteTimeMachine.advance_time_to(1.day.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 5
        expect(application_choice.chasers_sent.pluck(:chaser_type)).to contain_exactly('offer_10_day', 'offer_20_day', 'offer_30_day', 'offer_40_day', 'offer_50_day')

        TestSuiteTimeMachine.advance_time_to(1.day.from_now)
        described_class.new.perform
        expect(application_choice.chasers_sent.count).to be 5
      end
    end
  end
end
