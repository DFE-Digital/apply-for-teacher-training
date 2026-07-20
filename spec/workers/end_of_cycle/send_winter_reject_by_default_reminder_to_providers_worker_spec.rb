require 'rails_helper'

RSpec.describe EndOfCycle::SendWinterRejectByDefaultReminderToProvidersWorker do
  let(:instance) { described_class.new }
  let(:previous_year) { RecruitmentCycleTimetable.previous_year }

  describe '#perform' do
    context 'is before or after the date for sending the reminder' do
      it 'does not enqueue the batch worker' do
        travel_temporarily_to(email_send_date - 1.day) do
          application_choice = create(
            :application_choice,
            :awaiting_provider_decision,
            current_recruitment_cycle_year: previous_year,
            application_form: create(:application_form, recruitment_cycle_year: previous_year),
          )
          create(:provider_permissions, provider: application_choice.provider)

          allow(EndOfCycle::SendWinterRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
          described_class.new.perform
          expect(EndOfCycle::SendWinterRejectByDefaultReminderToProvidersBatchWorker).not_to have_received(:perform_at)
        end
      end
    end

    context 'when winter reject by default is set, and it is on the reminder date' do
      it 'calls batch worker with application choices with start dates after september' do
        travel_temporarily_to(email_send_date) do
          allow(instance).to receive(:send_email?).and_return(true)

          september_course = create(:course, recruitment_cycle_year: previous_year, start_date: Date.parse("01/09/#{previous_year}"))
          _inactive_application = create(:application_choice,
                                         :inactive,
                                         current_recruitment_cycle_year: previous_year,
                                         course_option: create(:course_option, course: september_course))
          _interview_application = create(
            :application_choice,
            :interviewing,
            current_recruitment_cycle_year: previous_year,
            course_option: create(:course_option, course: september_course),
          )
          _awaiting_application = create(
            :application_choice,
            :awaiting_provider_decision,
            current_recruitment_cycle_year: previous_year,
            course_option: create(:course_option, course: september_course),
          )

          january_course = create(:course, recruitment_cycle_year: previous_year, start_date: Date.parse("01/01/#{previous_year + 1}"))
          _jan_inactive_application = create(
            :application_choice,
            :inactive,
            current_recruitment_cycle_year: previous_year,
            course_option: create(:course_option, course: january_course),
          )
          _jan_interview_application = create(
            :application_choice,
            :interviewing,
            current_recruitment_cycle_year: previous_year,
            course_option: create(:course_option, course: january_course),
          )
          _jan_awaiting_application = create(
            :application_choice,
            :awaiting_provider_decision,
            current_recruitment_cycle_year: previous_year,
            course_option: create(:course_option, course: january_course),
          )
          duplication_january_course = create(
            :course,
            start_date: Date.parse("01/01/#{previous_year + 1}"),
          )
          _jan_inactive_application_this_cycle = create(
            :application_choice,
            :inactive,
            course_option: create(:course_option, course: duplication_january_course),
          )

          # These two application choices should not be included
          create(:application_choice, :rejected, current_recruitment_cycle_year: previous_year)
          create(:application_choice, :unsubmitted, current_recruitment_cycle_year: previous_year)

          allow(EndOfCycle::SendWinterRejectByDefaultReminderToProvidersBatchWorker).to receive(:perform_at)
          instance.perform

          expect(EndOfCycle::SendWinterRejectByDefaultReminderToProvidersBatchWorker)
            .to have_received(:perform_at).with(kind_of(Time), [
              january_course.provider.id, duplication_january_course.provider.id
            ])
        end
      end
    end
  end

  def email_send_date
    EndOfCycle::ProviderEmailTimetabler.new.reject_by_default_reminder_provider_date
  end
end
