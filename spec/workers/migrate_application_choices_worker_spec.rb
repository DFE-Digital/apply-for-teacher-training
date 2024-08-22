require 'rails_helper'

RSpec.describe MigrateApplicationChoicesWorker do
  describe '#perform' do
    it 'dups the working experiences and histories from application_form to choice' do
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
      allow(Rails.logger).to receive(:info)

      expect {
        described_class.new.perform(choice_ids)
      }.to change(choice.work_experiences, :count).by(2)
        .and change(choice.volunteering_experiences, :count).by(1)
        .and change(choice.work_history_breaks, :count).by(1)
        .and not_change(choice_with_data_migrated.work_experiences, :count)
        .and not_change(choice_with_data_migrated.volunteering_experiences, :count)
        .and not_change(choice_with_data_migrated.work_history_breaks, :count)
      expect(Rails.logger).to have_received(:info).with('No errors')
    end

    context 'with errors' do
      it 'dups the working experiences and histories from application_form to choice' do
        application_form = create(
          :completed_application_form,
          volunteering_experiences_count: 1,
          full_work_history: true,
        )
        choice = create(:application_choice, application_form:)
        choice_ids = [choice.id]

        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(ApplicationChoice).to receive(:work_experiences=)
          .and_raise(ActiveRecord::RecordInvalid)
        # rubocop:enable RSpec/AnyInstance
        allow(Rails.logger).to receive(:info)

        described_class.new.perform(choice_ids)
        expect(Rails.logger).to have_received(:info).with("Error choice id #{choice.id}: Record invalid")
      end
    end
  end
end
