require 'rails_helper'

RSpec.describe DataMigrations::BackfillExperienceableOnApplicationExperiences do
  context 'when experienceable_id and experienceable_type are not nil' do
    it 'does not backfill the experienceable attributes' do
      application_form = create(:application_form)
      application_experience = create(:application_work_experience, application_form:, experienceable_id: application_form.id, experienceable_type: 'ApplicationForm')

      expect {
        described_class.new.change
      }.not_to change {
        application_experience.reload.experienceable_id
      }
    end
  end

  context 'when experienceable_id and experienceable_type are nil' do
    it 'backfills the experienceable attributes' do
      application_form_1 = create(:application_form)
      application_experience_1 = create(:application_work_experience, application_form: application_form_1, experienceable_id: nil, experienceable_type: nil)

      application_form_2 = create(:application_form)
      application_experience_2 = create(:application_work_experience, application_form: application_form_2, experienceable_id: nil, experienceable_type: nil)

      described_class.new.change

      expect(application_experience_1.reload.experienceable_id).to eq application_form_1.id
      expect(application_experience_1.reload.experienceable_type).to eq "ApplicationForm"
      expect(application_experience_2.reload.experienceable_id).to eq application_form_2.id
      expect(application_experience_2.reload.experienceable_type).to eq "ApplicationForm"
    end
  end
end
