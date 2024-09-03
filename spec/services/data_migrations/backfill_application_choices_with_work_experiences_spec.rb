require 'rails_helper'

RSpec.describe DataMigrations::BackfillApplicationChoicesWithWorkExperiences do
  describe '#change' do
    it 'enques jobs to MigrateApplicationChoicesWorker' do
      application_form = create(:application_form)
      create(:application_choice, :awaiting_provider_decision, application_form:)

      expect { described_class.new.change }.to change(
        MigrateApplicationChoicesWorker.jobs, :size
      ).by(1)
    end
  end

  describe '#choices_without_work_histories' do
    it 'returns all the application choices that need to be backfilled' do
      application_form = create(:application_form)
      choice1 = create(:application_choice, :awaiting_provider_decision, application_form:)
      choice2 = create(:application_choice, :awaiting_provider_decision, application_form:)
      create(
        :application_work_experience,
        experienceable: choice2,
      )
      create(
        :application_work_history_break,
        breakable: choice2,
      )
      choice3 = create(:application_choice, :awaiting_provider_decision, application_form:)
      create(
        :application_work_experience,
        experienceable: choice3,
      )
      create(
        :application_volunteering_experience,
        experienceable: choice3,
      )
      choice4 = create(:application_choice, :awaiting_provider_decision, application_form:)
      create(
        :application_work_experience,
        experienceable: choice4,
      )
      create(
        :application_volunteering_experience,
        experienceable: choice4,
      )
      create(
        :application_work_history_break,
        breakable: choice4,
      )

      expect(described_class.new.choices_without_work_histories).to include(
        choice1.id, choice2.id, choice3.id
      )
      expect(described_class.new.choices_without_work_histories).not_to include(
        choice4.id,
      )
    end
  end
end
