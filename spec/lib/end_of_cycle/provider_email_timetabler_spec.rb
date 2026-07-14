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

    context 'before the previous cycle has completely closed' do
      it 'returns the winter reject by default at date from the previous cycle - 2 weeks' do
        travel_temporarily_to(current_timetable.winter_decline_by_default_at - 1.month) do
          if previous_timetable.winter_reject_by_default_at.nil?
            previous_timetable.update(winter_reject_by_default_at: previous_timetable.reject_by_default_at + 17.weeks)
          end

          expect(winter_reject_by_default_reminder_provider_date.to_date).to eq((previous_timetable.winter_reject_by_default_at - 2.weeks).to_date)
        end
      end
    end

    context 'after the previous cycle has completely closed' do
      it 'returns the winter reject by default at date from the current cycle - 2 weeks' do
        travel_temporarily_to(current_timetable.winter_decline_by_default_at + 1.day) do
          expect(winter_reject_by_default_reminder_provider_date.to_date).to eq((current_timetable.winter_reject_by_default_at - 2.weeks).to_date)
        end
      end
    end
  end
end
