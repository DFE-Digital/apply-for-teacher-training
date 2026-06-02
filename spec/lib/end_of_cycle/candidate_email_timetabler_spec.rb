require 'rails_helper'

RSpec.describe EndOfCycle::CandidateEmailTimetabler do
  let(:instance) { described_class.new(timetable:) }
  let(:timetable) { RecruitmentCycleTimetable.previous_timetable }

  describe '.email_schedule' do
    subject(:email_schedule) { instance.email_schedule }

    describe 'winter_reject_by_default_explainer_date' do
      context 'when the timetable winter_reject_by_default_at attribute is nil' do
        before do
          allow(instance).to receive(:timetable).and_return(RecruitmentCycleTimetable.new)
        end

        it 'returns nil' do
          expect(instance.winter_reject_by_default_explainer_date).to be_nil
        end
      end

      context 'when the timetable winter_reject_by_default_at attribute is not nil' do
        it 'returns the winter_reject_by_default_at plus one day' do
          expect(
            email_schedule[:winter_reject_by_default_explainer_date],
          ).to eq timetable.winter_reject_by_default_at.to_date + 1.day
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
end
