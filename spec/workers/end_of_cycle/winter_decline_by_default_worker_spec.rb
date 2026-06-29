require 'rails_helper'

RSpec.describe EndOfCycle::WinterDeclineByDefaultWorker do
  let(:year) { RecruitmentCycleTimetable.current_year }
  let(:instance) { described_class.new }
  let(:last_september_course) { create(:course, recruitment_cycle_year: year - 1, start_date: Date.parse("01/09/#{year - 1}")) }
  let(:september_course) { create(:course, start_date: Date.parse("01/09/#{year}")) }
  let(:january_course) { create(:course, recruitment_cycle_year: year - 1, start_date: Date.parse("01/01/#{year}")) }
  let(:duplicate_january_course) { create(:course, start_date: Date.parse("01/01/#{year}")) }
  let!(:undeclineable_this_cycle) do
    create(
      :application_choice,
      :offer,
      course_option: create(:course_option, course: september_course),
    )
  end
  let!(:undeclineable_last_cycle) do
    create(
      :application_choice,
      :offer,
      current_recruitment_cycle_year: year - 1,
      course_option: create(:course_option, course: last_september_course),
    )
  end
  let!(:declineable_last_cycle) do
    create(
      :application_choice,
      :offer,
      current_recruitment_cycle_year: year - 1,
      course_option: create(:course_option, course: january_course),
    )
  end
  let!(:declineable_this_cycle) do
    create(
      :application_choice,
      :offer,
      current_recruitment_cycle_year: year,
      course_option: create(:course_option, course: duplicate_january_course),
    )
  end

  describe '#perform' do
    context 'where force is true' do
      it 'enqueues secondary worker for offered application choices', time: mid_cycle do
        expect { instance.perform(true) }.to enqueue_job(EndOfCycle::WinterDeclineByDefaultSecondaryWorker).with(contain_exactly(declineable_last_cycle.application_form.id, declineable_this_cycle.application_form.id))
      end
    end

    context 'after winter decline by default date' do
      it 'enqueues secondary worker for offered application choices' do
        allow(instance).to receive_messages(run_winter_decline_by_default?: true)
        expect { instance.perform }.to enqueue_job(EndOfCycle::WinterDeclineByDefaultSecondaryWorker).with(contain_exactly(declineable_last_cycle.application_form.id, declineable_this_cycle.application_form.id))
      end
    end

    context 'before winter decline by default date' do
      it 'enqueues secondary worker for offered application choices' do
        allow(instance).to receive_messages(run_winter_decline_by_default?: false)
        expect { instance.perform }.not_to enqueue_job(EndOfCycle::WinterDeclineByDefaultSecondaryWorker)
      end
    end
  end
end
