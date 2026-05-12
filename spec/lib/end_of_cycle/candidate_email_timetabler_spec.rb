require 'rails_helper'

RSpec.describe EndOfCycle::CandidateEmailTimetabler do
  let(:instance) { described_class.new }

  describe '.email_schedule' do
    subject(:email_schedule) { instance.email_schedule }

    describe 'winter_reject_by_default_explainer_date' do
      context 'when the timetable winter_reject_by_default_at attribute is nil' do
        it 'returns nil' do
          expect(instance.winter_reject_by_default_explainer_date).to be_nil
        end
      end

      context 'when the timetable winter_reject_by_default_at attribute is not nil' do
        before do
          allow(instance).to receive(:winter_reject_by_default_explainer_date).and_return(Date.parse('01/09/2026'))
        end

        it 'returns the winter_reject_by_default_at plus one day' do
          expect(email_schedule[:winter_reject_by_default_explainer_date]).to eq Date.parse('01/09/2026')
        end
      end
    end
  end

  describe '.winter_reject_by_default_explainer_date' do
    subject(:winter_reject_by_default_explainer_date) { instance.winter_reject_by_default_explainer_date }

    context 'when the timetable winter_reject_by_default_at attribute is nil' do
      it 'returns nil' do
        expect(winter_reject_by_default_explainer_date).to be_nil
      end
    end

    context 'when the timetable winter_reject_by_default_at attribute is set' do
      before do
        allow(instance).to receive(:timetable).and_return(Struct.new(:winter_reject_by_default_at).new(Date.parse('31/08/2026')))
      end

      it 'returns the winter_reject_by_default_at plus one day' do
        expect(winter_reject_by_default_explainer_date).to eq Date.parse('01/09/2026')
      end
    end
  end

  describe 'send_winter_reject_by_default_explainer?' do
    subject(:send_winter_reject_by_default_explainer?) { instance.send_winter_reject_by_default_explainer? }

    context 'when winter_reject_by_default_explainer_date is nil' do
      it 'returns false' do
        expect(send_winter_reject_by_default_explainer?).to be(false)
      end
    end

    context 'when the current date does not match the winter reject by default explainer date' do
      before do
        allow(instance).to receive(:email_schedule).and_return({ winter_reject_by_default_explainer_date: 1.month.ago.to_date })
      end

      it 'returns false' do
        expect(send_winter_reject_by_default_explainer?).to be(false)
      end
    end

    context 'when the current date matches the winter reject by default explainer date' do
      before do
        allow(instance).to receive(:email_schedule).and_return({ winter_reject_by_default_explainer_date: Date.current })
      end

      it 'returns false' do
        expect(send_winter_reject_by_default_explainer?).to be(true)
      end
    end
  end
end
