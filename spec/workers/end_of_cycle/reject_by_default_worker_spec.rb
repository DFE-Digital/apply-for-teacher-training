require 'rails_helper'

RSpec.describe EndOfCycle::RejectByDefaultWorker do
  describe '#perform' do
    context 'when force is true' do
      it 'enqueues the secondary worker', time: mid_cycle do
        rejectable = create(:application_choice, :inactive)

        expect { described_class.new.perform(true) }.to enqueue_job(EndOfCycle::RejectByDefaultSecondaryWorker).with(contain_exactly(rejectable.application_form.id))
      end
    end

    context 'for previous cycle, current cycle' do
      [previous_year, current_year].each do |year|
        let(:instance) { described_class.new }

        context 'after the reject by default date', time: reject_by_default_run_date(year) do
          it 'enqueues the secondary worker' do
            allow(instance).to receive_messages(winter_rejection_by_default_set?: false)
            inactive_choice = create(:application_choice, :inactive)
            interviewing_choice = create(:application_choice, :interviewing)
            awaiting_decision_choice = create(:application_choice, :awaiting_provider_decision)

            # It will not include the offered application choice
            create(:application_choice, :offer)

            expect { instance.perform }.to enqueue_job(EndOfCycle::RejectByDefaultSecondaryWorker)
              .with(
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

            expect { described_class.new.perform }.not_to enqueue_job(EndOfCycle::RejectByDefaultSecondaryWorker)
          end
        end

        context 'in mid-cycle', time: mid_cycle(year) do
          it 'does not enqueue the secondary worker' do
            create(:application_choice, :inactive)

            expect { described_class.new.perform }.not_to enqueue_job(EndOfCycle::RejectByDefaultSecondaryWorker)
          end
        end

        context 'after_apply_reopens', time: after_apply_reopens(year) do
          it 'does not enqueue the secondary worker' do
            create(:application_choice, :inactive)

            expect { described_class.new.perform }.not_to enqueue_job(EndOfCycle::RejectByDefaultSecondaryWorker)
          end
        end

        context 'when winter reject dates are set, after the reject by default date', time: reject_by_default_run_date(year) do
          let(:september_course) { create(:course, start_date: Date.parse("01/09/#{year}")) }
          let(:january_course) { create(:course, start_date: Date.parse("01/01/#{year + 1}")) }

          it 'enqueues the secondary worker' do
            allow(instance).to receive_messages(winter_rejection_by_default_set?: true)

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

            expect { instance.perform }.to enqueue_job(EndOfCycle::RejectByDefaultSecondaryWorker)
              .with(
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
            create(:application_choice, :inactive)
            create(
              :application_choice,
              current_recruitment_cycle_year: year - 1,
              course_option: create(:course_option, course: january_course),
            )

            expect { instance.perform }.not_to enqueue_job(EndOfCycle::RejectByDefaultSecondaryWorker)
          end
        end
      end
    end
  end
end
