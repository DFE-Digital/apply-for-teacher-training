require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesWorker, sidekiq: true do
  describe '#perform' do
    context 'when the candidate is in Apply 1' do
      it 'returns an application when the deadline is 2 months away' do
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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
        Timecop.travel(CycleTimetable.apply_1_deadline_second_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder - 1.month) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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
        Timecop.travel(CycleTimetable.apply_1_deadline + 1.day) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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
        Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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
        Timecop.travel(CycleTimetable.apply_2_deadline_first_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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
        Timecop.travel(CycleTimetable.apply_2_deadline_second_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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
        Timecop.travel(CycleTimetable.apply_2_deadline_first_reminder - 1.month) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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
        Timecop.travel(CycleTimetable.apply_2_deadline + 1.day) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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
        Timecop.travel(CycleTimetable.apply_2_deadline_first_reminder) do
          candidate = create(:candidate)

          create(
            :application_form,
            candidate: candidate,
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

  describe 'Staggered email sending' do
    around do |example|
      Timecop.freeze do
        example.run
      end
    end

    before do
      @application_form = instance_double(ActiveRecord::Relation)
      allow(SendEocDeadlineReminderEmailToCandidatesBatchWorker).to receive(:perform_at).and_return(nil)
    end

    context 'with 2 batches' do
      before do
        allow(@application_forms).to receive(:count).and_return(200)
        allow(@application_forms).to receive(:find_in_batches).and_yield(
          (1..120).map { |id| ApplicationForm.new(id: id) },
        ).and_yield(
          (121..200).map { |id| ApplicationForm.new(id: id) },
        )
        allow(GetApplicationsToSendDeadlineRemindersTo).to receive(:call).and_return(@application_forms)
        allow(CycleTimetable).to receive(:need_to_send_deadline_reminder?).and_return(true)
      end

      it 'queues two staggered SendEocDeadlineReminderEmailToCandidatesBatchWorker jobs' do
        described_class.new.perform

        expect(SendEocDeadlineReminderEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now, (1..120).to_a),
        )
        expect(SendEocDeadlineReminderEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now + described_class::STAGGER_OVER, (121..200).to_a),
        )
      end
    end

    context 'with 3 batches' do
      before do
        allow(@application_forms).to receive(:count).and_return(300)
        allow(@application_forms).to receive(:find_in_batches).and_yield(
          (1..120).map { |id| Candidate.new(id: id) },
        ).and_yield(
          (121..240).map { |id| Candidate.new(id: id) },
        ).and_yield(
          (241..300).map { |id| Candidate.new(id: id) },
        )
        allow(GetApplicationsToSendDeadlineRemindersTo).to receive(:call).and_return(@application_forms)
        allow(CycleTimetable).to receive(:need_to_send_deadline_reminder?).and_return(true)
      end

      it 'queues three staggered SendEocDeadlineReminderEmailToCandidatesBatchWorker jobs' do
        described_class.new.perform

        expect(SendEocDeadlineReminderEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now, (1..120).to_a),
        )
        expect(SendEocDeadlineReminderEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now + (described_class::STAGGER_OVER / 2.0), (121..240).to_a),
        )
        expect(SendEocDeadlineReminderEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now + described_class::STAGGER_OVER, (241..300).to_a),
        )
      end
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
