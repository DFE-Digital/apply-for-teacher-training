require 'rails_helper'

RSpec.describe DataMigrations::BackfillExperienceableForApplicationForms do
  it 'backfills application experiences with experienceable id and type nil' do
    volunteering_experience = create(
      :application_volunteering_experience,
      application_form: create(:application_form),
    )
    # skip the callback that sets these columns
    volunteering_experience.update_columns(experienceable_id: nil, experienceable_type: nil)
    work_experience = create(
      :application_work_experience,
      application_form: create(:application_form),
    )
    work_experience.update_columns(experienceable_id: nil, experienceable_type: nil)

    described_class.new.change

    expect(volunteering_experience.reload.experienceable_id).to eq(volunteering_experience.application_form_id)
    expect(volunteering_experience.experienceable_type).to eq('ApplicationForm')
    expect(work_experience.reload.experienceable_id).to eq(work_experience.application_form_id)
    expect(work_experience.experienceable_type).to eq('ApplicationForm')
  end
end
