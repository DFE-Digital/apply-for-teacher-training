require 'rails_helper'

RSpec.describe EndOfCycle::ProviderEmailTimetabler do
  let(:instance) { described_class.new }

  describe '.send_winter_reject_by_default_reminder_to_providers?' do
    subject(:send_winter_reject_by_default_reminder_to_providers?) { instance.send_winter_reject_by_default_reminder_to_providers? }

    context 'when winter_reject_by_default_explainer_date is nil' do
      it 'returns false' do
        expect(send_winter_reject_by_default_reminder_to_providers?).to be(false)
      end
    end

    context 'when the current date does not match the winter reject by default explainer date' do
      before do
        TestSuiteTimeMachine.travel_permanently_to(Time.zone.now.next_weekday.to_date)
        allow(instance).to receive(:timetable).and_return(Struct.new(:winter_reject_by_default_at).new(winter_reject_by_default_at))
      end

      let(:winter_reject_by_default_at) { 1.month.ago.to_date }

      it 'returns false' do
        expect(send_winter_reject_by_default_reminder_to_providers?).to be(false)
      end
    end

    context 'when the current date matches the winter reject by default explainer date' do
      before do
        TestSuiteTimeMachine.travel_permanently_to(Time.zone.now.next_weekday.to_date)
        allow(instance).to receive(:timetable).and_return(Struct.new(:winter_reject_by_default_at).new(winter_reject_by_default_at))
      end

      let(:winter_reject_by_default_at) { 2.weeks.from_now.to_date }

      it 'returns false' do
        expect(send_winter_reject_by_default_reminder_to_providers?).to be(true)
      end
    end
  end

  describe '.winter_reject_by_default_reminder_provider_date' do
    subject(:winter_reject_by_default_reminder_provider_date) { instance.winter_reject_by_default_reminder_provider_date }

    context 'when the timetable winter_reject_by_default_at attribute is nil' do
      it 'returns nil' do
        expect(winter_reject_by_default_reminder_provider_date).to be_nil
      end
    end

    context 'when the timetable winter_reject_by_default_at attribute is not nil' do
      it 'returns a date 2 weeks before the timetable winter_reject_by_default_at attribute' do
        allow(instance).to receive(:timetable).and_return(Struct.new(:winter_reject_by_default_at).new(Date.parse('01/09/2026')))
        expect(winter_reject_by_default_reminder_provider_date).to eq(Date.parse('18/08/2026'))
      end
    end
  end
end
