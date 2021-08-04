require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesWorker, sidekiq: true do
  describe '#perform' do
    before do
      allow(SendEocDeadlineReminderEmailToCandidate).to receive(:call).and_return true
    end

    context 'when the candidate is in Apply 1' do
      let(:application_form) { create(:application_form) }

      it 'returns an application when the deadline is 2 months away' do
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder) do
          application_form = create(:application_form)
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).to have_received(:call).with(application_form: application_form)
        end
      end

      it 'returns an application when the deadline is 1 month away' do
        Timecop.travel(CycleTimetable.apply_1_deadline_second_reminder) do
          application_form = create(:application_form)
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).to have_received(:call).with(application_form: application_form)
        end
      end

      it 'does not return an application when the deadline is 3 months away' do
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder - 1.month) do
          create(:application_form)
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).not_to have_received(:call)
        end
      end

      it 'does not return an application when the deadline has passed' do
        Timecop.travel(CycleTimetable.apply_1_deadline + 1.day) do
          create(:application_form)
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).not_to have_received(:call)
        end
      end

      it 'does not return an application form from the previous cycle' do
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder) do
          create(:application_form, recruitment_cycle_year: RecruitmentCycle.previous_year)
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).not_to have_received(:call)
        end
      end
    end

    context 'when the candidate is in Apply 2' do
      it 'returns an application when the deadline is 2 months away' do
        Timecop.travel(CycleTimetable.apply_2_deadline_first_reminder) do
          application_form = create(:application_form, phase: 'apply_2')
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).to have_received(:call).with(application_form: application_form)
        end
      end

      it 'returns an application when the deadline is 1 month away' do
        Timecop.travel(CycleTimetable.apply_2_deadline_second_reminder) do
          application_form = create(:application_form, phase: 'apply_2')
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).to have_received(:call).with(application_form: application_form)
        end
      end

      it 'does not return an application when the deadline is 3 months away' do
        Timecop.travel(CycleTimetable.apply_2_deadline_first_reminder - 1.month) do
          create(:application_form, phase: 'apply_2')
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).not_to have_received(:call)
        end
      end

      it 'does not return an application when the deadline has passed' do
        Timecop.travel(CycleTimetable.apply_2_deadline + 1.day) do
          create(:application_form, phase: 'apply_2')
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).not_to have_received(:call)
        end
      end

      it 'does not return an application form from the previous cycle' do
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder) do
          create(:application_form, phase: 'apply_2', recruitment_cycle_year: RecruitmentCycle.previous_year)
          described_class.new.perform

          expect(SendEocDeadlineReminderEmailToCandidate).not_to have_received(:call)
        end
      end
    end
  end
end
