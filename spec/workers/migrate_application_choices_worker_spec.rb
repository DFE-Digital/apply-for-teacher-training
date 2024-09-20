require 'rails_helper'

RSpec.describe MigrateApplicationChoicesWorker do
  describe '#perform' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    it 'dups the working experiences and histories from application_form to choice', :with_audited do
      application_form = create(
        :completed_application_form,
        volunteering_experiences_count: 1,
        full_work_history: true,
      )
      application_form_2 = create(
        :completed_application_form,
        volunteering_experiences_count: 1,
        full_work_history: true,
      )
      choice = create(:application_choice, application_form:)
      choice_with_data_migrated = create(
        :application_choice,
        application_form: application_form_2,
      )
      create(
        :application_work_experience,
        experienceable: choice_with_data_migrated,
      )
      create(
        :application_volunteering_experience,
        experienceable: choice_with_data_migrated,
      )
      create(
        :application_work_history_break,
        breakable: choice_with_data_migrated,
      )
      choice_ids = [choice.id, choice_with_data_migrated.id]

      expect {
        described_class.new.perform(choice_ids)
      }.to change(choice.work_experiences, :count).by(2)
        .and change(choice.volunteering_experiences, :count).by(1)
        .and change(choice.work_history_breaks, :count).by(1)
        .and not_change(choice_with_data_migrated.work_experiences, :count)
        .and not_change(choice_with_data_migrated.volunteering_experiences, :count)
        .and not_change(choice_with_data_migrated.work_history_breaks, :count)
        .and not_change(choice.own_and_associated_audits, :count)
        .and not_change(choice.reload, :updated_at)
        .and not_change(application_form.reload, :updated_at)
        .and not_change(application_form.candidate, :updated_at)
    end

    context 'when env is production' do
      it 'does not create work histories' do
        application_form = create(
          :completed_application_form,
          volunteering_experiences_count: 1,
          full_work_history: true,
        )
        choice = create(:application_choice, application_form:)

        allow(HostingEnvironment).to receive(:production?).and_return(true)

        expect {
          described_class.new.perform([choice.id])
        }.to not_change(choice.work_experiences, :count)
          .and not_change(choice.volunteering_experiences, :count)
          .and not_change(choice.work_history_breaks, :count)
          .and not_change(choice.own_and_associated_audits, :count)
          .and not_change(choice.reload, :updated_at)
          .and not_change(application_form.reload, :updated_at)
          .and not_change(application_form.candidate, :updated_at)
      end
    end
  end
end
