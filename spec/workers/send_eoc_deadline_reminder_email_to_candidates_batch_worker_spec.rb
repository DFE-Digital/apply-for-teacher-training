require 'rails_helper'

RSpec.describe SendEocDeadlineReminderEmailToCandidatesBatchWorker, :sidekiq do
  describe '#perform' do
    let(:candidate) { create(:candidate) }

    let(:application_form) do
      create(
        :application_form,
        candidate:,
        phase: 'apply_1',
        application_choices: [create(:application_choice, :application_not_sent)],
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
    end

    it 'sends emails to the given candidates' do
      described_class.new.perform(application_form.id)

      expect(email_for_candidate(candidate)).to be_present
    end

    it 'creates ChaserSent for the given candidates' do
      described_class.new.perform(application_form.id)

      expect(candidate.current_application.chasers_sent.pluck(:chaser_type)).to eq(['eoc_deadline_reminder'])
    end

    it 'does nothing if the email was already sent' do
      allow(CycleTimetable).to receive(:apply_1_deadline).and_return(1.day.ago)

      candidate.current_application.chasers_sent.create(
        chaser_type: :eoc_deadline_reminder,
      )

      described_class.new.perform(candidate.id)

      expect(email_for_candidate(candidate)).not_to be_present
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
