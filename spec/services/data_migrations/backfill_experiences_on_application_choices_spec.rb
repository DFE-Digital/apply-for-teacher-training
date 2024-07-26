require 'rails_helper'

RSpec.describe DataMigrations::BackfillExperiencesOnApplicationChoices do
  it "creates ApplicationWorkExperience records for application choices that don't have them" do
    application_form = create(:application_form)
    application_choice = create(:application_choice, :awaiting_provider_decision, application_form: application_form)

    create(:application_work_experience, experienceable: application_form)

    expect {
      described_class.new.change
    }.to(change { application_choice.work_experiences.count })
  end

  context 'when the application choice is unsubmitted' do
    it 'does not create ApplicationWorkExperience records' do
      application_choice = create(:application_choice, :unsubmitted)
      application_form = application_choice.application_form
      create(:application_work_experience, experienceable: application_form)

      expect {
        described_class.new.change
      }.to(not_change { application_choice.work_experiences.count })
    end
  end

  context 'when the application choice already has an ApplicationWorkExperience record' do
    it 'does not create a new ApplicationWorkExperience record' do
      application_choice = create(:application_choice, :awaiting_provider_decision)
      application_form = application_choice.application_form
      create(:application_work_experience, experienceable: application_form)
      create(:application_work_experience, experienceable: application_choice)

      expect {
        described_class.new.change
      }.to(not_change { application_choice.work_experiences.count })
    end
  end
end
