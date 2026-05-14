require 'rails_helper'

RSpec.describe EndOfCycle::WinterDeclineByDefaultWorker do
  let(:year) { RecruitmentCycleTimetable.current_year }
  let(:instance) { described_class.new }
  let(:september_course) { create(:course, start_date: Date.parse("01/09/#{year}")) }
  let(:january_course) { create(:course, start_date: Date.parse("01/01/#{year}")) }
  let!(:undeclineable) do
    create(:application_choice, :offer, course_option: create(:course_option, course: september_course))
  end
  let!(:declineable) do
    create(
      :application_choice,
      :offer,
      current_recruitment_cycle_year: year - 1,
      course_option: create(:course_option, course: january_course),
      )
  end

  describe '#perform' do
    context 'where force is true' do
      it 'enqueues secondary worker for offered application choices', time: mid_cycle do
        allow(EndOfCycle::WinterDeclineByDefaultSecondaryWorker).to receive(:perform_at)
        instance.perform(true)
        expect(EndOfCycle::WinterDeclineByDefaultSecondaryWorker)
          .to have_received(:perform_at).with(kind_of(Time), [declineable.application_form.id])
      end
    end

    context 'after winter decline by default date' do
      it 'enqueues secondary worker for offered application choices' do
        allow(instance).to receive_messages(run_winter_decline_by_default?: true)
        allow(EndOfCycle::WinterDeclineByDefaultSecondaryWorker).to receive(:perform_at)
        instance.perform
        expect(EndOfCycle::WinterDeclineByDefaultSecondaryWorker)
          .to have_received(:perform_at).with(kind_of(Time), [declineable.application_form.id])
      end
    end

    context 'before winter decline by default date' do
      it 'enqueues secondary worker for offered application choices' do
        allow(instance).to receive_messages(run_winter_decline_by_default?: false)
        allow(EndOfCycle::WinterDeclineByDefaultSecondaryWorker).to receive(:perform_at)
        instance.perform
        expect(EndOfCycle::WinterDeclineByDefaultSecondaryWorker)
          .not_to have_received(:perform_at)
      end
    end
  end
end
