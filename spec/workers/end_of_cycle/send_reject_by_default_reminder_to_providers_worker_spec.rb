require 'rails_helper'

RSpec.describe EndOfCycle::SendRejectByDefaultReminderToProvidersWorker do
  describe '#perform' do
    context 'is before the date for sending the reminder' do
      it 'does not enqueue the batch worker' do
        travel_temporarily_to(email_send_date - 1.day) do
          application_choices = create(:application_choice, :awaiting_provider_decision)
          create(:provider_permissions, provider: application_choices.provider)

          allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
          described_class.new.perform
          expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).not_to have_received(:perform_at)
        end
      end
    end

    context 'is after the date for sending the reminder' do
      it 'does not enqueue the batch worker' do
        travel_temporarily_to(email_send_date + 1.day) do
          application_choices = create(:application_choice, :awaiting_provider_decision)
          create(:provider_permissions, provider: application_choices.provider)

          allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
          described_class.new.perform
          expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).not_to have_received(:perform_at)
        end
      end
    end

    context 'it is on the reminder date' do
      it 'calls batch worker with application choices' do
        travel_temporarily_to(email_send_date) do
          inactive_application = create(:application_choice, :inactive)
          interview_application = create(:application_choice, :interviewing)
          awaiting_application = create(:application_choice, :awaiting_provider_decision)

          # These two application choices should not be included
          create(:application_choice, :rejected)
          create(:application_choice, :unsubmitted)

          allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
          described_class.new.perform

          expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker)
            .to have_received(:perform_at).with(kind_of(Time), [
              inactive_application.provider.id,
              interview_application.provider.id,
              awaiting_application.provider.id,
            ])
        end
      end
    end

    context 'when winter reject by default is set, and it is on the reminder date' do
      let(:instance) { described_class.new }

      it 'calls batch worker with application choices with september start dates' do
        travel_temporarily_to(email_send_date) do
          allow(instance).to receive(:winter_reject_by_default_set?).and_return(true)
          current_year = RecruitmentCycleTimetable.current_year

          september_course = create(:course, start_date: Date.parse("01/09/#{current_year}"))
          _inactive_application = create(:application_choice, :inactive, course_option: create(:course_option, course: september_course))
          _interview_application = create(:application_choice, :interviewing, course_option: create(:course_option, course: september_course))
          _awaiting_application = create(:application_choice, :awaiting_provider_decision, course_option: create(:course_option, course: september_course))

          january_course = create(:course, start_date: Date.parse("01/01/#{current_year + 1}"))
          _jan_inactive_application = create(:application_choice, :inactive, course_option: create(:course_option, course: january_course))
          _jan_interview_application = create(:application_choice, :interviewing, course_option: create(:course_option, course: january_course))
          _jan_awaiting_application = create(:application_choice, :awaiting_provider_decision, course_option: create(:course_option, course: january_course))

          # These two application choices should not be included
          create(:application_choice, :rejected)
          create(:application_choice, :unsubmitted)

          allow(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
          instance.perform

          expect(EndOfCycle::SendRejectByDefaultReminderToProvidersBatchWorker)
            .to have_received(:perform_at).with(kind_of(Time), [
              september_course.provider.id,
            ])
        end
      end
    end
  end

  def email_send_date
    EndOfCycle::ProviderEmailTimetabler.new.reject_by_default_reminder_provider_date
  end
end
