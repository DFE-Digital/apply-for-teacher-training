require 'rails_helper'

RSpec.describe EndOfCycle::RejectByDefaultWorker do
  describe '#perform' do
    context 'when force is true' do
      it 'enqueues the secondary worker', time: mid_cycle do
        rejectable = create(:application_choice, :inactive)

        allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
        described_class.new.perform(true)
        expect(EndOfCycle::RejectByDefaultSecondaryWorker)
          .to have_received(:perform_at).with(kind_of(Time), [rejectable.application_form.id])
      end
    end

    context 'for previous cycle, current cycle' do
      [previous_year, current_year].each do |year|
        let(:instance) { described_class.new }

        context 'after the reject by default date', time: reject_by_default_run_date(year) do
          it 'enqueues the secondary worker' do
            inactive_choice = create(:application_choice, :inactive)
            interviewing_choice = create(:application_choice, :interviewing)
            awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision)

            # It will not include the offered application choice
            create(:application_choice, :offer)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker)
              .to have_received(:perform_at)
                    .with(
                      kind_of(Time),
                      contain_exactly(
                        inactive_choice.application_form.id,
                        interviewing_choice.application_form.id,
                        awaiting_decision_choice.application_form.id,
                      ),
                    )
          end
        end

        context 'between cycles, but not on reject by default date', time: after_apply_deadline(year) do
          it 'does not enqueue the secondary worker' do
            create(:application_choice, :inactive)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'in mid-cycle', time: mid_cycle(year) do
          it 'does not enqueue the secondary worker' do
            create(:application_choice, :inactive)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'after_apply_reopens', time: after_apply_reopens(year) do
          it 'does not enqueue the secondary worker' do
            create(:application_choice, :inactive)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            described_class.new.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'when winter reject dates are set, after the reject by default date', time: reject_by_default_run_date(year) do
          let(:september_course) { create(:course, start_date: Date.parse("01/09/#{year}")) }
          let(:january_course) { create(:course, start_date: Date.parse("01/01/#{year + 1}")) }

          it 'enqueues the secondary worker' do
            allow(instance).to receive(:winter_rejection_by_default_set?).and_return(true)
            allow(instance).to receive(:run_winter_reject_by_default?).and_return(false)

            inactive_choice = create(:application_choice, :inactive, course_option: create(:course_option, course: september_course))
            interviewing_choice = create(:application_choice, :interviewing, course_option: create(:course_option, course: september_course))
            awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision, course_option: create(:course_option, course: september_course))
            _unrejectable_choice = create(
              :application_choice,
              current_recruitment_cycle_year: year - 1,
              course_option: create(:course_option, course: january_course),
            )

            # It will not include the offered application choice
            create(:application_choice, :offer)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            instance.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker)
              .to have_received(:perform_at)
                    .with(
                      kind_of(Time),
                      contain_exactly(
                        inactive_choice.application_form.id,
                        interviewing_choice.application_form.id,
                        awaiting_decision_choice.application_form.id,
                      ),
                    )
          end
        end

        context 'when winter reject dates are set, after decline by default dates', time: decline_by_default_run_date(year) do
          let(:september_course) { create(:course, start_date: Date.parse("01/09/#{year}")) }
          let(:january_course) { create(:course, start_date: Date.parse("01/01/#{year + 1}")) }

          it 'does not enqueue the secondary worker' do
            allow(instance).to receive(:winter_rejection_by_default_set?).and_return(true)
            allow(instance).to receive(:run_winter_reject_by_default?).and_return(false)

            create(:application_choice, :inactive)
            create(
              :application_choice,
              current_recruitment_cycle_year: year - 1,
              course_option: create(:course_option, course: january_course),
            )

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            instance.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker).not_to have_received(:perform_at)
          end
        end

        context 'when winter reject dates are set, after the winter reject dates', time: decline_by_default_run_date(year) do
          let(:september_course) { create(:course, start_date: Date.parse("01/09/#{year}")) }
          let(:january_course) { create(:course, start_date: Date.parse("01/01/#{year + 1}")) }

          it 'enqueues the secondary worker' do
            allow(instance).to receive(:winter_rejection_by_default_set?).and_return(true)
            allow(instance).to receive(:run_winter_reject_by_default?).and_return(true)

            inactive_choice = create(
              :application_choice,
              :inactive,
              current_recruitment_cycle_year: year - 1,
              course_option: create(:course_option, course: january_course),
            )
            interviewing_choice = create(
              :application_choice,
              :interviewing,
              current_recruitment_cycle_year: year - 1,
              course_option: create(:course_option, course: january_course),
            )
            awaiting_decision_choice = create(
              :application_choice,
              :awaiting_provider_decision,
              current_recruitment_cycle_year: year - 1,
              course_option: create(:course_option, course: january_course),
            )
            _unrejectable_choice = create(
              :application_choice,
              course_option: create(:course_option, course: september_course),
            )

            # It will not include the offered application choice
            create(:application_choice, :offer)

            allow(EndOfCycle::RejectByDefaultSecondaryWorker).to receive(:perform_at)
            instance.perform
            expect(EndOfCycle::RejectByDefaultSecondaryWorker)
              .to have_received(:perform_at)
                    .with(
                      kind_of(Time),
                      contain_exactly(
                        inactive_choice.application_form.id,
                        interviewing_choice.application_form.id,
                        awaiting_decision_choice.application_form.id,
                      ),
                    )
          end
        end
      end
    end
  end
end
