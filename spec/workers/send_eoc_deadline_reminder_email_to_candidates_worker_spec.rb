require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesWorker, sidekiq: true do
  let(:send_reminder) { described_class.new.applications_to_send_reminders_to }

  describe '#perform' do
    context 'when the candidate is in Apply 1' do
      it 'returns an application when the deadline is 2 months away' do
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder) do
          application_form = create(:application_form)

          expect(send_reminder).to include application_form
        end
      end

      it 'returns an application when the deadline is 1 month away' do
        Timecop.travel(CycleTimetable.apply_1_deadline_second_reminder) do
          application_form = create(:application_form)

          expect(send_reminder).to include application_form
        end
      end

      it 'does not return an application when the deadline is 3 months away' do
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder - 1.month) do
          create(:application_form)

          expect(send_reminder).to be_empty
        end
      end

      it 'does not return an application when the deadline has passed' do
        Timecop.travel(CycleTimetable.apply_1_deadline + 1.day) do
          create(:application_form)

          expect(send_reminder).to be_empty
        end
      end

      it 'does not return an application form from the previous cycle' do
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder) do
          application_form_from_previous_cycle = create(:application_form, recruitment_cycle_year: RecruitmentCycle.previous_year)

          expect(send_reminder).to be_empty
        end
      end
    end

    context 'when the candidate is in Apply 2' do
      it 'returns an application when the deadline is 2 months away' do
        Timecop.travel(CycleTimetable.apply_2_deadline_first_reminder) do
          application_form = create(:application_form, phase: 'apply_2')

          expect(send_reminder).to include application_form
        end
      end

      it 'returns an application when the deadline is 1 month away' do
        Timecop.travel(CycleTimetable.apply_2_deadline_second_reminder) do
          application_form = create(:application_form, phase: 'apply_2')

          expect(send_reminder).to include application_form
        end
      end

      it 'does not return an application when the deadline is 3 months away' do
        Timecop.travel(CycleTimetable.apply_2_deadline_first_reminder - 1.month) do
          create(:application_form, phase: 'apply_2')

          expect(send_reminder).to be_empty
        end
      end

      it 'does not return an application when the deadline has passed' do
        Timecop.travel(CycleTimetable.apply_2_deadline + 1.day) do
          create(:application_form, phase: 'apply_2')

          expect(send_reminder).to be_empty
        end
      end

      it 'does not return an application form from the previous cycle' do
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder) do
          application_form_from_previous_cycle = create(:application_form, phase: 'apply_2', recruitment_cycle_year: RecruitmentCycle.previous_year)

          expect(send_reminder).to be_empty
        end
      end
    end
  end
end
