require 'rails_helper'

RSpec.describe EndOfCycle::ProviderEmailTimetabler do
  let(:instance) { described_class.new }

  describe '.send_winter_reject_by_default_reminder_to_providers?' do
    subject(:send_winter_reject_by_default_reminder_to_providers?) { instance.send_winter_reject_by_default_reminder_to_providers? }

    context 'when the current date does not match the winter reject by default explainer date' do
      before do
        TestSuiteTimeMachine.travel_permanently_to(current_timetable.winter_reject_by_default_at + 1.day)
      end

      it 'returns false' do
        expect(send_winter_reject_by_default_reminder_to_providers?).to be(false)
      end
    end

    context 'when the current date matches the winter reject by default explainer date' do
      before do
        TestSuiteTimeMachine.travel_permanently_to(current_timetable.winter_reject_by_default_at - 2.weeks)
      end

      it 'returns false' do
        expect(send_winter_reject_by_default_reminder_to_providers?).to be(true)
      end
    end
  end

  describe '.winter_reject_by_default_reminder_provider_date' do
    subject(:winter_reject_by_default_reminder_provider_date) { instance.winter_reject_by_default_reminder_provider_date }

    context 'when the timetable winter_reject_by_default_at attribute is not nil' do
      it 'returns a date 2 weeks before the timetable winter_reject_by_default_at attribute' do
        if previous_timetable.winter_reject_by_default_at.nil?
          previous_timetable.update(winter_reject_by_default_at: previous_timetable.reject_by_default_at + 17.weeks)
        end

        expect(winter_reject_by_default_reminder_provider_date.to_date).to eq((previous_timetable.winter_reject_by_default_at - 2.weeks).to_date)
      end
    end
  end
end
