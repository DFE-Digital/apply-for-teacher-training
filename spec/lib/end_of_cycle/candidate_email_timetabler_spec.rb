require 'rails_helper'

RSpec.describe EndOfCycle::CandidateEmailTimetabler do
  let(:instance) { described_class.new }

  describe '.email_schedule' do
    subject(:email_schedule) { instance.email_schedule }

    describe 'decline_by_default_explainer_date' do
      it 'returns the decline_by_default_at plus one day' do
        expect(
          email_schedule[:decline_by_default_explainer_date],
        ).to eq current_timetable.decline_by_default_at.to_date + 1.day
      end
    end

    describe 'winter_reject_by_default_explainer_date' do
      context 'it is at the start of new cycle' do
        it 'returns date calculated on previous cycle winter reject by default at' do
          travel_temporarily_to(2026, 10, 10) do
            expect(
              email_schedule[:winter_reject_by_default_explainer_date],
            ).to eq Date.new(2027, 1, 21)
          end
        end
      end

      context 'it is in Jan, before the winter reject by default at' do
        it 'returns date calculated on previous cycle winter reject by default at' do
          travel_temporarily_to(2027, 1, 19) do
            expect(
              email_schedule[:winter_reject_by_default_explainer_date],
            ).to eq Date.new(2027, 1, 21)
          end
        end
      end

      context 'it is in Jan, between the winter reject by default and winter decline by default dates' do
        it 'returns date calculated on previous cycle winter reject by default at' do
          travel_temporarily_to(2027, 1, 24) do
            expect(
              email_schedule[:winter_reject_by_default_explainer_date],
            ).to eq Date.new(2027, 1, 21)
          end
        end
      end

      context 'it is after winter dates have passed' do
        it 'returns date calculated on current cycle winter reject by default at' do
          travel_temporarily_to(2027, 2, 1) do
            expect(
              email_schedule[:winter_reject_by_default_explainer_date],
            ).to eq Date.new(2028, 1, 27)
          end
        end
      end

      context 'when a specific, future timetable is provided' do
        it 'returns date calculated on given timetable' do
          timetable = RecruitmentCycleTimetable.find_by(recruitment_cycle_year: current_year + 2)
          schedule = described_class.new(timetable:).email_schedule
          expect(schedule[:winter_reject_by_default_explainer_date]).to eq((timetable.winter_reject_by_default_at + 1.day).to_date)
        end
      end
    end

    describe 'winter_decline_by_default_explainer_date' do
      context 'it is at the start of new cycle' do
        it 'returns date calculated on the previous cycle' do
          travel_temporarily_to(2026, 10, 10) do
            expected_date = Date.new(2027, 1, 25)
            expect(
              email_schedule[:winter_decline_by_default_explainer_date],
            ).to eq(expected_date)
            expect(expected_date).to eq((previous_timetable.winter_decline_by_default_at + 1.day).to_date)
          end
        end
      end

      context 'it is in Jan, before the winter reject by default at' do
        it 'returns date calculated on previous cycle winter reject by default at' do
          travel_temporarily_to(2027, 1, 19) do
            expected_date = Date.new(2027, 1, 25)
            expect(
              email_schedule[:winter_decline_by_default_explainer_date],
            ).to eq(expected_date)
            expect(expected_date).to eq((previous_timetable.winter_decline_by_default_at.to_date + 1.day).to_date)
          end
        end
      end

      context 'it is in Jan, between the winter reject by default and winter decline by default dates' do
        it 'returns date calculated on previous cycle winter reject by default at' do
          travel_temporarily_to(2027, 1, 24) do
            expected_date = Date.new(2027, 1, 25)
            expect(
              email_schedule[:winter_decline_by_default_explainer_date],
            ).to eq(expected_date)
            expect(expected_date).to eq((previous_timetable.winter_decline_by_default_at.to_date + 1.day).to_date)
          end
        end
      end

      context 'it is after winter dates have passed' do
        it 'returns date calculated on current cycle winter reject by default at' do
          travel_temporarily_to(2027, 2, 1) do
            expected_date = Date.new(2028, 1, 31)
            expect(
              email_schedule[:winter_decline_by_default_explainer_date],
            ).to eq expected_date
            expect(expected_date).to eq((current_timetable.winter_decline_by_default_at + 1.day).to_date)
          end
        end
      end
    end
  end

  describe 'send_winter_reject_by_default_explainer?' do
    subject(:send_winter_reject_by_default_explainer?) { instance.send_winter_reject_by_default_explainer? }

    context 'when winter_reject_by_default_explainer_date is nil' do
      before do
        allow(instance).to receive(:winter_reject_by_default_explainer_date).and_return(nil)
      end

      it 'returns false' do
        expect(send_winter_reject_by_default_explainer?).to be(false)
      end
    end

    context 'when the current date does not match the winter reject by default explainer date' do
      it 'returns false' do
        travel_temporarily_to(current_timetable.winter_reject_by_default_at + 1.month, freeze: true) do
          expect(send_winter_reject_by_default_explainer?).to be(false)
        end
      end
    end

    context 'when the current date matches the winter reject by default explainer date' do
      it 'returns true' do
        travel_temporarily_to(current_timetable.winter_reject_by_default_at + 1.day) do
          expect(send_winter_reject_by_default_explainer?).to be(true)
        end
      end
    end
  end

  describe 'send_winter_decline_by_default_explainer?' do
    subject(:send_winter_decline_by_default_explainer?) { instance.send_winter_decline_by_default_explainer? }

    context 'when the current date does not match the winter decline by default explainer date' do
      it 'returns false' do
        travel_temporarily_to(current_timetable.winter_decline_by_default_at + 1.month, freeze: true) do
          expect(send_winter_decline_by_default_explainer?).to be(false)
        end
      end
    end

    context 'when the current date matches the winter decline by default explainer date' do
      it 'returns true' do
        travel_temporarily_to(current_timetable.winter_decline_by_default_at + 1.day) do
          expect(send_winter_decline_by_default_explainer?).to be(true)
        end
      end
    end
  end

  describe 'send_decline_by_default_explainer?' do
    subject(:send_decline_by_default_explainer?) { instance.send_decline_by_default_explainer? }

    context 'when the current date does not match the decline by default explainer date' do
      it 'returns false' do
        travel_temporarily_to(current_timetable.decline_by_default_at + 1.month, freeze: true) do
          expect(send_decline_by_default_explainer?).to be(false)
        end
      end
    end

    context 'when the current date matches the decline by default explainer date' do
      it 'returns true' do
        travel_temporarily_to(current_timetable.decline_by_default_at + 1.day) do
          expect(send_decline_by_default_explainer?).to be(true)
        end
      end
    end
  end
end
