require 'rails_helper'

RSpec.describe RevertApplicationChoicesUpdatedAtWorker, :audited_automatic_process do
  before do
    TestSuiteTimeMachine.unfreeze!
  end

  describe '#perform' do
    it 'updates the application_choices that have been touched by the big touch', :with_audited do
      correct_choice = nil
      choice_with_wrong_audit = nil
      august = Time.zone.parse('2024-8-1')

      TestSuiteTimeMachine.travel_temporarily_to(august) do
        application_form = create(:completed_application_form)
        correct_choice = create(:application_choice, application_form:)
        choice_with_wrong_audit = create(:application_choice, application_form:)
      end

      september = Time.zone.parse('2024-9-3 16:00')
      TestSuiteTimeMachine.travel_temporarily_to(september) do
        create(
          :application_work_experience,
          experienceable: correct_choice,
        )
      end
      create(
        :application_work_experience,
        experienceable: choice_with_wrong_audit,
      )
      choices = [correct_choice.id, choice_with_wrong_audit.id]

      allow(Rails.logger).to receive(:info)

      expect {
        described_class.new.perform(choices)
      }.to not_change(choice_with_wrong_audit.reload, :updated_at)
      .and not_change(correct_choice.reload.own_and_associated_audits, :count)
      .and not_change(correct_choice.application_form.reload, :updated_at)
      .and not_change(correct_choice.application_form.candidate, :updated_at)

      expect(correct_choice.reload.updated_at).to eq(august)

      expect(Rails.logger).to have_received(:info).with(
        "Updated choice ids: #{[correct_choice.id]}",
      )
    end

    it 'does update choice when there is a user audit before touch', :with_audited do
      application_choice = nil

      TestSuiteTimeMachine.travel_temporarily_to(Time.zone.parse('2024-8-1')) do
        application_choice = create(:application_choice, :with_submitted_application_form)
      end

      user_audit = Time.zone.parse('2024-9-3 11:00')
      TestSuiteTimeMachine.travel_temporarily_to(user_audit) do
        create(
          :interview,
          application_choice:,
        )
      end

      the_touch = Time.zone.parse('2024-9-3 16:00')
      TestSuiteTimeMachine.travel_temporarily_to(the_touch) do
        create(
          :application_work_experience,
          experienceable: application_choice,
        )
      end
      # replicates the updated at of the choice being before the audit in terms of timestamp
      application_choice.update_column(:updated_at, application_choice.updated_at - 0.01.seconds)

      choices = [application_choice.id]

      described_class.new.perform(choices)

      expect(application_choice.reload.updated_at).to be_within(0.5).of(user_audit)
    end

    it 'does not update choice when there is a user audit after touch', :with_audited do
      application_choice = nil

      TestSuiteTimeMachine.travel_temporarily_to(Time.zone.parse('2024-8-1')) do
        application_choice = create(:application_choice, :with_submitted_application_form)
      end

      the_touch = Time.zone.parse('2024-9-3 16:00')
      TestSuiteTimeMachine.travel_temporarily_to(the_touch) do
        create(
          :application_work_experience,
          experienceable: application_choice,
        )
      end

      user_audit = Time.zone.parse('2024-9-3 17:00')
      TestSuiteTimeMachine.travel_temporarily_to(user_audit) do
        create(
          :interview,
          application_choice:,
        )
      end
      # replicates the updated at of the choice being before the audit in terms of timestamp
      application_choice.update_column(:updated_at, application_choice.updated_at - 0.01.seconds)

      choices = [application_choice.id]

      expect {
        described_class.new.perform(choices)
      }.to not_change(application_choice.reload, :updated_at)

      expect(application_choice.updated_at).to be_within(0.5).of(user_audit)
    end

    it 'does not update choices with user created audits after the big touch', :with_audited do
      application_choice = nil

      august = Time.zone.parse('2024-8-1')
      TestSuiteTimeMachine.travel_temporarily_to(august) do
        application_choice = create(:application_choice, :with_submitted_application_form)
      end

      the_touch = Time.zone.parse('2024-9-3 16:00')
      TestSuiteTimeMachine.travel_temporarily_to(the_touch) do
        create(
          :application_work_experience,
          experienceable: application_choice,
        )
      end
      create(
        :interview,
        application_choice:,
        created_at: Time.zone.parse('2024-9-10'),
      )
      choices = [application_choice.id]

      expect {
        described_class.new.perform(choices)
      }.to not_change(application_choice.reload, :updated_at)

      expect(application_choice.updated_at).not_to be_within(0.5).of(the_touch)
    end

    it 'does not update choices that have updated_at passed touch audit', :with_audited do
      application_choice = nil

      august = Time.zone.parse('2024-8-1')
      TestSuiteTimeMachine.travel_temporarily_to(august) do
        application_choice = create(:application_choice, :with_submitted_application_form)
      end

      the_touch = Time.zone.parse('2024-9-3 16:00')
      TestSuiteTimeMachine.travel_temporarily_to(the_touch) do
        create(
          :application_work_experience,
          experienceable: application_choice,
        )
      end
      application_choice.update_columns(updated_at: Time.zone.now)
      choices = [application_choice.id]

      expect {
        described_class.new.perform(choices)
      }.to not_change(application_choice.reload, :updated_at)

      expect(application_choice.updated_at).not_to be_within(0.5).of(the_touch)
    end
  end
end
