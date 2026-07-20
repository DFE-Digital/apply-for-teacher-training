require 'rails_helper'

RSpec.describe EndOfCycle::WinterRejectByDefaultWorker do
  let(:year) { RecruitmentCycleTimetable.current_year }
  let(:instance) { described_class.new }
  let(:last_september_course) { create(:course, recruitment_cycle_year: year - 1, start_date: Date.parse("01/09/#{year - 1}")) }
  let(:september_course) { create(:course, start_date: Date.parse("01/09/#{year}")) }
  let(:january_course) { create(:course, recruitment_cycle_year: year - 1, start_date: Date.parse("01/01/#{year}")) }
  let(:duplicate_january_course) { create(:course, start_date: Date.parse("01/01/#{year}")) }
  let!(:last_september_choice) do
    create(
      :application_choice,
      :inactive,
      current_recruitment_cycle_year: year - 1,
      course_option: create(:course_option, course: last_september_course),
    )
  end
  let!(:inactive_choice) do
    create(
      :application_choice,
      :inactive,
      current_recruitment_cycle_year: year - 1,
      course_option: create(:course_option, course: january_course),
    )
  end
  let!(:inactive_choice_this_cycle) do
    create(
      :application_choice,
      :inactive,
      current_recruitment_cycle_year: year,
      course_option: create(:course_option, course: duplicate_january_course),
    )
  end
  let!(:interviewing_choice) do
    create(
      :application_choice,
      :interviewing,
      current_recruitment_cycle_year: year - 1,
      course_option: create(:course_option, course: january_course),
    )
  end
  let!(:awaiting_decision_choice) do
    create(
      :application_choice,
      :awaiting_provider_decision,
      current_recruitment_cycle_year: year - 1,
      course_option: create(:course_option, course: january_course),
    )
  end
  let(:unrejectable_choice) do
    create(
      :application_choice,
      course_option: create(:course_option, course: september_course),
    )
  end

  before do
    unrejectable_choice
    # It will not include the offered application choice
    create(:application_choice, :offer)
  end

  describe '#perform' do
    context 'where force is true' do
      it 'enqueues the secondary worker', time: mid_cycle do
        allow(EndOfCycle::WinterRejectByDefaultSecondaryWorker).to receive(:perform_at)
        instance.perform(force: true)
        expect(EndOfCycle::WinterRejectByDefaultSecondaryWorker)
          .to have_received(:perform_at)
                .with(
                  kind_of(Time),
                  contain_exactly(
                    inactive_choice.application_form.id,
                    interviewing_choice.application_form.id,
                    awaiting_decision_choice.application_form.id,
                    inactive_choice_this_cycle.application_form.id,
                  ),
                )
      end
    end

    context 'after winter reject by default dates' do
      it 'enqueues the secondary worker' do
        allow(instance).to receive_messages(run_winter_reject_by_default?: true)
        allow(EndOfCycle::WinterRejectByDefaultSecondaryWorker).to receive(:perform_at)
        instance.perform
        expect(EndOfCycle::WinterRejectByDefaultSecondaryWorker)
          .to have_received(:perform_at)
                .with(
                  kind_of(Time),
                  contain_exactly(
                    inactive_choice.application_form.id,
                    interviewing_choice.application_form.id,
                    awaiting_decision_choice.application_form.id,
                    inactive_choice_this_cycle.application_form.id,
                  ),
                )
      end
    end

    context 'before winter reject by default dates' do
      it 'enqueues the secondary worker' do
        allow(instance).to receive_messages(run_winter_reject_by_default?: false)
        allow(EndOfCycle::WinterRejectByDefaultSecondaryWorker).to receive(:perform_at)
        instance.perform
        expect(EndOfCycle::WinterRejectByDefaultSecondaryWorker)
          .not_to have_received(:perform_at)
      end
    end
  end
end
