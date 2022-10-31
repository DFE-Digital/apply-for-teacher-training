require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesWorker, sidekiq: true do
  describe '#perform' do
    context 'when the candidate is in Apply 1' do
      it 'returns an application when the deadline is 2 months away' do
        travel_temporarily_to(CycleTimetable.apply_1_deadline_first_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_1',
            application_choices: [create(:application_choice, :application_not_sent)],
            recruitment_cycle_year: RecruitmentCycle.current_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).to be_present
        end
      end

      it 'does not return an application where the candidate is unsubscribed' do
        allow(CycleTimetable).to receive(:need_to_send_deadline_reminder?).and_return(:apply_1)

        unsubscribed_candidate = create(:candidate, unsubscribed_from_emails: true)
        create(:application_form, candidate: unsubscribed_candidate)

        described_class.new.perform

        email_for_candidate = email_for_candidate(unsubscribed_candidate)

        expect(email_for_candidate).not_to be_present
      end

      it 'returns an application when the deadline is 1 month away' do
        travel_temporarily_to(CycleTimetable.apply_1_deadline_second_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_1',
            application_choices: [create(:application_choice, :application_not_sent)],
            recruitment_cycle_year: RecruitmentCycle.current_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).to be_present
        end
      end

      it 'does not return an application when the deadline is 3 months away' do
        travel_temporarily_to(CycleTimetable.apply_1_deadline_first_reminder - 1.month) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_1',
            application_choices: [create(:application_choice, :application_not_sent)],
            recruitment_cycle_year: RecruitmentCycle.current_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).not_to be_present
        end
      end

      it 'does not return an application when the deadline has passed' do
        travel_temporarily_to(CycleTimetable.apply_1_deadline + 1.day) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_1',
            application_choices: [create(:application_choice, :application_not_sent)],
            recruitment_cycle_year: RecruitmentCycle.current_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).not_to be_present
        end
      end

      it 'does not return an application form from the previous cycle' do
        travel_temporarily_to(CycleTimetable.apply_1_deadline_first_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_1',
            application_choices: [create(:application_choice, :application_not_sent)],
            recruitment_cycle_year: RecruitmentCycle.previous_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).not_to be_present
        end
      end
    end

    context 'when the candidate is in Apply 2' do
      it 'returns an application when the deadline is 2 months away' do
        travel_temporarily_to(CycleTimetable.apply_2_deadline_first_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_2',
            application_choices: [create(:application_choice, :application_not_sent)],
            recruitment_cycle_year: RecruitmentCycle.current_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).to be_present
        end
      end

      it 'does not return an application where the candidate is unsubscribed' do
        allow(CycleTimetable).to receive(:need_to_send_deadline_reminder?).and_return(:apply_2)

        unsubscribed_candidate = create(:candidate, unsubscribed_from_emails: true)
        create(:application_form, candidate: unsubscribed_candidate)

        described_class.new.perform

        email_for_candidate = email_for_candidate(unsubscribed_candidate)

        expect(email_for_candidate).not_to be_present
      end

      it 'returns an application when the deadline is 1 month away' do
        travel_temporarily_to(CycleTimetable.apply_2_deadline_second_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_2',
            application_choices: [create(:application_choice, :application_not_sent)],
            recruitment_cycle_year: RecruitmentCycle.current_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).to be_present
        end
      end

      it 'does not return an application when the deadline is 3 months away' do
        travel_temporarily_to(CycleTimetable.apply_2_deadline_first_reminder - 1.month) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_2',
            application_choices: [create(:application_choice, :application_not_sent)],
            recruitment_cycle_year: RecruitmentCycle.current_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).not_to be_present
        end
      end

      it 'does not return an application when the deadline has passed' do
        travel_temporarily_to(CycleTimetable.apply_2_deadline + 1.day) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_2',
            application_choices: [create(:application_choice, :application_not_sent)],
            recruitment_cycle_year: RecruitmentCycle.current_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).not_to be_present
        end
      end

      it 'does not return an application form from the previous cycle' do
        travel_temporarily_to(CycleTimetable.apply_2_deadline_first_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate:,
            phase: 'apply_2',
            recruitment_cycle_year: RecruitmentCycle.previous_year,
          )

          described_class.new.perform

          email_for_candidate = email_for_candidate(candidate)

          expect(email_for_candidate).not_to be_present
        end
      end
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
